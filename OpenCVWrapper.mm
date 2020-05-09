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

- (NSString *) test: (int)x y: (int)y
                    cannyFirstThreshold: (double)cannyFirstThreshold
                    cannySecondThreshold: (double)cannySecondThreshold
                    houghThreshold: (double)houghThreshold
                    houghMinLength: (double)houghMinLength
                    houghMaxGap: (double)houghMaxGap
                    image: (CVPixelBufferRef)image {
     
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
    cv::Canny(img, edges, cannyFirstThreshold, cannySecondThreshold);
    
    // Vector that stores the line values
    std::vector<cv::Vec4i> lines;
    cv::HoughLinesP(edges, lines, 2.6, CV_PI / 180, houghThreshold, houghMinLength, houghMaxGap);
    
    std::vector<int> linesonleft;
    std::vector<int> linesonright;
    
    // categorize the lines as on the left and on the right
    for(size_t i = 0; i < lines.size(); i++) {
        // Finding lines to the left of the point
        
        // Line x1y1 x2y2 represented as a1x + b1y = c1
        int a1 = lines[i][3] - lines[i][1];
        int b1 = lines[i][0] - lines[i][2];
        int c1 = a1 * (lines[i][0]) + b1 * (lines[i][1]);
        
        // Line found point to edge of screen represented as a2x + b2y = c2
        int a2 = 0;
        int b2 = x;
        int c2 = b2 * (y);
        
        int determinant = a1*b2 - a2*b1;
        
        // if they  are not parallel
        if (determinant != 0) {
            int foundx = (b2*c1 - b1*c2) / determinant;
            
            if (foundx < x and foundx > 0) {
                linesonleft.push_back(lines[i][0]);
                linesonleft.push_back(lines[i][1]);
                linesonleft.push_back(lines[i][2]);
                linesonleft.push_back(lines[i][3]);
                linesonleft.push_back(-1 * a1 / b1);
                continue;
            }
        }
        
        // Finding lines to the right of the point
        
        // x1y1 x2y2 line already calculated
        // Line found point to edge of screen represented as a2x + b2y = c2
        a2 = 0;
        b2 = x - height;
        c2 = a2 * (x) + b2 * (y);
        
        determinant = a1*b2 - a2*b1;
        
        // if they  are not parallel
        if (determinant != 0) {
            int foundx = (b2*c1 - b1*c2) / determinant;
            
            if (foundx > x and foundx < height){
                linesonright.push_back(lines[i][0]);
                linesonright.push_back(lines[i][1]);
                linesonright.push_back(lines[i][2]);
                linesonright.push_back(lines[i][3]);
                linesonright.push_back(-1 * a1 / b1);
            }
        }
            
    }
    
    // find two lines, one on rightone on left, that have the same slope

    int distance = height;
    int line1x1 = 0;
    int line1y1 = 0;
    int line1x2 = 0;
    int line1y2 = 0;
    int line2x1 = 0;
    int line2y1 = 0;
    int line2x2 = 0;
    int line2y2 = 0;

    for (size_t i = 0; i < linesonleft.size() / 5; i++) {
        for (size_t j = 0; j < linesonright.size() / 5; j++) {
        
            // If the slopes are the same
            if (linesonleft[i*5 + 4] == linesonright[j*5 + 4]) {
            
                // If the line is the closest
                int far = abs(linesonleft[i*5] - linesonright[j*5]);
                if (far < distance) {
                    // Record the lines as the closest to the point
                    distance = far;
                    line1x1 = linesonleft[i*5];
                    line1y1 = linesonleft[i*5 + 1];
                    line1x2 = linesonleft[i*5 + 2];
                    line1y2 = linesonleft[i*5 + 3];
                    line2x1 = linesonright[j*5];
                    line2y1 = linesonright[j*5 + 1];
                    line2x2 = linesonright[j*5 + 2];
                    line2y2 = linesonright[j*5 + 3];
                }
            }
        }
    }
    
    NSString *returnstr = [NSString stringWithFormat: @"%@_%@_%@_%@_%@_%@_%@_%@",
                            [NSString stringWithFormat:@"%d", line1x1],
                            [NSString stringWithFormat:@"%d", line1y1],
                            [NSString stringWithFormat:@"%d", line1x2],
                            [NSString stringWithFormat:@"%d", line1y2],
                            [NSString stringWithFormat:@"%d", line2x1],
                            [NSString stringWithFormat:@"%d", line2y1],
                            [NSString stringWithFormat:@"%d", line2x2],
                            [NSString stringWithFormat:@"%d", line2y2]];
    
                            
    // Return the lines
    return returnstr;
    
}
        
             
@end

