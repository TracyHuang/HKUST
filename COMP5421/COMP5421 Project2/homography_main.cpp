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
    
    Mat gray_image1;
    Mat gray_image2;
    // Convert to Grayscale
    cvtColor( image1, gray_image1, CV_RGB2GRAY );
    cvtColor( image2, gray_image2, CV_RGB2GRAY );
    
    //imshow("first image",image2);
    //imshow("second image",image1);
    
    if( !gray_image1.data || !gray_image2.data )
    { std::cout<< " --(!) Error reading images " << std::endl; exit(-1); }
    
    //-- Step 1: Detect the keypoints using SURF Detector
    int minHessian = 400;
    
    SurfFeatureDetector detector( minHessian );
    
    std::vector< KeyPoint > keypoints_object, keypoints_scene;
    
    detector.detect( gray_image1, keypoints_object );
    detector.detect( gray_image2, keypoints_scene );
    
    //-- Step 2: Calculate descriptors (feature vectors)
    SurfDescriptorExtractor extractor;
    
    Mat descriptors_object, descriptors_scene;
    
    extractor.compute( gray_image1, keypoints_object, descriptors_object );
    extractor.compute( gray_image2, keypoints_scene, descriptors_scene );
    
    //-- Step 3: Matching descriptor vectors using FLANN matcher
    FlannBasedMatcher matcher;
    std::vector< DMatch > matches;
    matcher.match( descriptors_object, descriptors_scene, matches );
    
    double max_dist = 0; double min_dist = 100;
    
    //-- Quick calculation of max and min distances between keypoints
    for( int i = 0; i < descriptors_object.rows; i++ )
    { double dist = matches[i].distance;
        if( dist < min_dist ) min_dist = dist;
        if( dist > max_dist ) max_dist = dist;
    }
    
    printf("-- Max dist : %f \n", max_dist );
    printf("-- Min dist : %f \n", min_dist );
    
    //-- Use only "good" matches (i.e. whose distance is less than 3*min_dist )
    std::vector< DMatch > good_matches;
    
    for( int i = 0; i < descriptors_object.rows; i++ )
    { if( matches[i].distance < 3*min_dist )
    { good_matches.push_back( matches[i]); }
    }
    std::vector< Point2f > obj;
    std::vector< Point2f > scene;
    
    for( int i = 0; i < good_matches.size(); i++ )
    {
        //-- Get the keypoints from the good matches
        obj.push_back( keypoints_object[ good_matches[i].queryIdx ].pt );
        scene.push_back( keypoints_scene[ good_matches[i].trainIdx ].pt );
    }
    
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
        
        images.push_back(img);
    }
    
    Mat result =  blendImage(images[1], images[0]);
    
    
    
    for (int i = 2; i < numImage; i ++) {
        result = blendImage(images[i], result);
        
        //for (int i = 0; i < 20; i ++) {
        //    result = removeBlackRegion(result);
        //}
        //imshow("result", result);
        //waitKey();
    }
    
    imwrite("/Users/tianweihuang/Desktop/result.jpg", result);
    imshow( "Result", result );
    waitKey();
    
    //Mat temp_result = removeBlackRegion(result);
    
    //imwrite("/Users/tianweihuang/Desktop/b.jpg", temp_result);
    
    return 0;
    
}