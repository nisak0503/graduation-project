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

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate, UITextViewDelegate{

    var locationLabelUpdate:Bool = true
    var hazardManager:HazardManager = HazardManager()
    
    /* func viewDidLoad
     * 一开始加载结束就做的事情
     * ViewController自带的函数
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        initMapView()
        initLocationManager()
        //初始化目的地始发地文本框信息
        initAddress()
        hazardManager.loadHazards()
        locationLabelUpdate = true;
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    /* func initMapView
     * 初始化地图信息 的 主入口
     */
    func initMapView(){
        mapView.delegate = self
        mapView.mapType = .satellite
        mapView.showsScale = true
        mapView.showsTraffic = true
        mapView.showsBuildings = true
        mapView.showsUserLocation = true
        mapView.showsPointsOfInterest = true
        mapView.userTrackingMode = .followWithHeading
        mapView.isRotateEnabled = false
    }
    
    
    @IBOutlet weak var mapView: MKMapView!
    var locationArray = [CLLocationCoordinate2D]()
    let locationManager:CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    
    /* func initLocationManager
     * 初始化定位信息 的主入口
     */
    func initLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        if(CLLocationManager.locationServicesEnabled())
        {
            locationManager.startUpdatingLocation()
        }
    }
    
    
    /*
     * 目的地始发地文本框信息 成员变量的声明
     */
    @IBOutlet weak var fromAddress: UITextField!
    @IBOutlet weak var toAddress: UITextField!
    var fromAddressString: String = ""
    var toAddressString: String = ""
    var fromCoordinate = CLLocationCoordinate2D()
    var toCoordinate = CLLocationCoordinate2D()
    var changedFrom = false
    var changedTo = false
    
    
    /* func initAddress
     * 初始化目的地始发地文本框信息 的主入口
     */
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
        
        self.fromAddressString = ""
        self.toAddressString = ""
    }
    
    
    /* func textFieldShouldReturn
     * 在用户按下return键之后做的事情
     */
    func textFieldShouldReturn(_ address: UITextField) -> Bool {
        //收起键盘
        address.resignFirstResponder()
        //获取文本框中的地址值并转换为经纬度
        if(address.restorationIdentifier == "fromAddress"){
            fromAddressString = address.text!
            print("fromAddress: \(self.fromAddressString)")
            print("toAddress: \(self.toAddressString)")
            
            self.locationEncode(address: fromAddress.text!, isFrom: true)
        }
        if(address.restorationIdentifier == "toAddress"){
            toAddressString = address.text!
            print("toAddress: \(self.toAddressString)")
            print("fromAddress: \(self.fromAddressString)")
            
            self.locationEncode(address: toAddress.text!, isFrom: false)
        }
        return true;
    }
    
    
    var currentTask = Task()
    /* func locationEncode
     * 给定地址字符串，获得经纬度信息
     */
    func locationEncode(address:String, isFrom: Bool){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: {
            (placemarks:[CLPlacemark]?, error:Error?) -> Void in
            if error != nil {
                print("error：\(error!.localizedDescription))")
            }
            if let p = placemarks?[0] {
                let annotation = Hazard(latitude: p.location!.coordinate.latitude, longitude: p.location!.coordinate.longitude, title: address)
                if (isFrom == true){ //source
                    if(self.currentTask.sourceHistory){
                        self.mapView.removeAnnotation(self.currentTask.source)
                        // delete other routes
                        for r in 0..<self.currentTask.routes.count{
                            let route = self.currentTask.routes[r]
                            self.mapView.remove(route.polyline)
                        }
                    }
                    self.currentTask.setSource(source: annotation)
                }
                else
                {
                    if(self.currentTask.destinationHistory){
                        self.mapView.removeAnnotation(self.currentTask.destination)
                        // delete other routes
                        for r in 0..<self.currentTask.routes.count{
                            let route = self.currentTask.routes[r]
                            self.mapView.remove(route.polyline)
                        }
                    }
                    self.currentTask.setDestination(destination: annotation)
                }
                self.mapView.addAnnotation(annotation)
                let latDelta = 0.003
                let longDelta = 0.003
                let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
                let center:CLLocation = CLLocation(latitude: annotation.latitude, longitude: annotation.longitude)
                let currentRegion:MKCoordinateRegion = MKCoordinateRegion(center: center.coordinate, span: currentLocationSpan)
                self.mapView.setRegion(currentRegion, animated: true)
                self.locationLabelUpdate = true;
                self.getLocationLabel(currentLocation: center);
                self.locationLabelUpdate = false

                //当前填写的是起始位置
                if(isFrom == true){
                        self.fromCoordinate = CLLocationCoordinate2D(latitude: annotation.latitude, longitude: annotation.longitude)
                        self.changedFrom = true
                }
                //当前填写的是终点位置
                if(isFrom == false) {
                        self.toCoordinate = CLLocationCoordinate2D(latitude: annotation.latitude, longitude: annotation.longitude)
                        self.changedTo = true
                }
            } else {
                print("[BetterRoad] No placemarks!")
            }
        })
    }
    
    
    /* func tryToNavigate
     * 当用户按下Go时，开始尝试导航，去掉可能导致导航失败的情况
     */
    @IBAction func tryToNavigate(_ sender: UIButton) {
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
        let fromPlaceMark = MKPlacemark(coordinate: fromCoordinate, addressDictionary: nil)
        let toPlaceMark = MKPlacemark(coordinate: toCoordinate, addressDictionary: nil)
        let fromItem = MKMapItem(placemark: fromPlaceMark)
        let toItem = MKMapItem(placemark: toPlaceMark)
        self.routeCount = 0
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
            print("[BetterRoad] wait")
        }

        directions.calculate { (response: MKDirectionsResponse?, error: Error?) in
            if error == nil {
                self.showRoute(response: response!)
            }else{
                print("[BetterRoad] track the error \(error?.localizedDescription)")
            }

        }
        
    }

    
    func sqr(num:Double)->Double{
        return num * num
    }

    
    func isOnRoute(point1: CLLocationCoordinate2D, point2: CLLocationCoordinate2D, hazard: Hazard) -> Bool{
        // between the two points
        let s = (hazard.latitude - point1.latitude) * ( point2.latitude - point1.latitude) + (hazard.longitude - point1.longitude)*(point2.longitude - point1.longitude)
        let m = sqrt(sqr(num: point1.latitude - point2.latitude) + sqr(num: point2.longitude - point1.longitude))
        if(s < 0){
            return false
        }
        if(s  > m * m){
            return false
        }
        // delta为马路宽度阈值
        let delta = 4.0 * 2
        let A = (point2.longitude - point1.longitude) * 100000
        let B = (point1.latitude - point2.latitude) * 111320
        let C = (point1.longitude * point2.latitude - point1.latitude * point2.longitude) * 111320 * 100000
        let son = A * hazard.latitude * 111320 + B * hazard.longitude * 100000 + C
        let mom = sqrt(A * A + B * B)
        let distance = abs(son / mom)
        if(distance < delta){
            return true
        }
        else {
            return false
        }
    }
    
    
    func hazardCounts(routePoints: UnsafeMutablePointer<CLLocationCoordinate2D>, pointCount: Int) -> Int{
        var count = 0
        var flag: [Int] = [] //用于存储处理过的hazard序号，一个hazard可能在两个线段上，只能算一次
        if(pointCount <= 1) {
            return count
        }
        var firstPoint = routePoints[0]
        for i in 1 ..< pointCount {
            let lastPoint = routePoints[i]
            for j in 0 ..< self.hazardManager.annotations.count {
                let hazard = self.hazardManager.annotations[j]
                if(isOnRoute(point1: firstPoint, point2: lastPoint, hazard: hazard) == true) {
                    if(flag.contains(j)){
                        continue
                    }
                    flag.append(j)
                    count = count + 1
                }
            }
            firstPoint = lastPoint
        }
        return count
    }
 
    
    var minHaz = Int.max
    var minRoute = MKRoute()
    var routes: [MKRoute] = []
    var tasks: [Task] = []
    
    
    func showRoute(response:MKDirectionsResponse) {
        var maxDistance = 0.0
        for route in response.routes{
            if(route.distance as Double > maxDistance) {
                maxDistance = route.distance as Double
            }
        }
        let latDelta = maxDistance / 200000
        let longDelta = maxDistance / 200000
        let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let center = CLLocation(latitude:(fromCoordinate.latitude + toCoordinate.latitude)/2, longitude:(fromCoordinate.longitude + toCoordinate
            .longitude)/2)
        let currentRegion:MKCoordinateRegion = MKCoordinateRegion(center: center.coordinate, span: currentLocationSpan)
        self.mapView.setRegion(currentRegion, animated: true)
        self.locationLabelUpdate = true
        self.getLocationLabel(currentLocation: center)
        self.locationLabelUpdate = false
        minHaz = Int.max
        minRoute = MKRoute()
        routes = response.routes
        self.currentTask.setRoutes(routes: routes)
        
        for r in 0 ..< response.routes.count{
            let route = response.routes[r]
            let count = route.polyline.pointCount
            var points: UnsafeMutablePointer<CLLocationCoordinate2D> = UnsafeMutablePointer.allocate(capacity: count)
            route.polyline.getCoordinates(points, range: NSRange(location:0, length: count))
            let hazCount = hazardCounts(routePoints: points, pointCount: count)
            if(minHaz > hazCount){
                minHaz = hazCount
                minRoute = route
            }
            
            for i in 0 ..< count {
                let coordinatePoint = points[i]
                let annotation = Hazard(latitude: coordinatePoint.latitude, longitude: coordinatePoint.longitude, title: "routePoint", subtitle: "\(i)")
            }
            mapView.add(route.polyline, level: MKOverlayLevel.aboveLabels)
            let routeSeconds = route.expectedTravelTime
            let routeDistance = route.distance
        }
        
    }
    

    @IBAction func showBestRoad(_ sender: Any) {
        if(routes == []){
            return
        }
        let count = minRoute.polyline.pointCount
        var points: UnsafeMutablePointer<CLLocationCoordinate2D> = UnsafeMutablePointer.allocate(capacity: count)
        minRoute.polyline.getCoordinates(points, range: NSRange(location:0, length: count))
        for i in 0 ..< count {
            let coordinatePoint = points[i]
            let annotation = Hazard(latitude: coordinatePoint.latitude, longitude: coordinatePoint.longitude, title: "routePoint", subtitle: "\(i)")
        }
        mapView.add(minRoute.polyline, level: MKOverlayLevel.aboveLabels)
        for r in 0 ..< routes.count {
            let route = routes[r]
            if(route != minRoute){
                mapView.remove(route.polyline)
            }
        }
    }

    
    @IBOutlet weak var altitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var location: UILabel!
    
    func getLocationLabel(currentLocation: CLLocation){
        if(locationLabelUpdate == false)
        {
            return
        }
        let geocoder: CLGeocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation) {(placemark, error) -> Void in
            if (error == nil) {//成功，解析获取到的各个信息
                let array = placemark! as NSArray
                let mark = array.firstObject as! CLPlacemark
                let city: String = (mark.addressDictionary! as NSDictionary).value(forKey: "City") as! String
                let sublocality = (mark.addressDictionary! as NSDictionary).value(forKey: "SubLocality") as! String
                self.location.text = "\(sublocality), \(city)"
            }else {
                print("[BetterRoad] translate failed")
            }  
            
        }

    }
    
    
    func locationManager(_ manager:CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let currentLocation: CLLocation = locations.last!
        locationArray.append(CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude))
        longitude.text = "longitude: \(currentLocation.coordinate.longitude) E"
        latitude.text = "latitude: \(currentLocation.coordinate.latitude) N"
        altitude.text = "altitude: \(currentLocation.altitude) m"
        getLocationLabel(currentLocation: currentLocation)
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[BetterRoad] gps error \(error)")
    }
    var routeCount = 0
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        self.routeCount = self.routeCount + 1
        let pr = MKPolylineRenderer()
        if (isViewLoaded) {
            if (overlay is MKPolyline) {
                let pr = MKPolylineRenderer(overlay: overlay)
                switch routeCount % 3{  //3 colors
                    case 0: pr.strokeColor = UIColor.blue
                          break
                    case 1: pr.strokeColor = UIColor.green
                          break
                    case 2: pr.strokeColor = UIColor.red
                          break
                    default:
                        print("math error in route drawing")
                }
                //pr.strokeColor = UIColor.blue
                pr.lineWidth = 5
                return pr
            }
        }
        return pr
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)
        -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            let reuserId = "pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuserId)
                as? MKPinAnnotationView
            if pinView == nil {
                //创建大头针
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuserId)
                pinView?.canShowCallout = true
                if (annotation.title! == "hazard"){
                    pinView?.pinTintColor = UIColor.orange
                }
                else if (annotation.title! == "routePoint"){
                    pinView?.pinTintColor = UIColor.red
                }
                //大头针点击
                pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }else{
                if (annotation.title! == "hazard"){
                    pinView?.pinTintColor = UIColor.orange
                }
                else if (annotation.title! == "routePoint"){
                    pinView?.pinTintColor = UIColor.red
                }
                pinView?.annotation = annotation
            }
            return pinView
    }
    func drawPath(){
        
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        let polyline = MKPolyline(coordinates: locationArray, count: locationArray.count)
        mapView.add(polyline, level: .aboveRoads)
        print("[nisak report] add polyline okay")
    }
    /*
     * Once pressed ViewHazard button, envoke uploadAnnotations
     * load hazards information from annotations.plist
     * add hazards as annotations to the map
    */
    @IBAction func uploadAnnotations(_ sender: Any) {
        self.hazardManager.loadHazards()
        mapView.addAnnotations(self.hazardManager.annotations)
    }
}
