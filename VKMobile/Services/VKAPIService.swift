//
//  VKAPIService.swift
//  VKMobile
//
//  Created by Grigory on 25.11.2020.
//

import Foundation
import Alamofire
import RealmSwift

protocol VKAPIServiceNewsInterface {
    func getNewsFeed(startFrom: String, completion: @escaping ([NewsVK], String) -> Void)
    func getNewsFeedRefresh(startTime: String, completion: @escaping ([NewsVK]) -> Void)
}

class Session {
    static let instance = Session()
    private init() {}
    
    var token: String = ""
    var userId: Int = 0
}

struct ResponseItem<T>: Decodable where T: Decodable {
    var count: Int
    var items: [T]
}

struct ResponseNewsItem<T>: Decodable where T: Decodable {
    var items: [T]
    var profiles: [UserVK]
    var groups: [GroupVK]
    var next_from: String
}

struct ResponseNewsItemRefresh<T>: Decodable where T: Decodable {
    var items: [T]
    var profiles: [UserVK]
    var groups: [GroupVK]
}

struct MainUserResponse: Decodable {
    var response: ResponseItem<UserVK>
}

struct MainPhotoResponse: Decodable {
    var response: ResponseItem<PhotoVK>
}

struct MainGroupResponse: Decodable {
    var response: ResponseItem<GroupVK>
}

struct MainPhotoAlbumResponse: Decodable {
    var response: ResponseItem<PhotoAlbumVK>
}

struct NewsFeedResponse: Decodable {
    var response: ResponseNewsItem<NewsVK>
}

struct NewsFeedRefreshResponse: Decodable {
    var response: ResponseNewsItemRefresh<NewsVK>
}

struct VKAPIServiceConst {
    static let newsPhotoMax: Int = 100
}

class VKAPIService: VKAPIServiceNewsInterface {
    
    let baseURL: String = "https://api.vk.com"
    let session = Session.instance
    
    enum APIMethod {
        case friends(id: String)
        case photos(id: String)
        case groups(id: String)
        case groupsSearch(query: String)
        case newsFeed(startFrom: String)
        case newsFeedRefresh(startTime: String)
        case photoAlbums(id: String)
        case photosFromAlbum(id: String, albumId: String)
        
        var path: String {
            switch self {
            case .friends:
                return "/method/friends.get"
            case .photos:
                return "/method/photos.getAll"
            case .groups:
                return "/method/groups.get"
            case .groupsSearch:
                return "/method/groups.search"
            case .newsFeed, .newsFeedRefresh:
                return "/method/newsfeed.get"
            case .photoAlbums:
                return "/method/photos.getAlbums"
            case .photosFromAlbum:
                return "/method/photos.get"
            }
        }
        
        var parameters: [String: Any] {
            switch self {
            case .friends(let id):
                return [
                    "user_id": id,
                    "order": "name",
                    "fields": "bdate,photo_100"
                ]
            case .photos(let id):
                return [
                    "owner_id": id,
                    "extended": "1",
                    "count": "200",
                    "photo_sizes": "1",
                    "no_service_albums": "0"
                ]
            case .groups(let id):
                return [
                    "user_id": id,
                    "extended": "1",
                    "fields": "id,name,type,photo_100",
                    "count": "1000"
                ]
            case .groupsSearch(let query):
                return [
                    "q": query,
                    "type": "group",
                    "sort": "0",
                    "count": "100"
                ]
            case .newsFeed(let startFrom):
                return [
                    "filters": "post,wall_photo",
                    "return_banned": "0",
                    "max_photos": String(VKAPIServiceConst.newsPhotoMax),
                    "count": "25",
                    "start_from": startFrom
                ]
            case .newsFeedRefresh(let startTime):
                return [
                    "filters": "post,wall_photo",
                    "return_banned": "0",
                    "max_photos": String(VKAPIServiceConst.newsPhotoMax),
                    "count": "100",
                    "start_time": startTime
                ]
            case .photoAlbums(let id):
                return [
                    "owner_id": id,
                    "need_covers": "1",
                    "need_system": "1"
                ]
            case .photosFromAlbum(let id, let albumId):
                return [
                    "owner_id": id,
                    "album_id": albumId,
                    "count": "200",
                    "photo_sizes": "1"
                ]
            }
        }
    }
    
    private func request(_ method: APIMethod, completion: @escaping (Data?) -> Void) {
        let url = baseURL + method.path
        var parameters: Parameters = [
            "access_token": session.token,
            "v": "5.126"
        ]
        for (k, v) in method.parameters {
            parameters.updateValue(v, forKey: k)
        }
        AF.request(url, method: .get, parameters: parameters).responseData { (response) in
            guard let data = response.data else {
                completion(nil)
                return
            }
            completion(data)
        }
    }

    func getUserFriends(userId: Int, completion: @escaping () -> Void) {
        request(.friends(id: String(userId))) { (data) in
            guard let data = data else {
                completion()
                return
            }
            
            do {
                let mainResponse = try JSONDecoder().decode(MainUserResponse.self, from: data)
                mainResponse.response.items.forEach { $0.userId = userId }
                self.saveUsersToRealm(mainResponse.response.items, id: userId)
            } catch {
                print(error)
            }
            completion()
        }
    }
    
    func getUserPhotos(ownerId: Int, completion: @escaping () -> Void) {
        request(.photos(id: String(ownerId))) { (data) in
            guard let data = data else {
                completion()
                return
            }
            
            do {
                let mainResponse = try JSONDecoder().decode(MainPhotoResponse.self, from: data)
                mainResponse.response.items.forEach { $0.userId = ownerId }
                self.savePhotosToRealm(mainResponse.response.items, id: ownerId)
            } catch {
                print(error)
            }
            completion()
        }
    }
    
    func getUserPhotosNetwork(ownerId: Int, completion: @escaping ([PhotoVK]) -> Void) {
        request(.photos(id: String(ownerId))) { (data) in
            guard let data = data else {
                completion([])
                return
            }
            
            do {
                let mainResponse = try JSONDecoder().decode(MainPhotoResponse.self, from: data)
                completion(mainResponse.response.items)
            } catch {
                print(error)
                completion([])
            }
        }
    }
    
    func getUserPhotoAlbumsNetwork(ownerId: Int, completion: @escaping ([PhotoAlbumVK]) -> Void) {
        request(.photoAlbums(id: String(ownerId))) { (data) in
            guard let data = data else {
                completion([])
                return
            }
            
            do {
                let mainResponse = try JSONDecoder().decode(MainPhotoAlbumResponse.self, from: data)
                completion(mainResponse.response.items)
            } catch {
                print(error)
                completion([])
            }
        }
    }
    
    func getUserPhotoAlbumNetwork(ownerId: Int, albumId: Int,completion: @escaping ([PhotoVK]) -> Void) {
        request(.photosFromAlbum(id: String(ownerId), albumId: String(albumId))) { (data) in
            guard let data = data else {
                completion([])
                return
            }
            
            do {
                let mainResponse = try JSONDecoder().decode(MainPhotoResponse.self, from: data)
                completion(mainResponse.response.items)
            } catch {
                print(error)
                completion([])
            }
        }
    }
    
    func getUserGroups(userId: Int, completion: @escaping () -> Void) {
        request(.groups(id: String(userId))) { (data) in
            guard let data = data else {
                completion()
                return
            }
            
            do {
                let mainResponse = try JSONDecoder().decode(MainGroupResponse.self, from: data)
                mainResponse.response.items.forEach { $0.userId = userId }
                self.saveGroupsToRealm(mainResponse.response.items, id: userId)
            } catch {
                print(error)
            }
            completion()
        }
    }
    
    func getSearchGroups(query: String, completion: @escaping ([GroupVK]) -> Void) {
        
        if query == "" {
            completion([])
            return
        }
        
        request(.groupsSearch(query: query)) { (data) in
            guard let data = data else {
                completion([])
                return
            }
            
            do {
                let mainResponse = try JSONDecoder().decode(MainGroupResponse.self, from: data)
                completion(mainResponse.response.items)
            } catch {
                print(error)
                completion([])
            }
        }
    }
    
    func getNewsFeed(startFrom: String, completion: @escaping ([NewsVK], String) -> Void) {
        DispatchQueue.global().async {
            self.request(.newsFeed(startFrom: startFrom)) { (data) in
                guard let data = data else {
                    completion([], "")
                    return
                }
                
                do {
                    let mainResponse = try JSONDecoder().decode(NewsFeedResponse.self, from: data)
                    let rawNews = mainResponse.response.items
                    let newsUsers = mainResponse.response.profiles
                    let newsGroups = mainResponse.response.groups
                    let nextFrom = mainResponse.response.next_from
                    completion(self.updateNews(rawNews, newsUsers, newsGroups), nextFrom)
                } catch {
                    completion([], "")
                }
            }
        }
    }
    
    func getNewsFeedRefresh(startTime: String, completion: @escaping ([NewsVK]) -> Void) {
        DispatchQueue.global().async {
            self.request(.newsFeedRefresh(startTime: startTime)) { (data) in
                guard let data = data else {
                    completion([])
                    return
                }
                
                do {
                    let mainResponse = try JSONDecoder().decode(NewsFeedRefreshResponse.self, from: data)
                    let rawNews = mainResponse.response.items
                    let newsUsers = mainResponse.response.profiles
                    let newsGroups = mainResponse.response.groups
                    completion(self.updateNews(rawNews, newsUsers, newsGroups))
                } catch {
                    completion([])
                }
            }
        }
    }
    
    func updateNews(_ news: [NewsVK], _ users: [UserVK], _ groups: [GroupVK]) -> [NewsVK] {
        let newsCnt = news.count
        guard newsCnt > 0 else { return [] }
        
        var outNews: [NewsVK] = []
        
        for i in (0...newsCnt-1) {
            if news[i].sourceId != 0 && (news[i].textFull != "" || news[i].images.count > 0) {
                outNews.append(news[i])
                let publisherInfo = getPublisherInfo(news[i].sourceId, users, groups)
                if let lastNews = outNews.last {
                    lastNews.publisherAvatar = publisherInfo.0
                    lastNews.publisherFullName = publisherInfo.1
                    if lastNews.postType == .post && lastNews.textFull == "" {
                        lastNews.postType = .photo
                    }
                    if lastNews.postType == .post && lastNews.images.count > 0 {
                        lastNews.postType = .mix
                    }
                }
            }
        }
        
        return outNews
    }
    
    func getPublisherInfo(_ id: Int, _ users: [UserVK], _ groups: [GroupVK]) -> (String, String) {
        var publisherInfo: (String, String) = ("", "")
        if id > 0 {
            users.forEach { (user) in
                if user.id == id {
                    publisherInfo.0 = user.avatar
                    publisherInfo.1 = "\(user.name) \(user.surname)"
                }
            }
        } else {
            groups.forEach { (group) in
                if -group.id == id {
                    publisherInfo.0 = group.image
                    publisherInfo.1 = group.name
                }
            }
        }
        return publisherInfo
    }
    
    // MARK: Realm Realated Functions
    
    func getUserFriendsRealm(_ user: inout UserVK) {
        do {
            let realmDB = try Realm()
            user.friendsArray = Array(realmDB.objects(UserVK.self).filter("userId == %@", user.id))
        } catch {
            print(error)
        }
    }
    
    func saveUsersToRealm(_ users: [UserVK], id: Int) {
        do {
            let realmConfig = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
            let realmDB = try! Realm(configuration: realmConfig)
            let existingUser = realmDB.objects(UserVK.self).filter("userId == %@", id)
            try realmDB.write {
                realmDB.delete(existingUser)
            }
            try realmDB.write {
                realmDB.add(users)
            }
        } catch {
            print(error)
        }
    }
    
    func getUserPhotosRealm(_ user: inout UserVK) {
        do {
            let realmDB = try Realm()
            user.photos = Array(realmDB.objects(PhotoVK.self).filter("userId == %@", user.id))
        } catch {
            print(error)
        }
    }
    
    func savePhotosToRealm(_ photos: [PhotoVK], id: Int) {
        do {
            let realmConfig = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
            let realmDB = try Realm(configuration: realmConfig)
            let existingPhotos = realmDB.objects(PhotoVK.self).filter("userId == %@", id)
            try realmDB.write {
                realmDB.delete(existingPhotos)
            }
            try realmDB.write {
                realmDB.add(photos)
            }
        } catch {
            print(error)
        }
    }
    
    func getUserGroupsRealm(_ user: inout UserVK) {
        do {
            let realmDB = try Realm()
            user.groups = Array(realmDB.objects(GroupVK.self).filter("userId == %@", user.id))
        } catch {
            print(error)
        }
    }
    
    func saveGroupsToRealm(_ groups: [GroupVK], id: Int) {
        do {
            let realmConfig = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
            let realmDB = try Realm(configuration: realmConfig)
            let existingGroups = realmDB.objects(GroupVK.self).filter("userId == %@", id)
            try realmDB.write {
                realmDB.delete(existingGroups)
            }
            try realmDB.write {
                realmDB.add(groups)
            }
        } catch {
            print(error)
        }
    }
    
}
