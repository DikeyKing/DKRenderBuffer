//
//  DKBuffer.m
//  InsightSDK
//
//  Created by Dikey on 2018/8/9.
//  Copyright © 2018 DikeyKing. All rights reserved.
//

#import "DKBuffer.h"
#import "DKEAGLContext.h"
#import <OpenGLES/ES2/glext.h>

static const CGFloat kWidth = 320.0*2;
static const CGFloat kHeight = 568.0*2;

@implementation DKBuffer

- (instancetype)initWithContext:(EAGLContext *)context
{
    self = [super init];
    if (self) {
        _context = context;
        [EAGLContext setCurrentContext:_context];
        _frameBuffer = [[DKFrameBuffer alloc] initWithContext:_context withSize:CGSizeMake(kWidth, kHeight)];
        CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, _frameBuffer.target, &_formatDescription);
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _context = [DKEAGLContext newContext:kEAGLRenderingAPIOpenGLES2];
        [EAGLContext setCurrentContext:_context];
        _frameBuffer = [[DKFrameBuffer alloc] initWithContext:_context withSize:CGSizeMake(kWidth, kHeight)];
        CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, _frameBuffer.target, &_formatDescription);
    }
    return self;
}

- (void)startDrawing
{
//    if ([EAGLContext currentContext] != _context) {
//    }
    [EAGLContext setCurrentContext:_context];

    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer.frameBuffer);
//    glClearColor(1, 1, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, kWidth, kHeight);
    
    // Code with OpenGL
}

- (void)finishDrawing
{
    glFlush();
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    //     Now the frame already wrote into "_frameBuffer.target"
}

- (CVPixelBufferRef )getPixelBuffer
{    
    return _frameBuffer.target;
}

@end
