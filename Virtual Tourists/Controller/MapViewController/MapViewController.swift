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
    
    var mapPins: [Pin] = []
    
    fileprivate let locationManager: CLLocationManager = CLLocationManager()
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var annotations = [Pin]()
    let managedObjectContext =
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setCenter()
        
        let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
        longPress.addTarget(self, action: #selector(recognizeLongPress(_ :)))
        mapView.addGestureRecognizer(longPress)
        longPress.minimumPressDuration = 0.5
        addPins()
    }
    
    
    func saveContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func addPins() {
       
        let fetchRequest: NSFetchRequest = Pin.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: managedObjectContext,sectionNameKeyPath: nil,cacheName: nil)
        do {
            try fetchedResultsController.performFetch()
            guard let pins = fetchedResultsController.fetchedObjects else {
                print("no pins found")
                return
            }
            self.mapPins = pins
            
            for pin in pins {
                let annotation = MKPointAnnotation()
                annotation.coordinate = pin.coordinate
                mapView.addAnnotation(annotation)
            }
        } catch {
            return
        }
    }
    
    
    fileprivate func setCenter() {
        let defaults = UserDefaults.standard
        defaults.set(12.9716, forKey: "Lat")
        defaults.set(77.5946, forKey: "Lon")
        let center = CLLocationCoordinate2DMake(defaults.double(forKey: "Lat"), defaults.double(forKey: "Lon"))
        mapView.setCenter(center, animated: true)
        let mySpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        let myRegion: MKCoordinateRegion = MKCoordinateRegion(center: center, span: mySpan)
        mapView.region = myRegion
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    @objc private func recognizeLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let location = sender.location(in: mapView)
            let myCoordinate: CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)
            let myPin: MKPointAnnotation = MKPointAnnotation()
            myPin.coordinate = myCoordinate
            myPin.title = "Photos"
            mapView.addAnnotation(myPin)
//            let pin = Pin(context: managedObjectContext)
//            pin.coordinate = myCoordinate
//            mapPins.append(pin)
        }
        else  {
            return
        }
        saveContext()
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



