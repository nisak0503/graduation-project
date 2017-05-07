//
//  ViewController.m
//  RoadDetector
//
//  Created by grace xia on 17/3/17.
//  Copyright (c) 2017年 nisak0503. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Annotation.h"
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()<MKMapViewDelegate>{
    CLLocationManager * _locationManager;
    MKMapView * _mapView;
    CMMotionManager * _motionManager;
    NSString *accFilePath;
    NSString *gyroFilePath;
    NSFileHandle *accFileHandle;
    NSFileHandle *gyroFileHandle;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    accFilePath = @"acc_data.in";
    gyroFilePath = @"gyro_data.in";
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    [self updateFile: accFilePath using: fileManager];
    [self updateFile: gyroFilePath using: fileManager];
    accFileHandle = [NSFileHandle fileHandleForWritingAtPath:accFilePath];
    gyroFileHandle = [NSFileHandle fileHandleForWritingAtPath:gyroFilePath];
    
    // Do any additional setup after loading the view, typically from a nib.
    [self initGUI];
}

#pragma mark
- (void) updateFile :(NSString *)filePath using:(NSFileManager *)fileManager{
    if([fileManager fileExistsAtPath:filePath])
    {
        [fileManager removeItemAtPath:filePath error:nil];
    }
    BOOL isYes = [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    NSLog(@"create file %@: %d", filePath, isYes);
}
- (void)initGUI{
    CGRect rect = [UIScreen mainScreen].bounds;
    _mapView = [[MKMapView alloc]initWithFrame:rect];
    [self.view addSubview:_mapView];
    
    //设置代理
    _mapView.delegate = self;
    
    //请求定位服务
    _locationManager = [[CLLocationManager alloc]init];
    if(![CLLocationManager locationServicesEnabled] ||
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse){
        NSLog(@"locationManager turning on \n\n\n\n");
        [_locationManager requestWhenInUseAuthorization];
        NSLog(@"locationManager lat:%f\n", _locationManager.location.coordinate.latitude);
        NSLog(@"locationManager long:%f\n", _locationManager.location.coordinate.longitude);
    }

    //用户位置追踪（标记用户当前位置，此时会调用定位服务）
    _mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
    
    //设置地图类型
    _mapView.mapType = MKMapTypeStandard;
    //_mapView.mapType = MKMapTypeSatellite;
    
    //大头针
    //[self addAnnotation];
    [self initMotionManager];
    
}


#pragma mark

-(void) initMotionManager
{
    
    _motionManager = [[CMMotionManager alloc] init];
    if([_motionManager isAccelerometerAvailable])
    {
        [_motionManager setAccelerometerUpdateInterval:1 / 60.0];
        //NSLog(@"~~~");
        [_motionManager startAccelerometerUpdatesToQueue:NSOperationQueue.mainQueue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            if(error)
            {
                [_motionManager stopAccelerometerUpdates];
                NSLog(@"error occurs in Accelerometer");
            }
            else
            {
                
                //NSLog(@"~~~");
                double x = accelerometerData.acceleration.x;
                double y = accelerometerData.acceleration.y;
                double z = accelerometerData.acceleration.z;
            
                NSLog(@"update acc location: %f and %f and %f \n", x, y, z);
                [accFileHandle seekToEndOfFile];
                /*
                NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                NSString *str = @"update location:".a "dsfa";
                str += @" sadc ";
                NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
                [accFileHandle writeData:data];
                [accFileHandle closeFile];
                 */
            }
        }];
        
    }
    else
    {
        NSLog(@"Acceleometer unavailable");
    }
    
    if([_motionManager isGyroAvailable])
    {
        [_motionManager setAccelerometerUpdateInterval:1 / 60.0];
        [_motionManager startGyroUpdatesToQueue:NSOperationQueue.mainQueue withHandler:^(CMGyroData * gyroData, NSError * error) {
            if(error)
            {
                [_motionManager stopGyroUpdates];
                NSLog(@"error occurs in Gyro");
            }
            else
            {
                double x = gyroData.rotationRate.x;
                double y = gyroData.rotationRate.y;
                double z = gyroData.rotationRate.z;
                
                NSLog(@"update gyro location: %f and %f and %f \n", x, y, z);
            }
        }];
    }
}

-(void)addAnnotation{
    CLLocationCoordinate2D location1 = CLLocationCoordinate2DMake(39.95, 116.35);
    Annotation *annotation1 = [[Annotation alloc]init];
    annotation1.title = @"Wuhan";
    annotation1.subtitle = @"A studio";
    annotation1.coordinate = location1;
    [_mapView addAnnotation:annotation1];
    
    CLLocationCoordinate2D location2 = CLLocationCoordinate2DMake(39.87, 116.35);
    Annotation *annotation2 = [[Annotation alloc]init];
    annotation2.title = @"Kaoru";
    annotation2.subtitle = @"home";
    annotation2.coordinate = location2;
    [_mapView addAnnotation:annotation2];
}

#pragma mark -
#pragma mark

-(void)mapView : (MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)
userLocation{
    CLLocationCoordinate2D newLocation = userLocation.coordinate;
    NSLog(@"update location: %f and %f \n\n\n", newLocation.longitude, newLocation.latitude);
    //[mapView setCenterCoordinate:userLocation.coordinate animated:YES];
    
    MKCoordinateRegion region;
    region.span = MKCoordinateSpanMake(0.002, 0.002);
    region.center = newLocation;
    [mapView setRegion:region animated:YES];
}

-(void)locationManager : (CLLocationManager *)manager didChangeAuthorizationStatus:
(CLAuthorizationStatus)status{
    switch (status){
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusDenied:
            if([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
                [_locationManager requestWhenInUseAuthorization];
            }
            break;
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
