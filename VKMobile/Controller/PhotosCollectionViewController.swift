//
//  PhotosCollectionViewController.swift
//  VKMobile
//
//  Created by Grigory on 14.10.2020.
//

import UIKit
import RealmSwift

class PhotosCollectionViewController: UICollectionViewController, PhotoCacheServiceAltDelegate {
    
    weak var userPhotos: UserVK?
    lazy var photoCache = PhotoCacheServiceAlt()
    
    lazy var service = VKAPIService()
    
    var notificationToken: NotificationToken?
    
    lazy var realm: Realm = {
        let realmConfig = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        let realmDB = try! Realm(configuration: realmConfig)
        return realmDB
    }()
    
    @IBAction func unwindFromPhoto(_ segue: UIStoryboardSegue) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        
        photoCache.delegate = self
        
        if let user = userPhotos {
            service.getUserPhotos(ownerId: user.id, completion: {})
            subscribeToRealm()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        notificationToken = nil
    }
    
    @objc func onLike(_ sender: UIControl) {
        if let likeControlInstance = sender as? LikeControl,
           let user = userPhotos {
            user.photos[sender.tag].likeCount = likeControlInstance.likeCount
            user.photos[sender.tag].liked = likeControlInstance.isActivated
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let photoViewController = segue.destination as? PhotoViewController,
              let user = userPhotos,
              let index = collectionView.indexPathsForSelectedItems?[0]
        else { return }
        photoViewController.photosArray = user.photos
        photoViewController.photoID = Int(index.row)
        photoViewController.title = title
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let user = userPhotos else {
            return 0
        }
        return user.photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "friendPhotoCell", for: indexPath) as! PhotosCollectionViewCell
        // cell.width.constant = view.frame.width / 3.2
        if let user = userPhotos {
            if let imageURL = URL.init(string: user.photos[indexPath.row].photoName) {
                cell.photoImage.image = photoCache.getPhoto(at: indexPath, byUrl: imageURL, cacheSubDir: "photo")
                cell.likeButton.tag = indexPath.row
                cell.likeButton.likeCount = user.photos[indexPath.row].likeCount
                cell.likeButton.isActivated = user.photos[indexPath.row].liked
            } else {
                cell.photoImage.image = UIImage(systemName: "photo")
                cell.likeButton.likeCount = 0
                cell.likeButton.isActivated = false
            }
        }
        
        return cell
    }
    
    func imageLoaded(at indexPath: IndexPath) {
        collectionView.reloadItems(at: [indexPath])
    }
    
    // MARK: - Program Logic
    
    func subscribeToRealm() {
        guard let user = userPhotos else { return }
        
        let photos: Results<PhotoVK> = realm.objects(PhotoVK.self).filter("userId == %@", user.id)
        
        notificationToken = photos.observe{ (changes) in
            user.photos = Array(photos)
            self.collectionView.reloadData()
        }
    }

}
