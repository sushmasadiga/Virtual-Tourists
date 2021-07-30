//
//  ViewController.swift
//  Virtual Tourists
//
//  Created by Sushma Adiga on 27/07/21.
//


import UIKit
import MapKit
import CoreData
import CoreLocation

class MapViewController: UIViewController, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    fileprivate let locationManager: CLLocationManager = CLLocationManager()
    
    var annotations = [Pin]()
    var savedPins = [MKPointAnnotation]()
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var latitude: Double?
    var longitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setCenter()
        setUpFetchedResultsController()
        findCurrentLocation()
        let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
        longPress.addTarget(self, action: #selector(recognizeLongPress(_ :)))
        mapView.addGestureRecognizer(longPress)
    }
    
    fileprivate func setUpFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let result = try? DataController.shared.viewContext.fetch(fetchRequest) {annotations = result
            for annotation in annotations {
                let savePin = MKPointAnnotation()
                if let lat = CLLocationDegrees(exactly: annotation.latitude), let lon = CLLocationDegrees(exactly: annotation.longitude) {
                let coordinateLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    savePin.coordinate = coordinateLocation
                    savePin.title = "Photos"
                    savedPins.append(savePin)
                }
            }
            mapView.addAnnotations(savedPins)
        }
    }
    
    
    fileprivate func findCurrentLocation() {
        locationManager.delegate=self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let userLocation:CLLocation = locations[0]
            let latitude=userLocation.coordinate.latitude
            let longitude=userLocation.coordinate.longitude
            let latDelta:CLLocationDegrees=0.05
            let lonDelta:CLLocationDegrees=0.05
            let span=MKCoordinateSpan(latitudeDelta:latDelta, longitudeDelta:lonDelta)
            let location=CLLocationCoordinate2D(latitude:latitude,longitude:longitude)
            let region=MKCoordinateRegion(center:location,span:span)
            self.mapView.setRegion(region,animated:true)
        }
    
    fileprivate func setCenter() {
        let defaults = UserDefaults.standard
            defaults.set(37.7749, forKey: "Lat")
            defaults.set(-122.4194, forKey: "Lon")
        let center = CLLocationCoordinate2DMake(defaults.double(forKey: "Lat"), defaults.double(forKey: "Lon"))
            mapView.setCenter(center, animated: true)
        let mySpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        let myRegion: MKCoordinateRegion = MKCoordinateRegion(center: center, span: mySpan)
            mapView.region = myRegion
    }
    
    
    @objc private func recognizeLongPress(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == UIGestureRecognizer.State.began else {
            return
        }
        
        let location = sender.location(in: mapView)
        let myCoordinate: CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)
        let myPin: MKPointAnnotation = MKPointAnnotation()
            myPin.coordinate = myCoordinate
            myPin.title = "Photos"
            mapView.addAnnotation(myPin)
        let pin = Pin(context: DataController.shared.viewContext)
            pin.latitude = Double(myCoordinate.latitude)
            pin.longitude = Double(myCoordinate.longitude)
            annotations.append(pin)
        DataController.shared.save()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let photoAlbumVC = segue.destination as? PhotoAlbumViewController
        else {
            return
        }
        
        let pinAnnotation: AnnotationPinView = sender as! AnnotationPinView
        photoAlbumVC.pin = pinAnnotation.pin
    }
    
}
