//
//  DKFaceRenderBuffer.m
//
//  Created by Dikey on 2018/6/11.
//  Copyright © 2018 Dikey. All rights reserved.
//

#import "DKFaceRenderBuffer.h"
#import <GLKit/GLKit.h>

@interface DKFaceRenderBuffer()
{
    CVOpenGLESTextureRef renderTargetTexture; //输出 texture //Core video <--> glES
    CVOpenGLESTextureCacheRef _textureCache; //管理纹理
    GLKView *_videoPreviewView;
    GLuint _depthbuffer;
    CGFloat _viewWidth;
    CGFloat _viewHeight;
}

@end

@implementation DKFaceRenderBuffer

- (instancetype)initWithContext:(EAGLContext *)context
                          width:(CGFloat)width
                         height:(CGFloat)height
{
    self = [super init];
    if (self) {
        _viewWidth = width;
        _viewHeight = height;
        _eaglContext = context;
        [self generateFramebuffer];
    }
    return self;
}

- (instancetype)initWithContext:(EAGLContext *)context
{
    _viewWidth = [UIScreen mainScreen].bounds.size.width;
    _viewHeight = [UIScreen mainScreen].bounds.size.height;
    return [self initWithContext:context width:[UIScreen mainScreen].bounds.size.width height:[UIScreen mainScreen].bounds.size.height];
}

- (instancetype)init
{
    return [self initWithContext:[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2]];
}

- (void)dealloc {
    [self destory];
}

- (void)destory {
    [EAGLContext setCurrentContext:_eaglContext];
    if (_frameBuffer > 0) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    if (_renderTargetBuffer) {
        CFRelease(_renderTargetBuffer);
    }
    if (_textureCache) {
        CFRelease(_textureCache);
    }
    if (renderTargetTexture) {
        CFRelease(renderTargetTexture);
    }
}

- (void)generateFramebuffer
{
    if (!_eaglContext) {
        _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    
    if ([EAGLContext currentContext] != _eaglContext) {
        [EAGLContext setCurrentContext:_eaglContext];
    }
    if (!_videoPreviewView) {
        _videoPreviewView = [[GLKView alloc] initWithFrame:CGRectMake(0, 0, _viewWidth, _viewHeight) context:_eaglContext];
        _videoPreviewView.enableSetNeedsDisplay = NO;
    }
    
    if (_frameBuffer) {
        return;
    }
    
    CGFloat scale = [UIScreen mainScreen].scale;

    //1. glGenFramebuffers -> GLuint
    glGenFramebuffers(1, &_frameBuffer);
    //2. glBindFramebuffer -> GLuint
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glGenRenderbuffers(1, &_depthbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _viewWidth*scale , _viewHeight*scale);

    CVReturn err = 0;
    
    //3. create CVOpenGLESTextureCacheRef with EAGLContext
    if (_textureCache == NULL) {
        err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _eaglContext, NULL, &_textureCache);
    }
    
    if (err) {
        NSLog(@"CVReturn is %d" ,err);
    }
    CFDictionaryRef empty; // empty value for attr value.
    CFMutableDictionaryRef attrs;
    empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks); // our empty IOSurface properties dictionary
    attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
    
    
    //4.  Creates a single pixel buffer (CVPixelBufferRef) for a given size and pixel format.
    err = CVPixelBufferCreate(kCFAllocatorDefault, _viewWidth *scale, _viewHeight*scale, kCVPixelFormatType_32BGRA, attrs, &_renderTargetBuffer);
    if (err){
        NSLog(@"CVReturn is %d" ,err);
    }
    
    //5. Mapping a BGRA buffer as a source texture: CVOpenGLESTextureRef
    err = CVOpenGLESTextureCacheCreateTextureFromImage (kCFAllocatorDefault,
                                                        _textureCache,
                                                        _renderTargetBuffer,
                                                        NULL, // texture attributes
                                                        GL_TEXTURE_2D,
                                                        GL_RGBA, // opengl format
                                                        _viewWidth*scale  ,
                                                        _viewHeight*scale ,
                                                        GL_BGRA, // native iOS format
                                                        GL_UNSIGNED_BYTE,
                                                        0,
                                                        &renderTargetTexture);
    if (err){
        NSAssert(NO, @"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
    
    CFRelease(attrs);
    CFRelease(empty);
    
    //6. glBindTexture , 之后在glES中绘制，即可以从DKFaceRenderBuffer CVPixelBufferRef 获取到绘制完成的结果
    glBindTexture(CVOpenGLESTextureGetTarget(renderTargetTexture), CVOpenGLESTextureGetName(renderTargetTexture));
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, CVOpenGLESTextureGetName(renderTargetTexture), 0);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthbuffer);

    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"Incomplete filter FBO: %d", status);
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)display
{
    [_videoPreviewView display];
}

- (UIView *)getPreview
{
    return _videoPreviewView;
}

- (void)setCurrentEAGLContext
{
    if ([EAGLContext currentContext] != _eaglContext) {
        [EAGLContext setCurrentContext:_eaglContext];
    }
}

@end
