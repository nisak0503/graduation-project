//
//  Annotation.h
//  RoadDetector
//
//  Created by grace xia on 17/3/17.
//  Copyright (c) 2017年 nisak0503. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Annotation : NSObject<MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * subtitle;

@end
