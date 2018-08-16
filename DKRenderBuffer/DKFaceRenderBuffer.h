//
//  DKFaceRenderBuffer.h
//
//  Created by Dikey on 2018/6/11.
//  Copyright © 2018 Dikey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/glext.h>
#import <UIKit/UIKit.h>

typedef CVImageBufferRef CVPixelBufferRef;

@interface DKFaceRenderBuffer : NSObject

@property (nonatomic, assign) GLuint frameBuffer;  //输出 framebuffer //glES
@property (nonatomic, assign) CVPixelBufferRef renderTargetBuffer;

/**
 需要设置当前上下文：
 1、创建frameBuffer时候
 2、process frameBuffer时候
 3、更改、创建Mesh时候
 */
@property (nonatomic, strong) EAGLContext *eaglContext;

- (instancetype)initWithContext:(EAGLContext *)context;

- (void)setCurrentEAGLContext;
- (void)display;
- (UIView *)getPreview;

@end
