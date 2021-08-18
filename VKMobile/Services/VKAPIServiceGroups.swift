//
//  VKAPIServiceGroups.swift
//  VKMobile
//
//  Created by Grigory on 19.01.2021.
//

import Foundation
import Alamofire
import RealmSwift
import PromiseKit

struct ResponseItemGroups<T>: Decodable where T: Decodable {
    var count: Int
    var items: [T]
}

struct MainResponseGroups: Decodable {
    var response: ResponseItem<GroupVK>
}

class VKAPIServiceGroups {
    
    enum VKAPIServiceGroupsError: Error {
        case invalidResponse
    }

    func getUserGroups(userId: Int, token: String) {
        firstly {
            requestGroups(id: userId, token: token)
        }.then { data in
            self.parseGroups(id: userId, data: data)
        }.done { groups in
            self.saveGroupsToRealm(id: userId, groups: groups)
        }.catch { error in
            print(error)
        }
    }
    
    private func requestGroups(id: Int, token: String) -> Promise<Data> {
        return Promise<Data> { (resolver) in
            let url = "https://api.vk.com/method/groups.get"
            let parameters: Parameters = [
                "user_id": id,
                "extended": "1",
                "fields": "id,name,type,photo_100",
                "count": "1000",
                "access_token": token,
                "v": "5.126"
            ]
            AF.request(url, method: .get, parameters: parameters).responseData { (response) in
                guard let data = response.data else {
                    resolver.reject(VKAPIServiceGroupsError.invalidResponse)
                    return
                }
                resolver.fulfill(data)
            }
        }
    }
    
    private func parseGroups(id: Int, data: Data) -> Promise<[GroupVK]> {
        return Promise<[GroupVK]> { (resolver) in
            var groups: [GroupVK] = []
            do {
                let mainResponse = try JSONDecoder().decode(MainResponseGroups.self, from: data)
                mainResponse.response.items.forEach { $0.userId = id }
                groups = mainResponse.response.items
            } catch {
                print(error)
                resolver.reject(error)
                return
            }
            resolver.fulfill(groups)
        }
    }
    
    func saveGroupsToRealm(id: Int, groups: [GroupVK]) {
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
