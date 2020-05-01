//
//  OpenCVWrapper.m
//  getframeralitykit
//
//  Created by macos on 29.04.2020.
//  Copyright © 2020 macos. All rights reserved.
//

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>
#endif

#import "OpenCVWrapper.h"

@implementation OpenCVWrapper

- (int) test: (int)x y: (int)y {
    return x;
}

- (NSArray *) test2: (int)x y: (int)y {
    
    printf("%d, %d", x, y);
    
    return @[@'x', @'y'];
    
}

- (NSString *) test3: (int)x y: (int)y image: (CVPixelBufferRef) image {
     
    // convert CVPixelBufferRef to cv::Mat to be used in OpenCV functions
    cv::Mat img;

    CVPixelBufferLockBaseAddress(image, 0);

    void *address = CVPixelBufferGetBaseAddress(image);
    int width = (int) CVPixelBufferGetWidth(image);
    int height = (int) CVPixelBufferGetHeight(image);

    img = cv::Mat(height, width, CV_8U, address, 0);

    CVPixelBufferUnlockBaseAddress(image, 0);
    
    // Mat that stores edge image
    cv::Mat edges;
    cv::Canny(img, edges, 150, 200);
    
    // Vector that stores the line values
    std::vector<cv::Vec4i> lines;
    cv::HoughLinesP(edges, lines, 1, CV_PI / 180, 80, 395, 125);
    
    NSString *returnstr = @"";
    
    // Turn the line values into a string that can be transferred to swift side
    for(size_t i = 0; i < lines.size(); i++)
    {
        NSString *linePoints = [NSString stringWithFormat: @"%@_%@_%@_%@_",
                                [NSString stringWithFormat:@"%d", lines[i][0]],
                                [NSString stringWithFormat:@"%d", lines[i][1]],
                                [NSString stringWithFormat:@"%d", lines[i][2]],
                                [NSString stringWithFormat:@"%d", lines[i][3]]];
        
        returnstr = [NSString stringWithFormat: @"%@%@", returnstr, linePoints];
        
    }
    
    // Return the lines
    return returnstr;
    
}
        
             
@end

