//
// DKEAGLContext.h
//
//  Created by Dikey on 2018/8/9.
//  Copyright © 2018 DikeyKing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>

@interface DKEAGLContext : NSObject

+ (EAGLContext*)newContext: (EAGLRenderingAPI) api;

@end
