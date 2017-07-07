//
//  Hazard.swift
//  BetterRoad
//
//  Created by grace xia on 2017/7/7.
//  Copyright © 2017年 sjtuepcc. All rights reserved.
//
//  this class serves as hazard position
//  can be marked on the map

import UIKit
import CoreLocation
import MapKit

class Hazard: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var latitude: Double
    var longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double, title: String) {
        
        self.latitude = latitude
        self.longitude = longitude
        self.title = title
    }
    
    init(latitude: Double, longitude: Double, title: String, subtitle: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.title = title
        self.subtitle = subtitle
    }
    
    func getSubtitle(location: CLLocation) -> String{
        let geocoder: CLGeocoder = CLGeocoder()
        var subtitle = ""
        geocoder.reverseGeocodeLocation(location) {(placemark, error) -> Void in
            if (error == nil) {
                //转换成功，解析获取到的各个信息
                let array = placemark! as NSArray
                let mark = array.firstObject as! CLPlacemark
                
                let city: String = (mark.addressDictionary! as NSDictionary).value(forKey: "City") as! String
                let sublocality = (mark.addressDictionary! as NSDictionary).value(forKey: "SubLocality") as! String
                subtitle = city + sublocality + mark.thoroughfare! + mark.subThoroughfare!
                
            }else {
                //转换失败
                print("[nisak report] translate failed")
            }
        }
        return subtitle
    }
}
