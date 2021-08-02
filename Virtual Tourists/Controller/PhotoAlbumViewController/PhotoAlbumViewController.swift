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

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    
    public static let reuseId = "photoCell"
    
    var pin: Pin? = nil
    var dataController:DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!

    var currentLatitude = Double()
    var currentLongitude = Double()
    var collectionViewCells: [PhotoCell] = []
    let numberOfColumns: CGFloat = 3
    var savedPhotoObjects = [Photo]()
    var flickrPhotos: [FlickrPhoto] = []
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer.viewContext
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newCollectionsButton: UIButton!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    
    
    fileprivate func loadSavedData() -> [Photo]? {
        var photoArray: [Photo] = []
    
        guard let pin = pin else {
                    fatalError("pin is nil")
                }

        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate =  NSPredicate(format: "pin == %@", pin)
        let sortDescriptor = NSSortDescriptor(key: "imageURL", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        self.fetchedResultsController = .init(
                    fetchRequest: fetchRequest,
                    managedObjectContext: DataController.shared.viewContext,
                    sectionNameKeyPath: nil,
                    cacheName: "Virtual Tourist"
                )
        
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setUpCollectionView()
        setMapCenter()
        getFlickrPhotoURL()
        activityIndicator.startAnimating()
    }
    
    
    @IBAction func newCollectionsButton(_ sender: Any) {
        
        collectionViewCells = []
        collectionView.reloadData()
        
        activityIndicator.startAnimating()
        
        savedPhotoObjects.removeAll()
        getRandomFlickrImages()
    }
    
    
    fileprivate func getFlickrPhotoURL() {
        FlickrClient.shared.getFlickrPhotoURL(lat: currentLatitude, lon: currentLongitude, page: 1) { (photos, error) in
            
            
            if let error = error {
                DispatchQueue.main.async {
                    
                    self.activityIndicator.startAnimating()
                    
                    let alertVC = UIAlertController(title: "Error", message: "Error retrieving data", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(alertVC, animated: true)
                    print(error.localizedDescription)
                }
            } else {
                if let photos = photos { DispatchQueue.main.async {
                    self.flickrPhotos = photos
                    self.saveToCoreData(photos: photos)
                    self.activityIndicator.stopAnimating()
                    self.collectionView.reloadData()
                    self.showSavedResult()
                }
                }
            }
        }
    }
    
    
    fileprivate func getRandomFlickrImages() {
        let random = Int.random(in: 2...4)
        FlickrClient.shared.getFlickrPhotoURL(lat: currentLatitude, lon: currentLongitude, page: random, completion: { (photos, error) in
            
            if let error = error {
                DispatchQueue.main.async {
                    self.activityIndicator.startAnimating()
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
                        self.showSavedResult()
                    }
                }
            }
        })
    }
    
    
    func saveContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        configureFlowLayout()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        collectionView.reloadData()
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
        
        for image in savedPhotoObjects
        {
            DataController.shared.viewContext.delete(image)
        }
    }
    
    func showSavedResult() {
        DispatchQueue.main.async {
            
            self.collectionView.reloadData()
            self.activityIndicator.stopAnimating()
            
        }
    }
    
    func showNewResult() {
        
        deleteExistingCoreDataPhoto()
        savedPhotoObjects.removeAll()
        getFlickrPhotoURL()
        
    }
    
}




