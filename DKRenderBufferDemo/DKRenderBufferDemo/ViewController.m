//
//  ViewController.m
//  DKRenderBufferDemo
//
//  Created by Dikey on 2018/8/16.
//  Copyright © 2018 Dikey. All rights reserved.
//

#import "ViewController.h"
#import "DKFaceRenderBuffer.h"
#import "DKBuffer.h"

@interface ViewController ()

@property (nonatomic, strong) DKFaceRenderBuffer *renderBuffer;
@property (nonatomic, strong) DKBuffer *buffer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    _buffer = [DKBuffer new];
//    [_buffer startDrawing];
//
//    //gl Draw code
//
//    [_buffer finishDrawing];
//    CVPixelBufferRef pixelBuffer = [_buffer getPixelBuffer];
    
    _renderBuffer = [DKFaceRenderBuffer new];
    
    //gl Draw code
    [_renderBuffer display];
    CVPixelBufferRef pixelBuffer = [_renderBuffer renderTargetBuffer];
    NSLog(@"pixelBuffer is %@",pixelBuffer);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
