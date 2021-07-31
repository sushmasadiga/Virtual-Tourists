//
//  PhotoAlbumViewController+CollectionView.swift
//  Virtual Tourists
//
//  Created by Sushma Adiga on 28/07/21.
//

import Foundation
import UIKit

extension PhotoAlbumViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedPhotoObjects.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        let photoObject = savedPhotoObjects[indexPath.row]
        
        activityIndicator.stopAnimating()
        cell.initWithPhoto(photoObject)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / numberOfColumns
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        if cell?.isSelected == true {
            cell?.layer.borderColor = UIColor.blue.cgColor
            cell?.layer.borderWidth = 3
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.clear.cgColor
        cell?.layer.borderWidth = 3
        cell?.isSelected = false
    }
    
    func showAlertMessage() {
        let alertVc = UIAlertController(title: "Error", message: "Error retrieving data", preferredStyle: .alert)
        alertVc.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertVc, animated: true)
    }
    
}

