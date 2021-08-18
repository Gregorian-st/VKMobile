//
//  VKAPIServiceFriends.swift
//  VKMobile
//
//  Created by Grigory on 18.01.2021.
//

import Foundation
import Alamofire
import RealmSwift

struct ResponseItemFriends<T>: Decodable where T: Decodable {
    var count: Int
    var items: [T]
}

struct MainUserResponseFriends: Decodable {
    var response: ResponseItemFriends<UserVK>
}

class VKAPIServiceFriends {
    
    let friendsQueue = OperationQueue()
    
    func getUserFriends(userId: Int, token: String) {
        
        // Creating of Operations
        let operationRequestUsers = RequestUser()
        operationRequestUsers.id = userId
        operationRequestUsers.token = token
        
        let operationParseUsers = ParseUser()
        operationParseUsers.id = userId
        
        let operationSaveUsersToRealm = SaveUserToRealm()
        operationSaveUsersToRealm.id = userId
        
        // Data transfer operations
        let adapterOperation1 = BlockOperation {
            operationParseUsers.data = operationRequestUsers.dataOutput
        }
        
        let adapterOperation2 = BlockOperation {
            operationSaveUsersToRealm.users = operationParseUsers.usersOutput
        }
        
        // Adding dependencies
        adapterOperation1.addDependency(operationRequestUsers)
        operationParseUsers.addDependency(adapterOperation1)
        adapterOperation2.addDependency(operationParseUsers)
        operationSaveUsersToRealm.addDependency(adapterOperation2)
        
        // Creating Queue
        friendsQueue.addOperations ([operationRequestUsers, adapterOperation1, operationParseUsers, adapterOperation2, operationSaveUsersToRealm], waitUntilFinished: false)
    }
    
    final class RequestUser: AsyncOperation {
        var id: Int = 0
        var token: String = ""
        var dataOutput: Data = Data()
        
        override func main() {
            let url = "https://api.vk.com/method/friends.get"
            let parameters: Parameters = [
                "user_id": id,
                "order": "name",
                "fields": "bdate,photo_100",
                "access_token": token,
                "v": "5.126"
            ]
            AF.request(url, method: .get, parameters: parameters).responseData { (response) in
                guard let data = response.data else {
                    self.state = .finished
                    return
                }
                self.dataOutput = data
                self.state = .finished
            }
        }
    }
    
    final class ParseUser: Operation {
        var id: Int = 0
        var data: Data = Data()
        var usersOutput: [UserVK] = []
        
        override func main() {
            do {
                let mainResponse = try JSONDecoder().decode(MainUserResponseFriends.self, from: data)
                mainResponse.response.items.forEach { $0.userId = id }
                usersOutput = mainResponse.response.items
            } catch {
                print(error)
            }
        }
    }
    
    final class SaveUserToRealm: Operation {
        var id: Int = 0
        var users: [UserVK] = []
        
        override func main(){
            do {
                let realmConfig = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
                let realmDB = try! Realm(configuration: realmConfig)
                let existingUser = realmDB.objects(UserVK.self).filter("userId == %@", id)
                try realmDB.write {
                    realmDB.delete(existingUser)
                    realmDB.add(users)
                }
            } catch {
                print(error)
            }
        }
    }
        
}

