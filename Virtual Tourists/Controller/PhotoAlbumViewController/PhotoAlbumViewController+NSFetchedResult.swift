//
//  PhotoAlbumViewController+NSFetchedResult.swift
//  Virtual Tourists
//
//  Created by Sushma Adiga on 30/07/21.
//

import Foundation
import UIKit
import CoreData

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
            break
        case .update:
            collectionView.reloadItems(at: [indexPath!])
            break
        case .move:
            collectionView.moveItem(at: indexPath!, to: newIndexPath!)
            break
         default: ()
        }
        }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: collectionView.insertSections(indexSet)
        case .delete: collectionView.deleteSections(indexSet)
        case .update, .move:
            break
         default: ()
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    }

