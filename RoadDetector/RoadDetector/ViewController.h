//
//  ViewController.h
//  RoadDetector
//
//  Created by grace xia on 17/3/17.
//  Copyright (c) 2017年 nisak0503. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface ViewController : UIViewController
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, assign) CGPoint *virtualBall;
@end

