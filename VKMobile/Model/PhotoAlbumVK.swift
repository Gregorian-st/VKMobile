//
//  PhotoAlbumVK.swift
//  VKMobile
//
//  Created by Grigory on 05.02.2021.
//

import Foundation

class PhotoAlbumVK: Decodable {
    
    var id: Int = 0
    var title: String = ""
    var thumbLink: String = ""
    var size: Int = 0
    
    var photos: [PhotoVK] = []
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case thumbLink = "thumb_src"
        case size
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.thumbLink = try container.decodeIfPresent(String.self, forKey: .thumbLink) ?? ""
        self.size = try container.decodeIfPresent(Int.self, forKey: .size) ?? 0
    }
    
}
