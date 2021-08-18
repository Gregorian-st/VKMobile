//
//  ImageNode.swift
//  VKMobile
//
//  Created by Grigory on 04.02.2021.
//

import UIKit
import AsyncDisplayKit

class ImageNode: ASCellNode {
    
    enum requestType {
        case albumList
        case photoList
        case photoSingle
    }
    
    private var resource = PhotoVK()
    private var resourceAlbum = PhotoAlbumVK()
    private let photoImageNode = ASNetworkImageNode()
    private let iconImageNode = ASImageNode()
    private var request: requestType = .albumList
    
    init(resourcePhoto: PhotoVK, single: Bool) {
        self.resource = resourcePhoto
        self.request = single ? .photoSingle : .photoList
        super.init ()
        setupPhotoSubnodes()
    }
    
    init(resourceAlbum: PhotoAlbumVK) {
        self.resourceAlbum = resourceAlbum
        self.request = .albumList
        super.init ()
        setupPhotoSubnodes()
    }
    
    private func setupPhotoSubnodes() {
        switch request {
        case .albumList:
            photoImageNode.url = URL(string: resourceAlbum.thumbLink)
            photoImageNode.contentMode = .scaleAspectFill
            photoImageNode.shouldRenderProgressImages = true
            addSubnode(photoImageNode)
            iconImageNode.image = UIImage(named: "folder")
            addSubnode(iconImageNode)
        case .photoList, .photoSingle:
            photoImageNode.url = URL(string: resource.photoName)
            photoImageNode.contentMode = .scaleAspectFill
            photoImageNode.shouldRenderProgressImages = true
            addSubnode(photoImageNode)
        }
    }
    
    override func layoutSpecThatFits ( _ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        switch request {
        case .albumList:
            let photoDimension = (constrainedSize.max.width - 21) / 3
            photoImageNode.style.preferredSize = CGSize(width: photoDimension, height: photoDimension)
            let iconDimension = photoDimension / 4
            iconImageNode.style.preferredSize = CGSize(width: iconDimension, height: iconDimension * 0.7)
            let iconInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: iconDimension + 5, left: 0, bottom: 0, right: iconDimension + 5), child: iconImageNode)
            return ASCornerLayoutSpec(child: photoImageNode, corner: iconInsetSpec, location: .topRight)
        case .photoList:
            let photoDimension = (constrainedSize.max.width - 14) / 3
            photoImageNode.style.preferredSize = CGSize(width: photoDimension, height: photoDimension)
            let imageInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 1, left: 2, bottom: 1, right: 2), child: photoImageNode)
            return ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumX, child: imageInsetSpec)
        case .photoSingle:
            let photoDimension = constrainedSize.max.width
            photoImageNode.style.preferredSize = CGSize(width: photoDimension, height: photoDimension * resource.aspectRatio)
            let imageInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 1, left: 2, bottom: 1, right: 2), child: photoImageNode)
            return ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumX, child: imageInsetSpec)
        }
    }
    
}
