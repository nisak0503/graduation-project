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

    
    /* func viewDidLoad
     * 一开始加载结束就做的事情
     * ViewController自带的函数
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化地图信息
        initMapView()
        //初始化定位信息
        initLocationManager()
        
        //locationEncode()
        
        /*
         *初始化目的地始发地文本框信息
         */
        initAddress()
        self.loadHazards()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    /* func initMapView
     * 初始化地图信息 的 主入口
     */
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
    
    @IBOutlet weak var mapView: MKMapView!

    var locationArray = [CLLocationCoordinate2D]()
    

    /*
     * 定位信息 成员变量的声明
     */
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
            print("[nisak report] gps open for use")
        }
    }
    
    /*
     * 目的地始发地文本框信息 成员变量的声明
     */
 
    @IBOutlet weak var fromAddress: UITextField!
    @IBOutlet weak var toAddress: UITextField!
    
    var fromAddressString: String = ""
    var toAddressString: String = ""
    var fromCoordinate = CLLocationCoordinate2D();
    var toCoordinate = CLLocationCoordinate2D();
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
    
    /* func locationEncode
     * 给定地址字符串，获得经纬度信息
     */
    
    func locationEncode(address:String, isFrom: Bool){
        print("trying to locate \(address)")
        //let annotation = Hazard(latitude: 0.0, longitude: 0.0, title: "")
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: {
            (placemarks:[CLPlacemark]?, error:Error?) -> Void in
            print("yes!!!!!!!!!")
            if error != nil {
                print("错误：\(error!.localizedDescription))")
          //      return annotation
            }
            if let p = placemarks?[0] {
                
                print("--------------- 经度：\(p.location!.coordinate.longitude)   "
                    + "纬度：\(p.location!.coordinate.latitude)")
                
                let annotation = Hazard(latitude: p.location!.coordinate.latitude, longitude: p.location!.coordinate.longitude, title: address)
                self.mapView.addAnnotation(annotation)
                
                let latDelta = 0.003
                let longDelta = 0.003
                let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
                let center:CLLocation = CLLocation(latitude: annotation.latitude, longitude: annotation.longitude)
                let currentRegion:MKCoordinateRegion = MKCoordinateRegion(center: center.coordinate, span: currentLocationSpan)
                
                //设置显示区域
                self.mapView.setRegion(currentRegion, animated: true)
                
                
                
                print("this is annotation: \(annotation.latitude)")
                
                //当前填写的是起始位置
                if(isFrom == true){
                    //if(self.changedFrom == false){
                        self.fromCoordinate = CLLocationCoordinate2D(latitude: annotation.latitude, longitude: annotation.longitude)
                        self.changedFrom = true
                    //}
                }
                //当前填写的是终点位置
                if(isFrom == false) {
                    //if(self.changedTo == false){
                        self.toCoordinate = CLLocationCoordinate2D(latitude: annotation.latitude, longitude: annotation.longitude)
                        self.changedTo = true
                    //}
                }
            //    return annotation
                
            } else {
                print("No placemarks!")
            //    return annotation
            }
        })
    }
    
    
    /* func tryToNavigate
     * 当用户按下Go时，开始尝试导航，去掉可能导致导航失败的情况
     */
    @IBAction func tryToNavigate(_ sender: UIButton) {
        
        print("\(fromAddressString) -----> \(toAddressString)")
        print("\(fromCoordinate)")
        print("\(toCoordinate)")

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
    
    
    
    
    /* func navigate
     *
     */
    func navigate(){
        print("qunqun -------- navigate \(fromCoordinate) to \(toCoordinate)")
        
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

    func sqr(num:Double)->Double{
        return num * num
    }

    func isOnRoute(point1: CLLocationCoordinate2D, point2: CLLocationCoordinate2D, hazard: Hazard) -> Bool{
        // between the two points
        let s = (hazard.latitude - point1.latitude) * ( point2.latitude - point1.latitude) + (hazard.longitude - point1.longitude)*(point2.longitude - point1.longitude)
        let m = sqrt(sqr(num: point1.latitude - point2.latitude) + sqr(num: point2.longitude - point1.longitude))
//        print("s = \(s)")
//        print("m = \(m) and m*m = \(m * m)")
//        print("s > m * m = \(s > m * m)")
        if(s < 0){
            return false
        }
        if(s  > m * m){
            
            return false
        }
        
        // in the distance
        let delta = 4.0 * 2
        
        let A = (point2.longitude - point1.longitude) * 100000
        let B = (point1.latitude - point2.latitude) * 111320
        let C = (point1.longitude * point2.latitude - point1.latitude * point2.longitude) * 111320 * 100000
        
        let son = A * hazard.latitude * 111320 + B * hazard.longitude * 100000 + C
        let mom = sqrt(A * A + B * B)
        let distance = abs(son / mom)
        print("distance = \(distance)")
        if(distance < delta){
            return true
        }
        else {
            return false
        }
    }
    
    func hazardCounts(routePoints: UnsafeMutablePointer<CLLocationCoordinate2D>, pointCount: Int) -> Int{
        var count = 0
        var flag: [Int] = []
        if(pointCount <= 1) {
            return count
        }
        
        var firstPoint = routePoints[0]
        
        for i in 1 ..< pointCount {
            print("hazardCounts function for \(self.annotations.count)")
            let lastPoint = routePoints[i]
            for j in 0 ..< self.annotations.count {
                let hazard = self.annotations[j]
                //print(hazard.coordinate.latitude)
                if(isOnRoute(point1: firstPoint, point2: lastPoint, hazard: hazard) == true) {
                    print("hazard \(j+1)th with place from \(i-1) to \(i)")
                    if(flag.contains(j)){
                        continue
                    }
                    print("count")
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
        
        //设置显示区域
        self.mapView.setRegion(currentRegion, animated: true)
        //self.mapView.setCenter(center, animated: true)
        
        minHaz = Int.max
        minRoute = MKRoute()
        routes = response.routes
        for r in 0 ..< response.routes.count{
            let route = response.routes[r]
        
            print("some routes! \(route.name)")
            print(route.polyline.coordinate)
            print("what the hell??")
            print(route.polyline)
            print("step = \(route.steps)")
            print("what the fuck?")
            // play by me

            print("the count is \(route.polyline.pointCount)")

            let count = route.polyline.pointCount
            
            var points: UnsafeMutablePointer<CLLocationCoordinate2D> = UnsafeMutablePointer.allocate(capacity: count)
            //let range = Range(uncheckedBounds: (0, count-1))
            //var nsrange = NSRange(range)
            //print("points init okay")
            route.polyline.getCoordinates(points, range: NSRange(location:0, length: count))
            //print("getCoordinates okay")
            let hazCount = hazardCounts(routePoints: points, pointCount: count)
            print("hazCount = \(hazCount)")
            if(minHaz > hazCount){
                minHaz = hazCount
                minRoute = route
            }
            
            
            for i in 0 ..< count {
                let coordinatePoint = points[i]
            //    print("the \(i) th coordinatePoint is \(coordinatePoint.latitude) and \(coordinatePoint.longitude)")
                
                let annotation = Hazard(latitude: coordinatePoint.latitude, longitude: coordinatePoint.longitude, title: "routePoint", subtitle: "\(i)")
                
       //         mapView.addAnnotation(annotation)
                
            }
            
            mapView.add(route.polyline, level: MKOverlayLevel.aboveLabels)
            
            let routeSeconds = route.expectedTravelTime
            
            let routeDistance = route.distance
            
            print("distance between two points is \(routeSeconds) and \(routeDistance)")
            
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
            
            //mapView.addAnnotation(annotation)
            
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
        
        let geocoder: CLGeocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation) {(placemark, error) -> Void in
            if (error == nil) {//转换成功，解析获取到的各个信息
                let array = placemark! as NSArray
                let mark = array.firstObject as! CLPlacemark
                
                let city: String = (mark.addressDictionary! as NSDictionary).value(forKey: "City") as! String
                //let country = (mark.addressDictionary! as NSDictionary).value(forKey: "Country") as! String
                //let state = (mark.addressDictionary! as NSDictionary).value(forKey: "State") as! String
                let sublocality = (mark.addressDictionary! as NSDictionary).value(forKey: "SubLocality") as! String
                self.location.text = "\(sublocality), \(city)"
                
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
                print("[nisak report] translate failed")
            }  
            
        }

    }
    
    
    func locationManager(_ manager:CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        //print("haha = \(locationArray)")
        let currentLocation: CLLocation = locations.last!
        locationArray.append(CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude))
        //不用实时更新出来
        /*
        drawPath()
        let annotation = Hazard(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, title: "currentMove")

        mapView.addAnnotation(annotation)
        */
        
        longitude.text = "longitude: \(currentLocation.coordinate.longitude) E"
        latitude.text = "latitude: \(currentLocation.coordinate.latitude) N"
        altitude.text = "altitude: \(currentLocation.altitude) m"
        getLocationLabel(currentLocation: currentLocation)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[nisak report] gps error \(error)")
    }
    

    var routeCount = 0

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        print("rendererForOverlay----------------------")
        self.routeCount = self.routeCount + 1
        print("the route number is \(self.routeCount)")
        let pr = MKPolylineRenderer()
        if (isViewLoaded) {
            if (overlay is MKPolyline) {
                print("overlay is MKPolyline")
                let pr = MKPolylineRenderer(overlay: overlay)
                switch routeCount % 3{
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
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        // 使用 MKAnnotationView自定义大头针        
//        let identifier = "pin"
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//        if annotationView == nil {
//            print("???!!!!!!!!!!!!!!!!!!!!!!!!!!")
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//        }
//        annotationView?.annotation = annotation// 重要
//        annotationView?.image = UIImage(named: "sb.jpeg")// 设置打头针的图片
//        annotationView?.centerOffset = CGPoint(x: 0, y: 0)// 设置大头针中心偏移量        
//        annotationView?.canShowCallout = true// 设置弹框        
//        annotationView?.calloutOffset = CGPoint(x: 10, y: 0)// 设置弹框的偏移量                
//        annotationView?.isDraggable = true// 设置大头针可以拖动
//        return annotationView
//    }

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)
        -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            
            let reuserId = "pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuserId)
                as? MKPinAnnotationView
            if pinView == nil {
                //创建一个大头针视图
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuserId)
                pinView?.canShowCallout = true
                //pinView?.animatesDrop = true
                //设置大头针颜色
              
                if (annotation.title! == "hazard"){
                    //print("12323412354235555555555555555555  \("hazard" == "21323")")
                    pinView?.pinTintColor = UIColor.orange
                }
                else if (annotation.title! == "routePoint"){
                    //print("adsfgadgdfgdfgdasvdfbfdhrwgvfbfdhrst")
                    pinView?.pinTintColor = UIColor.red
                }
                
                //设置大头针点击注释视图的右侧按钮样式
                pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }else{
                if (annotation.title! == "hazard"){
                    //print("12323412354235555555555555555555  \("hazard" == "21323")")
                    pinView?.pinTintColor = UIColor.orange
                }
                else if (annotation.title! == "routePoint"){
                    //print("adsfgadgdfgdfgdasvdfbfdhrwgvfbfdhrst")
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
        
        
//        let currentLocation = locationArray[locationArray.count - 1]
//        mapView.setCenter(currentLocation, animated: true)
    }
    
    var data:NSArray?
    var annotations : [Hazard] = []
    
    var loadedHazards : Bool = false
    
    func loadHazards(){
        if(self.loadedHazards == true){
            return
        }
        
        if let path = Bundle.main.path(forResource: "annotations", ofType: "plist") {
            data = NSArray(contentsOfFile: path)
        }
        else{
            print("没打开吗？")
        }
        //iterate and create annotations
        if let items = data {
            var i = 0
            for item in items {
                i = i + 1
                print("\(item)")
                //                let lat = item.valueForKey("fadf")
                //
                let lat = (item as! NSDictionary).value(forKey: "lat") as! Double
                let long = (item as! NSDictionary).value(forKey: "long")as! Double
                let t = (item as! NSDictionary).value(forKey: "title") as! String
                
                let annotation = Hazard(latitude: lat, longitude: long, title: t, subtitle: "\(i)" )
                
                self.annotations.append(annotation)
            }
        }
    }
    
    @IBAction func uploadAnnotations(_ sender: Any) {
        print("[nisak report] start uploading annotations")
        

        loadHazards()
        
        mapView.addAnnotations(self.annotations)
        
    }
    

    
    
    
}




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
        
        //let location = CLLocation(latitude: self.latitude, longitude: self.longitude)
        //self.subtitle = self.getSubtitle(location: location)
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
            if (error == nil) {//转换成功，解析获取到的各个信息
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
