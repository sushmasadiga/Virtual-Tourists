//
//  MapViewController+Extension.swift
//  Virtual Tourists
//
//  Created by Sushma Adiga on 27/07/21.
//

import Foundation
import CoreData
import MapKit

extension MapViewController: MKMapViewDelegate {
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }
            let reuseId = "pinView"
            var pinView: MKPinAnnotationView
            
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView {
                pinView = annotationView
            } else {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            }
            
            pinView.canShowCallout = true
            pinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            pinView.annotation = annotation
            return pinView
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            
            let vc = storyboard?.instantiateViewController(identifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
            let locationLat = view.annotation?.coordinate.latitude
            let locationLon = view.annotation?.coordinate.longitude
            let myCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: locationLat!, longitude: locationLon!)
            let selectedPin: MKPointAnnotation = MKPointAnnotation()
            selectedPin.coordinate = myCoordinate
            
            for pin in annotations {
                if pin.latitude == selectedPin.coordinate.latitude &&
                    pin.longitude == selectedPin.coordinate.longitude {
                    vc.pin = pin
                }
                vc.currentLatitude = pin.latitude
                vc.currentLongitude = pin.longitude
            }
            navigationController?.pushViewController(vc, animated: true)
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            
            
            let selectedAnnotation = view.annotation as? MKPointAnnotation
            
            for pin in annotations {
                if pin.latitude == selectedAnnotation?.coordinate.latitude &&
                    pin.longitude == selectedAnnotation?.coordinate.longitude {
                   
                    DataController.shared.viewContext.delete(pin)
                    DataController.shared.save()
                }
            }
        }
}


extension MapViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            let pin = controller.object(at: newIndexPath!) as! Pin
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            mapView.addAnnotation(annotation)
            print("pin inserted")
            break
        default:
            break
        }
    }
}

extension MKMapView {
    
    func isInteractionEnabled(_ enabled: Bool) {
        isScrollEnabled = enabled
    }
    
    func addPinAnnotation(pin: Pin){
        addAnnotation(AnnotationPinView(pin: pin))
    }
    
    func clearAnnotations(){
        removeAnnotations(annotations)
    }
}
 
 
 
