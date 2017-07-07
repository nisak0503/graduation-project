//
//  Task.swift
//  BetterRoad
//
//  Created by grace xia on 2017/7/7.
//  Copyright © 2017年 sjtuepcc. All rights reserved.
//
//  Task class help manage navigation tasks
//  Used to enable BetterRoad to retype the source or destination address
import MapKit


class Task: NSObject {
    var source: MKAnnotation
    var destination: MKAnnotation
    var routes: [MKRoute]
    
    var sourceHistory: Bool = false
    var destinationHistory: Bool = false
    init(source: MKAnnotation, destination: MKAnnotation){
        self.source = source
        self.destination = destination
        self.routes = [MKRoute]()
        sourceHistory = true
        destinationHistory = true
    }
    override init(){
        self.source = Hazard(latitude: 0.0, longitude: 0.0, title: "")
        self.destination = Hazard(latitude: 0.0, longitude: 0.0, title: "")
        self.routes = [MKRoute]()
    }
    func setRoutes(routes: [MKRoute])
    {
        self.routes = routes
    }
    func setSource(source: MKAnnotation)
    {
        self.source = source
        sourceHistory = true
    }
    func setDestination(destination: MKAnnotation)
    {
        self.destination = destination
        destinationHistory = true
    }
    
}
