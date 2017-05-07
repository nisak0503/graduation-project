//
//  ViewController.swift
//  BetterRoad
//
//  Created by grace xia on 2017/4/25.
//  Copyright © 2017年 sjtuepcc. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager:CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    @IBOutlet weak var mapView: MKMapView!

    func initMapView(){
        //mapView = MKMapView(frame:self.view.frame)
        //view.addSubview(mapView)
        mapView.mapType = .satellite
        mapView.showsScale = true
        mapView.showsTraffic = true
        mapView.showsBuildings = true
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading

    }
    
    func initLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        if(CLLocationManager.locationServicesEnabled())
        {
            locationManager.startUpdatingLocation()
            print("[nisak report] gps open for use")
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMapView()
        initLocationManager()
        
                // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    @IBOutlet weak var altitude: UILabel!

    @IBOutlet weak var longitude: UILabel!

    @IBOutlet weak var latitude: UILabel!
    
    func locationManager(_ manager:CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let currentLocation: CLLocation = locations.last!
        longitude.text = "longitude: \(currentLocation.coordinate.longitude)"
        latitude.text = "latitude: \(currentLocation.coordinate.latitude)"
        altitude.text = "altitude: \(currentLocation.altitude)"
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[nisak report] gps error \(error)")
    }
    
}

