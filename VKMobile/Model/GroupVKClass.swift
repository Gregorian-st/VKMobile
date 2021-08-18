//
//  GroupVKClass.swift
//  VKMobile
//
//  Created by Grigory on 30.11.2020.
//

import Foundation
import RealmSwift
//import Firebase

class GroupVK: Object, Decodable {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var image: String = ""
    @objc dynamic var cntSubscribers: Int = 0
    @objc dynamic var isClosed: Bool = true
    @objc dynamic var userId: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case image = "photo_100"
        case cntSubscribers
        case isClosed = "is_closed"
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        let intIsClosed = try container.decode(Int.self, forKey: .isClosed)
        self.isClosed = intIsClosed == 1
        self.image = try container.decode(String.self, forKey: .image)
    }
    
    convenience init(id: Int, name: String, image: String, cntSubscribers: Int) {
        self.init()
        
        self.id = id
        self.name = name
        self.image = image
        self.cntSubscribers = cntSubscribers
    }
    
    static func == (lhs: GroupVK, rhs: GroupVK) -> Bool {
        return lhs.id == rhs.id
    }
    
}
