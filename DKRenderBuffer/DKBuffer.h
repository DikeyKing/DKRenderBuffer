//
//  DKBuffer.h
//  InsightSDK
//
//  Created by Dikey on 2018/8/9.
//  Copyright © 2018 DikeyKing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DKFrameBuffer.h"
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

@interface DKBuffer : NSObject
{
    EAGLContext *_context;
    CMVideoFormatDescriptionRef _formatDescription;
}

@property (nonatomic, strong) DKFrameBuffer *frameBuffer;

- (void)startDrawing;
- (void)finishDrawing;
- (CVPixelBufferRef )getPixelBuffer;
- (instancetype)initWithContext:(EAGLContext *)context;

@end

