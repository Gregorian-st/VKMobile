//
//  NewsFooter.swift
//  VKMobile
//
//  Created by Grigory on 04.11.2020.
//

import UIKit

class NewsFooter: UITableViewHeaderFooterView, LikeControlDelegate {
    
    @IBOutlet var viewButton: UIButton!
    @IBOutlet var repostButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    @IBOutlet weak var likeButton: LikeControl! {
        didSet {
            likeButton.delegate = self
        }
    }
    
    var viewCount: Int = 0 {
        didSet {
            viewButton.setTitle(" \(viewCount)", for: .normal)
        }
    }
    var repostCount: Int = 0 {
        didSet {
            repostButton.setTitle(" \(repostCount)", for: .normal)
        }
    }
    var commentCount: Int = 0 {
        didSet {
            commentButton.setTitle(" \(commentCount)", for: .normal)
        }
    }
    
    func likeChanged(_ id: Int, likeCount: Int, isActivated: Bool) {
        newsArray[id].likeCount = likeCount
        newsArray[id].liked = isActivated
    }

}
