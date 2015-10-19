//
//  main.cpp
//  project_2
//
//  Created by Tianwei Huang on 21/4/15.
//  Copyright (c) 2015 Tianwei Huang. All rights reserved.
//

#include <iostream>
#include <opencv2/opencv.hpp>

using namespace std;
using namespace cv;

int main (int argc, const char * argv[])
{
    Mat img = imread("/Users/sadeep/Desktop/image.jpg"); //Change the image path here.
    if (img.data == 0) {
        cerr << "Image not found!" << endl;
        return -1;
    }
    namedWindow("image", CV_WINDOW_AUTOSIZE);
    imshow("image", img);
    waitKey();
}