//
//  PhotoAlbumViewController.swift
//  Virtual Tourists
//
//  Created by Sushma Adiga on 28/07/21.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionsButton: UIButton!
    
    
    var pin: Pin!
    var currentLatitude: Double?
    var currentLongitude: Double?
    var savedPhotoObjects = [Photo]()
    var flickrPhotos: [FlickrPhoto] = []
    let numberOfColumns: CGFloat = 3
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let savedPhotos = reloadSavedData()
        if savedPhotos != nil && savedPhotos?.count != 0 {savedPhotoObjects = savedPhotos!
            showSavedResult()
        } else {
            showNewResult()
        }
        setCenter()
        activityIndicator.startAnimating()
    }
    
    
    fileprivate func reloadSavedData() -> [Photo]? {
        var photoArray: [Photo] = []
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", argumentArray: [pin!])
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "imageURL", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            let photoCount = try fetchedResultsController.managedObjectContext.count(for: fetchedResultsController.fetchRequest)
            
            for index in 0..<photoCount {
                
                photoArray.append(fetchedResultsController.object(at: IndexPath(row: index, section: 0)))
            }
            return photoArray
            
        } catch {
            print("error performing fetch")
            return nil
        }
    }
    
    fileprivate func getFlickrPhotos() {
        FlickrClient.shared.getFlickrPhoto(lat: currentLatitude!, lon: currentLongitude!, page: 1) { (photos, error) in
            
            if let error = error {
                DispatchQueue.main.async {
                    
                    self.activityIndicator.stopAnimating()
                    
                    let alertVC = UIAlertController(title: "Error", message: "Error retrieving data", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(alertVC, animated: true)
                    print(error.localizedDescription)
                }
            } else {
                if let photos = photos {
                    
                    DispatchQueue.main.async {
                        
                        self.flickrPhotos = photos
                        self.saveToCoreData(photos: photos)
                        self.activityIndicator.stopAnimating()
                        self.collectionView.reloadData()
                        self.savedPhotoObjects = self.reloadSavedData()!
                        self.showSavedResult()
                    }
                }
            }
        }
    }
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func saveToCoreData(photos: [FlickrPhoto]) {
        
        for flickrPhoto in photos {
            let photo = Photo(context: DataController.shared.viewContext)
            photo.imageURL = flickrPhoto.imageURLString()
            photo.pin = pin
            savedPhotoObjects.append(photo)
            DataController.shared.save()
        }
    }
    
    
    func deleteExistingCoreDataPhoto() {
        
        for image in savedPhotoObjects {
            DataController.shared.viewContext.delete(image)
        }
    }
    
    func showSavedResult() {
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func showNewResult() {
        
        deleteExistingCoreDataPhoto()
        savedPhotoObjects.removeAll()
        
        getFlickrPhotos()
    }
    
    fileprivate func getRandomFlickrImages() {
        let random = Int.random(in: 2...4)
        FlickrClient.shared.getFlickrPhoto(lat: currentLatitude!, lon: currentLongitude!, page: random, completion: { (photos, error) in
            
            if let error = error {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    let alertVC = UIAlertController(title: "Error", message: "Error retrieving data", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(alertVC, animated: true)
                    print(error.localizedDescription)
                }
            } else {
                if let photos = photos {
                    
                    DispatchQueue.main.async {
                        self.flickrPhotos = photos
                        self.saveToCoreData(photos: photos)
                        self.activityIndicator.stopAnimating()
                        self.savedPhotoObjects = self.reloadSavedData()!
                        self.showSavedResult()
                    }
                }
            }
        })
    }
    
    @IBAction func newCollectionsButton(_ sender: Any) {
        
        activityIndicator.startAnimating()
        deleteExistingCoreDataPhoto()
        getRandomFlickrImages()
        activityIndicator.stopAnimating()
    }
    
}



