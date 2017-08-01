//
//  MapViewController.swift
//  Weather Stations
//
//  Created by Abdullah Alradadi on 7/30/17.
//  Copyright © 2017 Abdullah Alradadi. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 30000
    var bottomListVC: BottomListViewController!
    let APIKEY = "a75da485666047dd"
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let initialLocation = CLLocation(latitude: 36.4389980909964, longitude: -121.239995164339)
        centerMapOnLocation(location: initialLocation)
    }
    
    
    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        if (sender.state != UIGestureRecognizerState.began){
            return
        }
        let location = sender.location(in: mapView)
        let coords = mapView.convert(location, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coords
        annotation.title = " "
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        let url = URL(string:"http://api.wunderground.com/api/a75da485666047dd/geolookup/geolookup/q/\(coords.latitude),\(coords.longitude).json")
        let task = URLSession.shared.dataTask(with: url!,
        completionHandler: { (data, response, error) in
            if error != nil {
                self.createAlert(msg: "No internet connection.")
            }
            else {
                var dict = self.parseJson(json: data!)
                let temp = (dict?["location"]?["nearby_weather_stations"] as? [String:AnyObject])?["pws"]?["station"]
                var stations = [[String:AnyObject]]()
                if (temp != nil){
                    stations = temp as! [[String:AnyObject]]
                }
                if (stations.count == 0){
                    self.createAlert(msg: "No stations around.")
                    return
                }
                annotation.title = dict?["location"]?["city"] as! String + ", " + (dict?["location"]?["state"] as! String)
                self.addStations(stations: stations)
                DispatchQueue.main.async(){
                    self.addBottomListView(stations: stations)
                }
                
            }
        })
        task.resume()
        
    }
    
    func addStations(stations: [[String:AnyObject]]){
        var station: [String: AnyObject]
        var coords: CLLocationCoordinate2D
        var annotation: MKPointAnnotation
        let sorted = stations.sorted(by: {
            ($0["distance_km"] as! Int) < ($1["distance_km"] as! Int)
        })
        if(stations.count == 0){
            return
        }
        for i in 0...stations.count{
            if(i == 5) {
                break
            }
            station = sorted[i]
            coords =  CLLocationCoordinate2D(latitude: (station["lat"] as! Double), longitude: (station["lon"] as! Double))
            annotation = MKPointAnnotation()
            annotation.coordinate = coords
            annotation.title = station["neighborhood"] as! String
            mapView.addAnnotation(annotation)
        }
    }
    
    func parseJson(json: Data) -> [String: AnyObject]?{
        do{
            let dict = try JSONSerialization.jsonObject(with: json, options: [])
            return dict as! [String : AnyObject]
        }
        catch{
            return nil
        }
    }
    
    func addBottomListView(stations: [[String:AnyObject]]) {
        let sortedStations = stations.sorted(by:{
            ($0["neighborhood"] as! String) < ($1["neighborhood"] as! String)
        })
        if (bottomListVC != nil){
            bottomListVC.hideList()
            bottomListVC.updateTable(data: sortedStations)
            return
        }
        bottomListVC = BottomListViewController()
        self.addChildViewController(bottomListVC)
        self.view.addSubview(bottomListVC.view)
        bottomListVC.didMove(toParentViewController: self)
        let height = view.frame.height
        let width  = view.frame.width
        bottomListVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
        bottomListVC.updateTable(data: sortedStations)
    }
    
    func createAlert(msg: String){
        let alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

