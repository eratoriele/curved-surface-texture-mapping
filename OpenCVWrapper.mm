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
#import <opencv2/core.hpp>
#endif

#import "OpenCVWrapper.h"

@implementation OpenCVWrapper

- (NSString *) test: (int)x y: (int)y
                    cannyFirstThreshold: (double)cannyFirstThreshold
                    cannySecondThreshold: (double)cannySecondThreshold
                    houghThreshold: (double)houghThreshold
                    houghMinLength: (double)houghMinLength
                    houghMaxGap: (double)houghMaxGap
                    image: (CVPixelBufferRef)image
                    lineMap: (bool)lineMap {
     
    // convert CVPixelBufferRef to cv::Mat to be used in OpenCV functions
    cv::Mat img;

    CVPixelBufferLockBaseAddress(image, 0);

    void *address = CVPixelBufferGetBaseAddress(image);
    int width = (int) CVPixelBufferGetWidth(image);
    int height = (int) CVPixelBufferGetHeight(image);

    img = cv::Mat(height, width, CV_8U, address, 0);

    CVPixelBufferUnlockBaseAddress(image, 0);
    
    cv::rotate(img, img, cv::ROTATE_90_CLOCKWISE);
    
    // Mat that stores edge image
    cv::Mat edges;
    cv::Canny(img, edges, cannyFirstThreshold, cannySecondThreshold);
    
    // Vector that stores the line values
    std::vector<cv::Vec4i> lines;
    cv::HoughLinesP(edges, lines, 1, CV_PI / 360, houghThreshold, houghMinLength, houghMaxGap);
    
    std::vector<int> linesonleft;
    std::vector<int> linesonright;
    
    // categorize the lines as on the left and on the right
    for(size_t i = 0; i < lines.size(); i++) {
        // [0] -> x1, [1] -> y1, [2] -> x2, [3] -> y2
        // Finding lines to the left of the point
        
        // formula of line is: y = slope1 * x + c1
        int diffx = lines[i][2] - lines[i][0];
        int diffy = lines[i][3] - lines[i][1];
        int slope1;
        // if diffx == 0, then the line is parallel to the y axis
        // and the formula changes to x = c1
        // first, solve the rest with formula y = slope1 * x + c1
        if (diffx != 0) {
            slope1 = diffy / diffx;
            int c1 = lines[i][1] - slope1 * lines[i][0];
            
            // The line we are looking for is from found point to all the way left
            // with slope of 0. so: y = point.y
            
            // if they  are not parallel
            if (slope1 != 0) {
                int foundx = (y - c1) / slope1;
                
                if ((foundx > lines[i][0] and foundx < lines[i][2]) or
                    (foundx > lines[i][2] and foundx < lines[i][0])) {
                    
                    if (foundx < x) {
                        linesonleft.push_back(lines[i][0]);
                        linesonleft.push_back(lines[i][1]);
                        linesonleft.push_back(lines[i][2]);
                        linesonleft.push_back(lines[i][3]);
                        linesonleft.push_back(slope1);
                        linesonleft.push_back(foundx);
                        linesonleft.push_back(slope1 * foundx + c1);
                        continue;
                    }
                    else {
                        linesonright.push_back(lines[i][0]);
                        linesonright.push_back(lines[i][1]);
                        linesonright.push_back(lines[i][2]);
                        linesonright.push_back(lines[i][3]);
                        linesonright.push_back(slope1);
                        linesonright.push_back(foundx);
                        linesonright.push_back(slope1 * foundx + c1);
                        continue;
                    }
                }
            }
        }
        // Bother with lines parallel to y axis last
        else {
            // if line is parallel to y, it is definetely a line that
            // either belongs to left or right of the found line
            // only restraint is:
            if ((y >= lines[i][1] and y <= lines[i][3]) or
                (y >= lines[i][3] and y <= lines[i][1])) {
                // if this is true, than they are defineletly crossing
                // now, to find if it is either on left or right
                if (x > lines[i][0]) {
                    linesonleft.push_back(lines[i][0]);
                    linesonleft.push_back(lines[i][1]);
                    linesonleft.push_back(lines[i][2]);
                    linesonleft.push_back(lines[i][3]);
                    linesonleft.push_back(INT_MAX);
                    linesonleft.push_back(lines[i][0]);
                    linesonleft.push_back(y);
                    continue;
                }
                else {
                    linesonright.push_back(lines[i][0]);
                    linesonright.push_back(lines[i][1]);
                    linesonright.push_back(lines[i][2]);
                    linesonright.push_back(lines[i][3]);
                    linesonright.push_back(INT_MAX);
                    linesonright.push_back(lines[i][0]);
                    linesonright.push_back(y);
                    continue;
                }
            }
        }
            
    }
    
    // find two lines, one on rightone on left, that have the same slope

    int distance = height * 2;
    int line1x1 = 0;
    int line1y1 = 0;
    int line1x2 = 0;
    int line1y2 = 0;
    int line2x1 = 0;
    int line2y1 = 0;
    int line2x2 = 0;
    int line2y2 = 0;
    int leftLineIntersectionx = 0;
    int leftLineIntersectiony = 0;
    int rightLineIntersectionx = 0;
    int rightLineIntersectiony = 0;

    for (size_t i = 0; i < linesonleft.size() / 7; i++) {
        for (size_t j = 0; j < linesonright.size() / 7; j++) {
        
            // If the slopes are close enough
            int slopeDiff = abs(abs(linesonleft[i*7 + 4]) - abs(linesonright[j*7 + 4]));
            if (slopeDiff < abs(linesonleft[i*7 + 4]) * 2 / 3 or
                slopeDiff < abs(linesonright[j*7 + 4]) * 2 / 3) {
            
                // If the line is the closest
                int far1x = linesonright[j*7] - linesonleft[i*7];
                int far1y = linesonright[j*7 + 1] - linesonleft[i*7 + 1];
                int far1 = pow((far1x * far1x + far1y * far1y), 0.5);
                int far2x = linesonright[j*7 + 2] - linesonleft[i*7 + 2];
                int far2y = linesonright[j*7 + 3] - linesonleft[i*7 + 3];
                int far2 = pow((far2x * far2x + far2y * far2y), 0.5);
                
                int far = far1 + far2;
                
                if (far < distance) {
                    // Record the lines as the closest to the point
                    distance = far;
                    line1x1 = linesonleft[i*7];
                    line1y1 = linesonleft[i*7 + 1];
                    line1x2 = linesonleft[i*7 + 2];
                    line1y2 = linesonleft[i*7 + 3];
                    leftLineIntersectionx = linesonleft[i*7 + 5];
                    leftLineIntersectiony = linesonleft[i*7 + 6];
                    line2x1 = linesonright[j*7];
                    line2y1 = linesonright[j*7 + 1];
                    line2x2 = linesonright[j*7 + 2];
                    line2y2 = linesonright[j*7 + 3];
                    rightLineIntersectionx = linesonright[i*7 + 5];
                    rightLineIntersectiony = linesonright[i*7 + 6];
                }
            }
        }
    }
    
    NSString *returnstr = @"";
    
    // Send the points for texture
    if (lineMap) {
        returnstr = [NSString stringWithFormat: @"%@_%@_%@_%@_%@_%@_%@_%@_%@_%@_%@_%@",
                    [NSString stringWithFormat:@"%d", line1x1],
                    [NSString stringWithFormat:@"%d", line1y1],
                    [NSString stringWithFormat:@"%d", line1x2],
                    [NSString stringWithFormat:@"%d", line1y2],
                    [NSString stringWithFormat:@"%d", line2x1],
                    [NSString stringWithFormat:@"%d", line2y1],
                    [NSString stringWithFormat:@"%d", line2x2],
                    [NSString stringWithFormat:@"%d", line2y2],
                    [NSString stringWithFormat:@"%d", leftLineIntersectionx],
                    [NSString stringWithFormat:@"%d", leftLineIntersectiony],
                    [NSString stringWithFormat:@"%d", rightLineIntersectionx],
                    [NSString stringWithFormat:@"%d", rightLineIntersectiony]];
    }
    // Send all the lines
    else {
        for(size_t i = 0; i < lines.size(); i++) {
            returnstr = [NSString stringWithFormat: @"%@_%@_%@_%@_%@_",
                        returnstr,
                        [NSString stringWithFormat:@"%d", lines[i][0]],
                        [NSString stringWithFormat:@"%d", lines[i][1]],
                        [NSString stringWithFormat:@"%d", lines[i][2]],
                        [NSString stringWithFormat:@"%d", lines[i][3]]];
        }
    }
    
    // Return the lines
    return returnstr;
    
}
        
             
@end

