//
//  Photo.swift
//  Virtual Tourists
//
//  Created by Sushma Adiga on 28/07/21.
//

import Foundation
import CoreData
import UIKit

class Photo: NSManagedObject {
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
        id = UUID()
        
    }
    
}
