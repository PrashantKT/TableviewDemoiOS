//
//  ObjectDetector.cpp
//  ObjectTracker
//
//  Created by Sheila Gonzalez on 12/10/18.
//  Copyright © 2018 GIMME360. All rights reserved.
//

#include "ObjectDetector.hpp"

ObjectDetector::ObjectDetector()
{
    foundCascade = false;
    tracking = false;
    
    // Parameters tested on (1920 x 1080) images
    minSize = cv::Size(45, 10);
    maxSize = cv::Size(150, 60);
    preScaleFactor = 0.4;
    scaleFactor = 1.1;
    minNeighbors = 15;
    roiScale = 1.2;
}

bool ObjectDetector::isDetectorReady()
{
    return foundCascade;
}

bool ObjectDetector::open(std::string modelName)
{
    foundCascade = cascade.load(modelName);
    return foundCascade;
}

bool ObjectDetector::detect(cv::Mat &img, std::vector< cv::Rect > &objects)
{
    objects.clear();
    
    // If not detector was found, return
    if(!foundCascade)   return false;
    
    // To improve the speed of detection, scale down the image by preScaleFactor
    // That way, the search is performed on a reduced space
    cv::Mat scaledImage;
    cv::resize(img, scaledImage, cv::Size(0,0), preScaleFactor, preScaleFactor);
    cv::cvtColor(scaledImage, scaledImage, CV_BGR2GRAY);
    
    // Detect objects
    std::vector< cv::Rect > found;
    cascade.detectMultiScale(scaledImage, found, scaleFactor, minNeighbors, 0, minSize, maxSize);
    
    for(int i=0; i<found.size(); i++)
        // Scale detected objects' rectangles to original size
        objects.push_back(cv::Rect(found[i].x/preScaleFactor,
                                   found[i].y/preScaleFactor,
                                   found[i].width/preScaleFactor,
                                   found[i].height/preScaleFactor));

    
    return true;
}

bool ObjectDetector::detectAndTrack(cv::Mat &img, std::vector < cv::Rect > &objects)
{
    objects.clear();
    
    // If not detector was found, return
    if(!foundCascade)   return false;
    
    if(!tracking)
    {
        detect(img, objects);
        if(objects.size() > 0)
        {
            roi.clear();
            for(int i=0; i<objects.size(); i++)
            {
                // Compute ROIs for tracking
                int dw = objects[i].width * (roiScale - 1);
                int dh = objects[i].height * (roiScale - 1);
                int newX = objects[i].x - dw * 0.5;
                int newY = objects[i].y - dh * 0.5;
                int newWidth = objects[i].width * roiScale;
                int newHeight = objects[i].height * roiScale;
                // If proposed ROI is completely inside the image, accept it
                if(newX >= 0 && newY >= 0 &&
                   newX+newWidth <= img.cols && newY+newHeight <= img.rows)
                    roi.push_back(cv::Rect(newX, newY, newWidth, newHeight));
            }
            if(roi.size() > 0)
                tracking = true;
        }
    }
    else
    {
        std::vector<cv::Rect> newROI;
        for(int i=0; i<roi.size(); i++)
        {
            cv::Mat subImage;
            img(roi[i]).copyTo(subImage);
            
            std::vector<cv::Rect> found;
            detect(subImage, found);
            if(found.size() > 0)
            {
                objects.push_back(cv::Rect(roi[i].x+found[0].x, roi[i].x+found[0].y,
                                           found[0].width, found[0].height));
                // Compute ROIs for tracking
                int dw = found[0].width * (roiScale - 1);
                int dh = found[0].height * (roiScale - 1);
                int newX = roi[i].x + found[0].x - dw * 0.5;
                int newY = roi[i].y + found[0].y - dh * 0.5;
                int newWidth = found[0].width * roiScale;
                int newHeight = found[0].height * roiScale;
                // If proposed ROI is completely inside the image, accept it
                if(newX >= 0 && newY >= 0 &&
                   newX+newWidth <= img.cols && newY+newHeight <= img.rows)
                    newROI.push_back(cv::Rect(newX, newY, newWidth, newHeight));
            }
        }
        if(newROI.size() == 0)  tracking = false;
        roi = newROI;
    }
    
    return true;
}
