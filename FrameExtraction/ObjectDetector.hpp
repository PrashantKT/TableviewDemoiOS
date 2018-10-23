//
//  ObjectDetector.hpp
//  ObjectTracker
//
//  Created by Sheila Gonzalez on 12/10/18.
//  Copyright © 2018 GIMME360. All rights reserved.
//

#ifndef ObjectDetector_hpp
#define ObjectDetector_hpp

#include <iostream>
#include <opencv2/opencv.hpp>

class ObjectDetector
{
public:
    ObjectDetector();
    
    bool isDetectorReady();
    
    bool open(std::string modelName);
    bool detect(cv::Mat &img, std::vector< cv::Rect > &objects);
    bool detectAndTrack(cv::Mat &img, std::vector < cv::Rect > &objects);
    
private:
    cv::CascadeClassifier cascade;
    std::vector< cv::Rect > roi;
    bool foundCascade;
    bool tracking;

    cv::Size minSize;           // Minimum size of object
    cv::Size maxSize;           // Maximum size of object
    float preScaleFactor;       // Scale factor prior to object detection
    float scaleFactor;          // Scale factor during object detection
    int minNeighbors;           // Minimum number of neighbors to accept detection
    float roiScale;
};

#endif /* ObjectDetector_hpp */
