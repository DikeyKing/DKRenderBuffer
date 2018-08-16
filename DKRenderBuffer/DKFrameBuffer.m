//
//  DKFrameBuffer.m
//
//  Created by Dikey on 2018/8/16.
//  Copyright © 2018 Dikey. All rights reserved.
//

#import "DKFrameBuffer.h"
#import <UIKit/UIKit.h>

@interface DKFrameBuffer()
{
    CGSize _renderSize;
    EAGLContext *_context;
    GLuint _depthbuffer;
    CVOpenGLESTextureCacheRef _textureCache;
    CVOpenGLESTextureRef _texture;
}
@end

@implementation DKFrameBuffer

- (instancetype)initWithContext:(EAGLContext *)ctx withSize:(CGSize)size
{
    self = [super init];
    if (self) {
        _renderSize = size;
        _context = ctx;
        
        [self setup];
    }
    return self;
}

- (void)dealloc {
    [self destory];
}

- (void)setup {
    [EAGLContext setCurrentContext:_context];
    
    [self createCVBufferWithSize:_renderSize withRenderTarget:&_target withTextureOut:&_texture];
    glBindTexture(CVOpenGLESTextureGetTarget(_texture), CVOpenGLESTextureGetName(_texture));
    
    // Set up filter and wrap modes for this texture object
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
#if ESSENTIAL_GL_PRACTICES_IOS
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
#else
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
#endif
    
    // Allocate a texture image with which we can render to
    // Pass NULL for the data parameter since we don't need to load image data.
    //     We will be generating the image by rendering to this texture
    glTexImage2D(GL_TEXTURE_2D,
                 0, GL_RGBA,
                 _renderSize.width, _renderSize.height,
                 0, GL_RGBA,
                 GL_UNSIGNED_BYTE, NULL);
    
    glGenRenderbuffers(1, &_depthbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _renderSize.width, _renderSize.height);
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, CVOpenGLESTextureGetName(_texture), 0);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthbuffer);
    
    if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
}

- (void)destory {
    [EAGLContext setCurrentContext:_context];
    
    if (_frameBuffer > 0) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    
    if (_depthbuffer > 0) {
        glDeleteRenderbuffers(1, &_depthbuffer);
        _depthbuffer = 0;
    }
    
    if (_target) {
        CFRelease(_target);
    }
    
    if (_textureCache) {
        CFRelease(_textureCache);
    }
    
    if (_texture) {
        CFRelease(_texture);
    }
}

- (void)createCVBufferWithSize:(CGSize)size
              withRenderTarget:(CVPixelBufferRef *)target
                withTextureOut:(CVOpenGLESTextureRef *)texture
{
    
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _context, NULL, &_textureCache);
    
    if (err) return;
    
    CFDictionaryRef empty; // empty value for attr value.
    CFMutableDictionaryRef attrs;
    empty = CFDictionaryCreate(kCFAllocatorDefault, // our empty IOSurface properties dictionary
                               NULL,
                               NULL,
                               0,
                               &kCFTypeDictionaryKeyCallBacks,
                               &kCFTypeDictionaryValueCallBacks);
    attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1,
                                      &kCFTypeDictionaryKeyCallBacks,
                                      &kCFTypeDictionaryValueCallBacks);
    
    CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
    CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height,
                        kCVPixelFormatType_32BGRA, attrs, target);
    
    CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                 _textureCache,
                                                 *target,
                                                 NULL, // texture attributes
                                                 GL_TEXTURE_2D,
                                                 GL_RGBA, // opengl format
                                                 size.width,
                                                 size.height,
                                                 GL_BGRA, // native iOS format
                                                 GL_UNSIGNED_BYTE,
                                                 0,
                                                 texture);
    
    CFRelease(empty);
    CFRelease(attrs);
}

@end
