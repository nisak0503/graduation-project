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

@interface ViewController ()<MKMapViewDelegate>{
    CLLocationManager * _locationManager;
    MKMapView * _mapView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initGUI];
}

#pragma mark
- (void)initGUI{
    CGRect rect = [UIScreen mainScreen].bounds;
    _mapView = [[MKMapView alloc]initWithFrame:rect];
    [self.view addSubview:_mapView];
    
    _mapView.delegate = self;

    _locationManager = [[CLLocationManager alloc]init];
    if(![CLLocationManager locationServicesEnabled] ||
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse){
        [_locationManager requestWhenInUseAuthorization];
    }

    _mapView.userTrackingMode = MKUserTrackingModeFollow;
    
    _mapView.mapType = MKMapTypeStandard;
    
    [self addAnnotation];
}

#pragma mark
-(void)addAnnotation{
    CLLocationCoordinate2D location1 = CLLocationCoordinate2DMake(39.95, 116.35);
    Annotation *annotation1 = [[Annotation alloc]init];
    annotation1.title = @"Beijing";
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
    NSLog(@"%@", userLocation);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
