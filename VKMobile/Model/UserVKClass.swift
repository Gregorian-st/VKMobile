//
//  UserVKClass.swift
//  VKMobile
//
//  Created by Grigory on 18.10.2020.
//

import Foundation
import RealmSwift

class UserVK: Object, Comparable, Decodable {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var surname: String = ""
    @objc dynamic var birthday: String = ""
    @objc dynamic var avatar: String = ""
    @objc dynamic var userId: Int = 0
    var birthdayFormatted: String {
        get {
            return formatStrDate(self.birthday)
        }
    }
    
    var photos: [PhotoVK] = []
    var groups: [GroupVK] = []
    var friendsArray: [UserVK] = []
    var photoAlbums: [PhotoAlbumVK] = []
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "first_name"
        case surname = "last_name"
        case birthday = "bdate"
        case avatar = "photo_100"
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.surname = try container.decodeIfPresent(String.self, forKey: .surname) ?? ""
        self.birthday = try container.decodeIfPresent(String.self, forKey: .birthday) ?? ""
        self.avatar = try container.decodeIfPresent(String.self, forKey: .avatar) ?? ""
    }
    
    convenience init(id: Int, name: String, surname: String, birthday: String) {
        self.init()
        
        self.id = id
        self.name = name
        self.surname = surname
        self.avatar = "person_circle"
        self.birthday = birthday
    }
    
    static func < (lhs: UserVK, rhs: UserVK) -> Bool {
        if (lhs.surname.lowercased() < rhs.surname.lowercased())||((lhs.surname.lowercased() == rhs.surname.lowercased())&&(lhs.name.lowercased() < rhs.name.lowercased())) {
            return true
        }
        return false
    }
    
    static func == (lhs: UserVK, rhs: UserVK) -> Bool {
        return (lhs.surname.lowercased() == rhs.surname.lowercased())&&(lhs.name.lowercased() == rhs.name.lowercased())
    }
    
    func formatStrDate(_ date: String) -> String {
        var strDate: String = ""
        
        let strDateArray = date.split(separator: ".")
        switch strDateArray.count {
        case 2:
            guard
                let day = Int(String(strDateArray[0])),
                let month = Int(String(strDateArray[1]))
            else { break }
            strDate = String(format: "%02u", day) + "." + String(format: "%02u", month)
        case 3:
            guard
                let day = Int(String(strDateArray[0])),
                let month = Int(String(strDateArray[1])),
                let year = Int(String(strDateArray[2]))
            else { break }
            strDate = String(format: "%02u", day) + "." + String(format: "%02u", month) + "." + String(format: "%04u", year)
        default:
            strDate = date
        }
        
        return strDate
    }
    
}
