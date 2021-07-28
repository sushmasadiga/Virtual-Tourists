//
//  Pin.swift
//  Virtual Tourists
//
//  Created by Sushma Adiga on 28/07/21.
//

import Foundation
import CoreData
import MapKit

class Pin: NSManagedObject {

    var coordinate: CLLocationCoordinate2D {
        get {
            return .init(latitude: latitude, longitude: longitude)
        }
        set {
            latitude = Double()
            longitude = Double()
        }
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
