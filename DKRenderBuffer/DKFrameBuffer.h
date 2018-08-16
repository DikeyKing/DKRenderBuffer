//
//  DKFrameBuffer.h
//
//  Created by Dikey on 2018/8/16.
//  Copyright © 2018 Dikey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/glext.h>
#import <CoreVideo/CoreVideo.h>

@interface DKFrameBuffer : NSObject

@property (nonatomic) GLuint frameBuffer;
@property (nonatomic, readonly) CVPixelBufferRef target;

- (instancetype)initWithContext:(EAGLContext *)ctx withSize:(CGSize)size;

@end
