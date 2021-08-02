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
    
            vc.currentLatitude = selectedPin.coordinate.latitude
            vc.currentLongitude = selectedPin.coordinate.longitude
        
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




