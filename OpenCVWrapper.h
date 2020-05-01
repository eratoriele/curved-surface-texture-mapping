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

- (int) test: (int)x y: (int)y;

- (NSArray *) test2: (int)x y: (int)y;

- (NSString *) test3: (int)x y: (int)y image: (CVPixelBufferRef)image;


@end


NS_ASSUME_NONNULL_END
