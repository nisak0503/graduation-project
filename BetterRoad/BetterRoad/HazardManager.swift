//
//  HazardManager.swift
//  BetterRoad
//
//  Created by grace xia on 2017/7/7.
//  Copyright © 2017年 sjtuepcc. All rights reserved.
//

import UIKit

class HazardManager: NSObject{
    var data:NSArray?
    var annotations : [Hazard] = []
    var loadedHazards : Bool = false
    
    func loadHazards(){
        //        if(self.loadedHazards == true){
        //            return
        //        }
        if let path = Bundle.main.path(forResource: "annotations", ofType: "plist") {
            data = NSArray(contentsOfFile: path)
        }
        else{
            print("[BetterRoad] file open failed")
        }
        if let items = data {
            var i = 0
            for item in items {
                i = i + 1
                let lat = (item as! NSDictionary).value(forKey: "lat") as! Double
                let long = (item as! NSDictionary).value(forKey: "long")as! Double
                let t = (item as! NSDictionary).value(forKey: "title") as! String
                let annotation = Hazard(latitude: lat, longitude: long, title: t, subtitle: "\(i)" )
                self.annotations.append(annotation)
            }
        }
    }
}
