//
//  OpenCVWrapper.m
//  FrameExtraction
//
//  Created by Sheila Gonzalez on 17/10/18.
//  Copyright © 2018 GIMME360. All rights reserved.
//

#import "OpenCVWrapper.h"
#import "opencv2/opencv.hpp"
#import "opencv2/imgcodecs/ios.h"
#include "ObjectDetector.hpp"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

ObjectDetector detector;

@implementation OpenCVWrapper

+(UIImage *) testProcess : (UIImage*) image{
    // Transform UIImage to cv::Mat
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    
    // If the image is already grayscale, return
    if(imageMat.channels() == 1) return image;
    
    // Convert to grayscale
    cv::cvtColor(imageMat, imageMat, CV_BGR2GRAY);
    
    // Convert back to UIImage
    return MatToUIImage(imageMat);
}

+(UIImage *) processImage : (UIImage*) image
{
    if(!detector.isDetectorReady())
    {
        NSString *cascadePath = [[NSBundle mainBundle]
                                 pathForResource:@"cascadeHAAR"
                                 ofType:@"xml"];
        const CFIndex CASCADE_NAME_LEN = 2048;
        char *CASCADE_NAME = (char *) malloc(CASCADE_NAME_LEN);
        CFStringGetFileSystemRepresentation( (CFStringRef)cascadePath,
                                            CASCADE_NAME,
                                            CASCADE_NAME_LEN);
        // Cannot find cascadeHAAR.xml
        if(!detector.open(CASCADE_NAME))
        {
            NSLog(@"Detector not found!");
            free(CASCADE_NAME);
            return NULL;
        }
        free(CASCADE_NAME);
    }
    // Transform UIImage to cv::Mat
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    
    // OBJECT DETECTION
    // The position of every found object is stored on "position" vector of Rectangles
    // The number of found objects can be accessed using "position.size"
    std::vector< cv::Rect > position;
    //detector.detect(frame, position);             // Just detection
    detector.detectAndTrack(imageMat, position);    // Detection and tracking (faster!)
    
//    UIImage *tempImage = MatToUIImage(imageMat);
//    CGImageRef imageRef = CGImageCreateWithImageInRect(tempImage.CGImage, CGRectMake(position[0].x, position[0].y, position[0].width, position[0].height));
//
//    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
//    CGImageRelease(imageRef);
//
//    return cropped;
//
    for(int i=0; i<position.size(); i++)
        
        cv::rectangle(imageMat, position[i], cv::Scalar(255,255,0), 3);
        NSLog(@"Found %d rects", position.size());
 //   NSLog(@"Found %@ rects", static_cast<void>(position));

    
    // Convert back to UIImage
    return MatToUIImage(imageMat);
}

+(NSArray<UIImage *>*) getProcessedImage : (UIImage*) image
{
    if(!detector.isDetectorReady())
    {
        NSString *cascadePath = [[NSBundle mainBundle]
                                 pathForResource:@"cascadeHAAR"
                                 ofType:@"xml"];
        const CFIndex CASCADE_NAME_LEN = 2048;
        char *CASCADE_NAME = (char *) malloc(CASCADE_NAME_LEN);
        CFStringGetFileSystemRepresentation( (CFStringRef)cascadePath,
                                            CASCADE_NAME,
                                            CASCADE_NAME_LEN);
        // Cannot find cascadeHAAR.xml
        if(!detector.open(CASCADE_NAME))
        {
            NSLog(@"Detector not found!");
            free(CASCADE_NAME);
            return NULL;
        }
        free(CASCADE_NAME);
    }
    // Transform UIImage to cv::Mat
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    
    // OBJECT DETECTION
    // The position of every found object is stored on "position" vector of Rectangles
    // The number of found objects can be accessed using "position.size"
    std::vector< cv::Rect > position;
    //detector.detect(frame, position);             // Just detection
    detector.detectAndTrack(imageMat, position);    // Detection and tracking (faster!)
    
    // Draw rect
    
    
    
    
    NSMutableArray *images = [NSMutableArray new];
    UIImage *tempImage = MatToUIImage(imageMat);
    
    
    for(int i=0; i<position.size(); i++) {
        
        CGImageRef imageRef = CGImageCreateWithImageInRect(tempImage.CGImage, CGRectMake(position[i].x , position[i].y, position[i].width, position[i].height));
    
        UIImage *cropped = [UIImage imageWithCGImage:imageRef];
        [images addObject:cropped];
        CGImageRelease(imageRef);
    }
    
    return images;
        
       // cv::rectangle(imageMat, position[i], cv::Scalar(255,255,0), 3);
  //  NSLog(@"Found %d rects", position.size());
    //   NSLog(@"Found %@ rects", static_cast<void>(position));
    
    
    // Convert back to UIImage
   // return MatToUIImage(imageMat);
}

@end
