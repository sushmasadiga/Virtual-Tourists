//
//  PhotoCell.swift
//  Virtual Tourists
//
//  Created by Sushma Adiga on 27/07/21.
//

import Foundation
import UIKit
import CoreData

class PhotoCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    public static let reuseId = "photoCell"
    var id: UUID? = nil
    var photo: Photo!
    
    func initWithPhoto(_ photo: Photo) {
        
        if photo.imageData != nil {
            
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: photo.imageData! as Data)
            }
        } else {
            downloadImage(photo)
        }
    }
    
    func downloadImage(_ photo: Photo) {
        
        URLSession.shared.dataTask(with: URL(string: photo.imageURL!)!) { (data, response, error) in
            
            if error == nil {
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data! as Data)
                    self.saveImageDataToCoreData(photo, imageData: data! as Data)
                }
            }
        }
        .resume()
    }
    
    func saveImageDataToCoreData(_ photo: Photo, imageData: Data) {
        
        do {
            photo.imageData = imageData
            try DataController.shared.viewContext.save()
        } catch {
            print("saving photoimage failed")
        }
    }
}


