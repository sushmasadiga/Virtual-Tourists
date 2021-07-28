//
//  AnnotationPinView.swift
//  Virtual Tourists
//
//  Created by Sushma Adiga on 28/07/21.
//

import Foundation
import MapKit

class AnnotationPinView: MKPointAnnotation {
    var pin: Pin

    init(pin: Pin){
        self.pin = pin
        super.init()
        self.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
    }
}
