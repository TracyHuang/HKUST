//
//  Huang Tianwei 20026141 twhuang@connect.ust.hk
//
//  main.cpp
//  COMP5421 Project 2
//
//  Created by Tianwei Huang on 22/4/15.
//  Copyright (c) 2015 Tianwei Huang. All rights reserved.
//

#include <iostream>
#include <opencv2/opencv.hpp>
#include <dirent.h>
#include <vector>
#include <cmath>
#include <string>
#include "opencv2/core/core.hpp"
#include "opencv2/features2d/features2d.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/nonfree/nonfree.hpp"
#include "opencv2/calib3d/calib3d.hpp"
#include "opencv2/imgproc/imgproc.hpp"


using namespace std;
using namespace cv;

vector<string> imageFileNames;
int numImage = 0;
vector<Mat> images;
unsigned char isFile = 0x8;

volatile float adc_value;
#define Q 1e-6f
#define R 1e-1f
volatile float kalman_value;
volatile float kalman_p;
float p;
float x;
float kg;

void kalman_filter()
{
    
    x = kalman_value;
    p = kalman_p + Q;
    kg = p / (p + R);
    kalman_p = (1 - kg) * p;
    kalman_value = x + kg * (adc_value - x);
}





void calcTransport(Mat a, Mat b, int* xt, int* yt) {
    Mat c = a * b;
    if (c.rows != 2 || c.cols != 1) {
        cerr << "calculate transport error, the size of c is " << c.rows << " " << c.cols << endl;
        return;
    }
    
    *xt = c.at<int>(0, 0);
    *yt = c.at<int>(1, 0);
    
    return;
    
}

bool sortContour(vector<Point> a, vector<Point> b) {
    return (a.size() > b.size());
}

Mat removeBlackRegion(Mat img) {
    Mat result;
    cvtColor(img, result, CV_BGR2GRAY);
    Mat mask;
    threshold(result, mask, 1.0, 255.0, THRESH_BINARY);
    Mat temp(mask);

    
    vector<vector<Point>> contours;
    vector<Vec4i> hierarchy;
    findContours(temp, contours, hierarchy, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);

    
    sort(contours.begin(), contours.end(), sortContour);
    Rect roi = boundingRect(contours[0]);

    //result = img(roi);
    return img(roi);
}

Mat blendImage(Mat image1, Mat image2) {
    
    
    
    Mat gray_image1 = image1;
    Mat gray_image2 = image2;
    // Convert to Grayscale
    //cvtColor( image1, gray_image1, CV_RGB2GRAY );
    //cvtColor( image2, gray_image2, CV_RGB2GRAY );
    
    //imshow("first image",gray_image1);
    //waitKey(0);
    //imshow("second image",gray_image2);
    //waitKey(0);
    
    if( !gray_image1.data || !gray_image2.data )
    { std::cout<< " --(!) Error reading images " << std::endl; exit(-1); }
    
    //-- Step 1: Detect the keypoints using SURF Detector
    int minHessian = 400;
    
    SurfFeatureDetector detector( minHessian );
    
    std::vector< KeyPoint > keypoints_1, keypoints_2;
    
    detector.detect( gray_image1, keypoints_1 );
    detector.detect( gray_image2, keypoints_2 );
    
    
    //cout << endl;
    //cout << keypoints_1.size() << " " << keypoints_2.size() << endl;
    //-- Step 2: Calculate descriptors (feature vectors)
    SurfDescriptorExtractor extractor;
    
    Mat descriptors_1, descriptors_2;
    
    extractor.compute( gray_image1, keypoints_1, descriptors_1 );
    extractor.compute( gray_image2, keypoints_2, descriptors_2 );
    
    //-- Step 3: Matching descriptor vectors using FLANN matcher
    FlannBasedMatcher matcher;
    std::vector< DMatch > matches;
    matcher.match( descriptors_1, descriptors_2, matches );
    
    
    //cout << "match " << matches.size();
    //printf("%zu\n", matches.size());
    
    double max_dist = 0; double min_dist = 100;
    
    //-- Quick calculation of max and min distances between keypoints
    for( int i = 0; i < descriptors_1.rows; i++ )
    { double dist = matches[i].distance;
        if( dist < min_dist ) min_dist = dist;
        if( dist > max_dist ) max_dist = dist;
    }
    
    //printf("-- Max dist : %f \n", max_dist );
    //printf("-- Min dist : %f \n", min_dist );
    
    //-- Use only "good" matches (i.e. whose distance is less than 3*min_dist )
    std::vector< DMatch > good_matches;
    
    for( int i = 0; i < descriptors_1.rows; i++ )
    { if( matches[i].distance < max(0.02, 2*min_dist) )
    { good_matches.push_back( matches[i]); }
    }
    
    //cout << "good matches" << good_matches.size() << endl;
    std::vector< Point2f > points1;
    std::vector< Point2f > points2;
    
    for( int i = 0; i < good_matches.size(); i++ )
    {
        //-- Get the keypoints from the good matches
        points1.push_back( keypoints_1[ good_matches[i].queryIdx ].pt );
        points2.push_back( keypoints_2[ good_matches[i].trainIdx ].pt );
    }
    
    // now we need to calculate average Xt and Yt
    int Xt = 0;
    int Yt = 0;
    float xSum = 0.0;
    float ySum = 0.0;
    int i = 0;
    
    for(i = 0; i < points1.size(); i ++) {
        xSum += points1[i].x - points2[i].x;
        ySum += points1[i].y - points2[i].y;
        
    }
    
    Xt = xSum / i;
    Yt = ySum / i;

    /*
    cout << "X DIFF" << endl;
    for (i = 0; i < points1.size(); i ++) {
        
        adc_value = points1[i].x - points2[i].x;
        cout << "adc_value " << adc_value << endl;
        kalman_filter();
        cout << "kalman value" << kalman_value << endl;
        //Xt += int(points1[i].x - points2[i].x );
        //Yt += int(points1[i].y - points2[i].y );
    }
    Xt = kalman_value;
    
    cout << "finished" << endl;
    cin >> temp;
    
    kalman_value = 0.0;
    for (i = 0; i < points1.size(); i ++) {
        adc_value = points1[i].y - points2[i].y;
        kalman_filter();
    }
    Yt = kalman_value;
    */
    
    
    Mat left, right;
    
    if (Xt > 0) {
        left = image1;
        right = image2;
    }
    else {
        left = image2;
        right = image1;
    }
    
    cout << "Xt " << Xt << " Yt " << Yt << " left.cols " << left.cols << " right.cols " << right.cols << endl;
    Xt = abs(Xt);
    
    Mat result(left.rows, right.cols + Xt, CV_8UC3, Scalar(0));
    
    for (int i = 0; i < Xt; i ++) {
        for (int j = 0; j < left.rows; j ++) {
            result.at<Vec3b>(j, i) = left.at<Vec3b>(j, i);
        }
    }
    
    
    double left_weight = 0.0;
    double right_weight = 0.0;
    for (int i = 0; i < left.cols - Xt; i ++) {
        left_weight = 1.0 - double(i) / double(left.cols - Xt);
        right_weight = double(i) / double(left.cols - Xt);
        for (int j = 0; j < left.rows; j ++) {
            result.at<Vec3b>(j, i + Xt)[0] = left.at<Vec3b>(j, i + Xt)[0] * left_weight + right.at<Vec3b>(j, i)[0] * right_weight;
            result.at<Vec3b>(j, i + Xt)[1] = left.at<Vec3b>(j, i + Xt)[1] * left_weight + right.at<Vec3b>(j, i)[1] * right_weight;
            result.at<Vec3b>(j, i + Xt)[2] = left.at<Vec3b>(j, i + Xt)[2] * left_weight + right.at<Vec3b>(j, i)[2] * right_weight;

        }
    }

    
    int length = right.cols - ( left.cols - Xt);
    for (int i = 0; i < length; i ++) {
        for (int j = 0; j < left.rows; j ++) {
            result.at<Vec3b>(j, i + left.cols) = right.at<Vec3b>(j, (left.cols - Xt) + i);
        }
    }
    

    
    return result;
    /*
    // Find the Homography Matrix
    Mat H = findHomography( obj, scene, CV_RANSAC );
    // Use the Homography Matrix to warp the images
    cv::Mat result;
    warpPerspective(image1,result,H,cv::Size(image1.cols+image2.cols,image1.rows));
    cv::Mat half(result,cv::Rect(0,0,image2.cols,image2.rows));
    image2.copyTo(half);
    //imwrite("/Users/tianweihuang/Desktop/a.jpg", result);
    
    for (int i = 0; i < 20; i ++) {
        result = removeBlackRegion(result);
    }
    return result;
    */
}


int main (int argc, const char * argv[])
{
    DIR*     dir;
    dirent*  pdir;
    
    dir = opendir(argv[1]);     // open current directory
    
    while (pdir = readdir(dir)) {
        //if (pdir == NULL) break;
        if (pdir->d_type == isFile) {
            imageFileNames.push_back(string(argv[1]) + string(pdir->d_name));
            cout << string(string(argv[1]) + string(pdir->d_name)) << endl;
            numImage ++;
        }
    }
    closedir(dir);
    
    
    Mat img;
    for (int i = 0; i < numImage; i ++) {
        Mat img = imread(imageFileNames[i], CV_LOAD_IMAGE_COLOR);
        if (img.data == 0) {
            cerr << "Image not found!" << endl;
            return -1;
        }
        resize(img, img, cvSize(0,0), 0.5, 0.5,cv::INTER_CUBIC);
        images.push_back(img);
    }
    
    Mat result =  blendImage(images[1], images[0]);
    
    imshow("result", result);
    cout << "Press any key to continue..." << endl;
    waitKey();
    
    for (int i = 2; i < numImage; i ++) {
        result = blendImage(images[i], result);
        
        imshow("result", result);
        cout << "Press any key to continue..." << endl;
        waitKey();
    }
    
    imwrite("result.jpg", result);
    cout << "result saved to ./result.jpg" << endl;
   

    
    return 0;
    
}