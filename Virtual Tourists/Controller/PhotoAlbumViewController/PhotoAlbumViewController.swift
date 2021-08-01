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
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>? = nil
    var currentLatitude = 0.0
    var currentLongitude = 0.0
    var collectionViewCells: [PhotoCell] = []
    let numberOfColumns: CGFloat = 3
    var savedPhotoObjects = [Photo]()
    var flickrPhotos: [FlickrPhoto] = []
    
    
    let managedObjectContext =
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newCollectionsButton: UIButton!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    
    func setupFetchedResultsController() {
        
        guard let pin = pin else {
            fatalError("setupPhotos: pin is nil")
        }
        
        let fetchRequest: NSFetchRequest = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        self.fetchedResultsController = .init(fetchRequest: fetchRequest,managedObjectContext: managedObjectContext,sectionNameKeyPath: nil,cacheName: nil)
        
        do {
            try fetchedResultsController!.performFetch()
            
        } catch {
            print("error performing fetch")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setMapCenter()
        downloadingImages = true
        getRandomFlickrImages()
        
        activityIndicator.startAnimating()
    }
    
    var downloadingImages = false {
        didSet {
            DispatchQueue.main.async {
                self.newCollectionsButton.isEnabled = !self.downloadingImages
            }
        }
    }
    
    func setupPhotos() {
        
        assert(collectionView != nil, "collection view is nil")
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        downloadingImages = true
        setupFetchedResultsController()
        
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
            downloadingImages = false
            return
        }
    }
    
    
    @IBAction func newCollectionsButton(_ sender: Any) {
        
        collectionViewCells = []
        collectionView.reloadData()
        
        activityIndicator.startAnimating()
        
        downloadingImages = true
        savedPhotoObjects.removeAll()
        getFlickrPhotoURL()
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
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.collectionView.reloadData()
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




