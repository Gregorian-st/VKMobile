//
//  AsyncPhotoCollectionViewController.swift
//  VKMobile
//
//  Created by Grigory on 04.02.2021.
//

import UIKit
import AsyncDisplayKit

class AsyncPhotoCollectionViewController: ASDKViewController<ASDisplayNode>, ASCollectionDelegate, ASCollectionDataSource {
    
    var userId: Int = 0
    let flowLayout = UICollectionViewFlowLayout()
    weak var userPhotos: PhotoAlbumVK?
    lazy var service = VKAPIService()
    private var singleView: Bool = false
    
    var collectionNode: ASCollectionNode
    
    override init() {
        collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        
        super.init(node: collectionNode )
        
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 2
        
        self.collectionNode.delegate = self
        self.collectionNode.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        
        if let album = userPhotos {
            service.getUserPhotoAlbumNetwork(ownerId: userId, albumId: album.id) { [weak self] (photos) in
                album.photos = photos
                self?.collectionNode.reloadData()
            }
        }
    }
    
    override func viewLayoutMarginsDidChange() {
        collectionNode.reloadData()
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return userPhotos?.photos.count ?? 0
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        guard
            let album = userPhotos
        else { return ASCellNode() }
        
        let cellNodeBlock = { () -> ASCellNode in
            let node = ImageNode(resourcePhoto: album.photos[indexPath.row], single: self.singleView)
            return node
        }
        return cellNodeBlock()
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        switchView(indexPath: indexPath)
    }
    
    // MARK: - Program Logic
    
    func switchView(indexPath: IndexPath) {
        singleView.toggle()
        collectionNode.reloadData()
        collectionNode.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
    }
    
}
