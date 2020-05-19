//
//  OpenCVWrapper.h
//  getframeralitykit
//
//  Created by macos on 29.04.2020.
//  Copyright © 2020 macos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

- (NSString *) getAllLines: (int)x y: (int)y
                            cannyFirstThreshold: (double)cannyFirstThreshold
                            cannySecondThreshold: (double)cannySecondThreshold
                            houghThreshold: (double)houghThreshold
                            houghMinLength: (double)houghMinLength
                            houghMaxGap: (double)houghMaxGap
                            image: (CVPixelBufferRef)image
                            lineMap: (bool)lineMap;

- (NSString *) getCylinderLines: (NSString *)lines;


@end


NS_ASSUME_NONNULL_END
