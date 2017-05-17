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

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate {

    let locationManager:CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    @IBOutlet weak var mapView: MKMapView!


    
    var locationArray = [CLLocationCoordinate2D]()
    
    func initMapView(){
        
        
        //mapView = MKMapView(frame:self.view.frame)
        //view.addSubview(mapView)
        
        mapView.delegate = self
        mapView.mapType = .satellite
        //mapView.mapType = .standard
        mapView.showsScale = true
        mapView.showsTraffic = true
        mapView.showsBuildings = true
        mapView.showsUserLocation = true
        mapView.showsPointsOfInterest = true
        mapView.userTrackingMode = .followWithHeading
        mapView.isRotateEnabled = false
        
        
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

 
    @IBOutlet weak var fromAddress: UITextField!
    
    
    @IBOutlet weak var toAddress: UITextField!
    
    
    func initAddress(){
        fromAddress.placeholder = "from address"
        toAddress.placeholder = "to address"
        fromAddress.adjustsFontSizeToFitWidth = true
        toAddress.adjustsFontSizeToFitWidth = true
        fromAddress.clearButtonMode = .whileEditing
        toAddress.clearButtonMode = .whileEditing
        fromAddress.returnKeyType = .done
        toAddress.returnKeyType = .done
        fromAddress.delegate = self
        toAddress.delegate = self
        
    }
    
    var fromAddressString: String = ""
    var toAddressString: String = ""
    var fromCoordinate = CLLocationCoordinate2D();
    var toCoordinate = CLLocationCoordinate2D();
    var changedFrom = false
    var changedTo = false
    func textFieldShouldReturn(_ address: UITextField) -> Bool {
        //收起键盘
        address.resignFirstResponder()
        
        //打印出文本框中的值
        if(address.restorationIdentifier == "fromAddress"){
            fromAddressString = address.text!
            print("fromAddress: \(self.fromAddressString)")
            print("toAddress: \(self.toAddressString)")
            
            locationEncode(address: fromAddress.text!, isFrom: true)
        }
        if(address.restorationIdentifier == "toAddress"){
            toAddressString = address.text!
            print("toAddress: \(self.toAddressString)")
            print("fromAddress: \(self.fromAddressString)")
            
            locationEncode(address: toAddress.text!, isFrom: false)
        }
        
        //ifNavigateBegins()
        return true;
    }
    
    @IBAction func tryToNavigate(_ sender: UIButton) {
        print("\(fromAddressString) -----> \(toAddressString)")
        print("\(fromCoordinate)")
        print("\(toCoordinate)")
        print("我能怎么办，我也很绝望呀  ~\(fromAddressString)~\(toAddressString)~")
        if(fromAddressString == "") {
            return
        }
        if(toAddressString == "") {
            return
        }
        if(toCoordinate.latitude < 1) {
            return
        }
        if(fromCoordinate.latitude < 1) {
            return
        }
        navigate()
    }
    
    func navigate(){
        print("qunqun -------- navigate \(fromCoordinate) to \(toCoordinate)")
        
        let fromPlaceMark = MKPlacemark(coordinate: fromCoordinate, addressDictionary: nil)
        let toPlaceMark = MKPlacemark(coordinate: toCoordinate, addressDictionary: nil)
        let fromItem = MKMapItem(placemark: fromPlaceMark)
        let toItem = MKMapItem(placemark: toPlaceMark)
        self.findDirectionsFrom(source: fromItem, destination: toItem)
    }
    
    func findDirectionsFrom(source:MKMapItem,destination:MKMapItem){
        
        let request = MKDirectionsRequest()
        request.source = source
        request.destination = destination
        request.transportType = MKDirectionsTransportType.automobile
        request.requestsAlternateRoutes = true;
        
        let directions = MKDirections(request: request)
        while(directions.isCalculating)
        {
            //等待
            print("[nisak report] wait")
        }

        directions.calculate { (response: MKDirectionsResponse?, error: Error?) in
            if error == nil {
                self.showRoute(response: response!)
            }else{
                print("[nisak report] track the error \(error?.localizedDescription)")
            }

        }
        
    }

    
    func showRoute(response:MKDirectionsResponse) {

        for route in response.routes {
            print("some routes! \(route.name)")
            print(route.polyline.coordinate)
        
            mapView.add(route.polyline, level: MKOverlayLevel.aboveLabels)
            
            let routeSeconds = route.expectedTravelTime
            
            let routeDistance = route.distance
            
            print("distance between two points is \(routeSeconds) and \(routeDistance)")
            
        }
        
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMapView()
        initLocationManager()
        //locationEncode()
        initAddress()
        self.fromAddressString = ""
        self.toAddressString = ""
                // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    @IBOutlet weak var altitude: UILabel!

    @IBOutlet weak var longitude: UILabel!

    @IBOutlet weak var latitude: UILabel!

    @IBOutlet weak var location: UILabel!
    
    func getLocationLabel(currentLocation: CLLocation){
        
        let geocoder: CLGeocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation) {(placemark, error) -> Void in
            if (error == nil) {//转换成功，解析获取到的各个信息
                let array = placemark! as NSArray
                let mark = array.firstObject as! CLPlacemark
                
                let city: String = (mark.addressDictionary! as NSDictionary).value(forKey: "City") as! String
                self.location.text = city
                
                //State = State.stringByReplacingOccurrencesOfString("省", withString: "")
                
                
                
                //                println(city)
                //            println(country)
                //            println(CountryCode)
                //            println(FormattedAddressLines)
                //            println(Name)
                //                println(State)
                //            println(SubLocality)
            }else {
                //转换失败 
           //     print("[nisak report] translate failed")
            }  
            
        }

    }
    
    func locationManager(_ manager:CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        //print("haha = \(locationArray)")
        let currentLocation: CLLocation = locations.last!
        locationArray.append(CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude))
        drawPath()
        let annotation = Hazard(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, title: "currentMove")

        mapView.addAnnotation(annotation)
        
        //print("aiai = \(currentLocation)")
        longitude.text = "longitude: \(currentLocation.coordinate.longitude)"
        latitude.text = "latitude: \(currentLocation.coordinate.latitude)"
        altitude.text = "altitude: \(currentLocation.altitude)"
        getLocationLabel(currentLocation: currentLocation)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[nisak report] gps error \(error)")
    }
    

//    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
//        if (overlay is MKPolyline) {
//            var pr = MKPolylineRenderer(overlay: overlay)
//            //pr.strokeColor = UIColor(colorLiteralRed: 0, green: 0, blue: 255, alpha: 0.5)
//            pr.strokeColor = UIColor.orange;
//            //pr.strokeColor = UIColor.colorWithRGBHex(0xff0000).colorWithAlphaComponent(0.5);
//            pr.lineWidth = 10;
//            return pr;
//        }
//        
//        return nil
//    }
    
//    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKPolyline!) -> MKOverlayRenderer! {
//        print("change pr color")
//        
//        var pr = MKPolylineRenderer(overlay: overlay);
//        pr.strokeColor = UIColor.black
//        pr.lineWidth = 10;
//        
//        return pr;
//        
//    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("rendererForOverlay----------------------")
        
        let pr = MKPolylineRenderer()
        if (overlay is MKPolyline) {
            print("overlay is MKPolyline")
            let pr = MKPolylineRenderer(overlay: overlay)
            pr.strokeColor = UIColor.blue
            pr.lineWidth = 5
            return pr
        }
        return pr
    }
    
    
    


    func drawPath(){
        
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        let polyline = MKPolyline(coordinates: locationArray, count: locationArray.count)
        mapView.add(polyline, level: .aboveRoads)
        //print("[nisak report] add polyline okay")
        
        
//        let currentLocation = locationArray[locationArray.count - 1]
//        mapView.setCenter(currentLocation, animated: true)
    }
    
    var data:NSArray?
    var annotations : [Hazard] = []
    @IBAction func uploadAnnotations(_ sender: Any) {
        print("[nisak report] start uploading annotations")
        

        if let path = Bundle.main.path(forResource: "annotations", ofType: "plist") {
            data = NSArray(contentsOfFile: path)
        }
        else{
            print("没打开吗？")
        }
                //iterate and create annotations
        if let items = data {
            for item in items {
                print("\(item)")
//                let lat = item.valueForKey("fadf")
//                
                let lat = (item as! NSDictionary).value(forKey: "lat") as! Double
                let long = (item as! NSDictionary).value(forKey: "long")as! Double
                let annotation = Hazard(latitude: lat, longitude: long, title: (item as! NSDictionary).value(forKey: "title") as! String)
                
                self.annotations.append(annotation)
            }
        }
        
        mapView.addAnnotations(self.annotations)
        
    }
    
    func locationEncode(address:String, isFrom: Bool){
        print("trying to locate \(address)")
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: {
            (placemarks:[CLPlacemark]?, error:Error?) -> Void in
            print("yes!!!!!!!!!")
            if error != nil {
                print("错误：\(error!.localizedDescription))")
                return
            }
            if let p = placemarks?[0] {
                
                print("--------------- 经度：\(p.location!.coordinate.longitude)   "
                    + "纬度：\(p.location!.coordinate.latitude)")
                
                let annotation = Hazard(latitude: p.location!.coordinate.latitude, longitude: p.location!.coordinate.longitude, title: address)
                self.mapView.addAnnotation(annotation)
                
                
                print("this is annotation: \(annotation.latitude)")
                if(isFrom == true){
                    if(self.changedFrom == false){
                        self.fromCoordinate = CLLocationCoordinate2D(latitude: annotation.latitude, longitude: annotation.longitude)
                        self.changedFrom = true
                    }
                }
                
                if(isFrom == false) {
                    if(self.changedTo == false){
                        self.toCoordinate = CLLocationCoordinate2D(latitude: annotation.latitude, longitude: annotation.longitude)
                        self.changedTo = true
                    }
                }
            } else {
                print("No placemarks!")
            }
        })
    }
    
    
    
}

class Hazard: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var latitude: Double
    var longitude:Double
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double, title: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.title = title
    }
}
