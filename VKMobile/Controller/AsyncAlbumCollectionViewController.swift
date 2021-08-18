//
//  AsyncPhotoCollectionViewController.swift
//  VKMobile
//
//  Created by Grigory on 04.02.2021.
//

import UIKit
import AsyncDisplayKit

class AsyncAlbumCollectionViewController: ASDKViewController<ASDisplayNode>, ASCollectionDelegate, ASCollectionDataSource {
    
    weak var userPhotos: UserVK?
    lazy var service = VKAPIService()
    
    var collectionNode: ASCollectionNode
    
    override init() {
        let flowLayout = UICollectionViewFlowLayout()
        collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        
        super.init(node: collectionNode )
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
        
        if let user = userPhotos {
            service.getUserPhotoAlbumsNetwork(ownerId: user.id) { [weak self] (photoAlbums) in
                user.photoAlbums = photoAlbums
                self?.collectionNode.reloadData()
            }
        }
    }
    
    override func viewLayoutMarginsDidChange() {
        collectionNode.reloadData()
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return userPhotos?.photoAlbums.count ?? 0
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        guard
            let user = userPhotos
        else { return ASCellNode() }
        
        let cellNodeBlock = { () -> ASCellNode in
            let node = ImageNode(resourceAlbum: user.photoAlbums[indexPath.row])
            return node
        }
        return cellNodeBlock()
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        guard
            let album = userPhotos
        else { return }
        
        let controller = AsyncPhotoCollectionViewController()
        controller.title = album.photoAlbums[indexPath.row].title
        controller.userId = album.id
        controller.userPhotos = album.photoAlbums[indexPath.row]
        controller.view.backgroundColor = .white
        navigationController?.pushViewController(controller, animated: true)
    }
    
}
