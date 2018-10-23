//
//  OpenCVWrapper.h
//  FrameExtraction
//
//  Created by Sheila Gonzalez on 17/10/18.
//  Copyright © 2018 GIMME360. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

+(UIImage *) testProcess : (UIImage*) image;
+(UIImage *) processImage : (UIImage*) image;
+(NSArray<UIImage *>*) getProcessedImage : (UIImage*) image;

@end

NS_ASSUME_NONNULL_END
