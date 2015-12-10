//
//  MapVC.swift
//  Smart Citizen
//
//  Created by Mustafa Hastürk on 03/12/15.
//  Copyright © 2015 Mustafa Hastürk. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManaer = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManaer.delegate = self
        self.locationManaer.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManaer.requestWhenInUseAuthorization()
        self.locationManaer.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude: CLLocationDegrees = location.coordinate.latitude
            let longitude: CLLocationDegrees = location.coordinate.longitude
            let latitudeDelta: CLLocationDegrees = 0.009
            let longitudeDelta: CLLocationDegrees = 0.009
            let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            let span: MKCoordinateSpan = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
            self.mapView.setRegion(region, animated: true)
            
            let annotation: MKPointAnnotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Sorun Burada"
            annotation.subtitle = "Detayları burada görebilirsin"
            self.mapView.addAnnotation(annotation)
        }
        else {
            print("Konum alınamadı")
        }
        self.locationManaer.stopUpdatingLocation()
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
