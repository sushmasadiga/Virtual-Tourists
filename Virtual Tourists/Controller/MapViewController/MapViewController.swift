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

class MapViewController: UIViewController, UIGestureRecognizerDelegate, CLLocationManagerDelegate {
    
    var Pins: [Pin] = []
    fileprivate let locationManager: CLLocationManager = CLLocationManager()
    let manager = CLLocationManager()
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var annotations = [Pin]()
    var savedPins = [MKPointAnnotation]()
    var latitude = 0.0
    var longitude = 0.0
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    fileprivate func setUpFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
            longPress.addTarget(self, action: #selector(recognizeLongPress(_ :)))
            mapView.addGestureRecognizer(longPress)
            longPress.minimumPressDuration = 0.3
        
        setCenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            manager.stopUpdatingLocation()
            render(location)
        }
    }
    
    func render(_ location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}



