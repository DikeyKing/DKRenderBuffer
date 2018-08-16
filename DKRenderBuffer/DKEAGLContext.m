#import <GLKit/GLKit.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreMedia/CoreMedia.h>

@interface DKEAGLContext : NSObject

+ (EAGLContext*)sharedContext;
+ (EAGLContext*)newContext: (EAGLRenderingAPI) api;

@end

@implementation DKEAGLContext

+ (EAGLContext*)sharedContext {
    
    static EAGLContext *srEAGLContext = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        srEAGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    });
    return srEAGLContext;
}

+ (EAGLContext*)newContext: (EAGLRenderingAPI) api
{
    EAGLSharegroup *sharegroup = [[DKEAGLContext sharedContext] sharegroup];
    return [[EAGLContext alloc] initWithAPI:api sharegroup:sharegroup];
}

@end
