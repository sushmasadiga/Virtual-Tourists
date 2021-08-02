//
//  PhotoCoredata.swift
//  Virtual Tourists
//
//  Created by Sushma Adiga on 02/08/21.
//

import Foundation
import CoreData
import UIKit

extension PhotoAlbumViewController  {
    
   func setupPhoto() {
        
        assert(collectionView != nil, "collection view is nil")
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        let coreDataPhotos = fetchedResultsController?.fetchedObjects
        if let coreDataPhotos = coreDataPhotos, !coreDataPhotos.isEmpty {
            
            activityIndicator.stopAnimating()
            
            for (indx, photo) in coreDataPhotos.enumerated() {
                
                guard let uiImage = photo.imageData.map(UIImage.init(data:)) as? UIImage
                else {
                    continue
                }
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell",
                                                              for: IndexPath(row: indx, section: 1)) as! PhotoCell
                cell.configure()
                cell.imageView.image = uiImage
                cell.id = photo.id
                collectionViewCells.append(cell)
                collectionView.reloadData()
            }
            return
        }
    }
}



