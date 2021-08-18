//
//  PhotoVKClass.swift
//  VKMobile
//
//  Created by Grigory on 30.11.2020.
//

import Foundation
import RealmSwift

class PhotoVK: Object, Decodable {
    
    @objc dynamic var photoName: String = ""
    @objc dynamic var likeCount: Int = 0
    @objc dynamic var liked: Bool = false
    @objc dynamic var userId: Int = 0
    var height: Int = 0
    var width: Int = 0
    var aspectRatio: CGFloat {
        if width != 0 {
            return CGFloat(height) / CGFloat(width)
        } else {
            return 1
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case sizes
        case likes
    }
    
    enum SizesCodingKeys: String, CodingKey {
        case photoName = "url"
        case type
        case height
        case width
    }
    
    enum LikesCodingKeys: String, CodingKey {
        case liked = "user_likes"
        case likeCount = "count"
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        var sizesArrayContainer = try container.nestedUnkeyedContainer(forKey: .sizes)
        let count = sizesArrayContainer.count ?? 0
        if count > 0 {
            for _ in (0...count - 1) {
                let sizesContainer = try sizesArrayContainer.nestedContainer(keyedBy: SizesCodingKeys.self)
                let type: String = try sizesContainer.decode(String.self, forKey: .type)
                if type == "x" {
                    self.photoName = try sizesContainer.decode(String.self, forKey: .photoName)
                    self.height = try sizesContainer.decodeIfPresent(Int.self, forKey: .height) ?? 0
                    self.width = try sizesContainer.decodeIfPresent(Int.self, forKey: .width) ?? 0
                    break
                }
            }
        }
        
        do {
            let likesContainer = try container.nestedContainer(keyedBy: LikesCodingKeys.self, forKey: .likes)
            let intLiked = try likesContainer.decode(Int.self, forKey: .liked)
            self.liked = intLiked == 1
            self.likeCount = try likesContainer.decode(Int.self, forKey: .likeCount)
        } catch {
            print(error)
        }
    }
        
    convenience init(photoName: String, likeCount: Int) {
        self.init()
        
        self.photoName = photoName
        self.likeCount = likeCount
    }
    
}
