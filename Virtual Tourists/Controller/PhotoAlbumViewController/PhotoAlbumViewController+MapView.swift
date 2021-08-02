//
//  PhotoAlbumViewController+NSFetchedResultDelegate.swift
//  Virtual Tourists
//
//  Created by Sushma Adiga on 28/07/21.
//


import Foundation
import MapKit

extension PhotoAlbumViewController: MKMapViewDelegate {
    
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
    
    func setMapCenter() {
        let defaults = UserDefaults.standard
        defaults.set(currentLatitude, forKey: "Lat")
        defaults.set(currentLongitude, forKey: "Lon")
        let center = CLLocationCoordinate2DMake(defaults.double(forKey: "Lat"), defaults.double(forKey: "Lon"))
        mapView.setCenter(center, animated: true)
        let mySpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        let myRegion: MKCoordinateRegion = MKCoordinateRegion(center: center, span: mySpan)
        mapView.region = myRegion
    }
    
}

