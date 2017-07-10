//
//  NavigateViewController.swift
//  BetterRoad
//
//  Created by grace xia on 2017/5/8.
//  Copyright © 2017年 sjtuepcc. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class NavigateViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager:CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    func initMapView(){
        
        
        //mapView = MKMapView(frame:self.view.frame)
        //view.addSubview(mapView)
        
        
        mapView.mapType = .satellite
        mapView.showsScale = true
        mapView.showsTraffic = true
        mapView.showsBuildings = true
        mapView.showsUserLocation = true
        mapView.showsPointsOfInterest = true
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
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
