//
//  AppDelegate.swift
//  VKMobile
//
//  Created by Grigory on 10.10.2020.
//

import UIKit
//import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print(getDocumentsDirectory())
//        setTestData()
//        FirebaseApp.configure()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
//    func setTestData() {
        /*
        // Friends Array
        GlobalVariables.mainUser.friendsArray.append(UserVK.init(id: 0, name: "Ivan", surname: "Ivanov", birthday: "01.10.1970"))
        GlobalVariables.mainUser.friendsArray.append(UserVK.init(id: 0, name: "John", surname: "Appleseed", birthday: "01.10.1970"))
        GlobalVariables.mainUser.friendsArray.append(UserVK.init(id: 0, name: "Kate", surname: "Bell", birthday: "01.10.1970"))
        GlobalVariables.mainUser.friendsArray.append(UserVK.init(id: 0, name: "Anna", surname: "Haro", birthday: "01.10.1970"))
        GlobalVariables.mainUser.friendsArray.append(UserVK.init(id: 0, name: "Daniel", surname: "Higgins", birthday: "01.10.1970"))
        GlobalVariables.mainUser.friendsArray.append(UserVK.init(id: 0, name: "David", surname: "Taylor", birthday: "01.10.1970"))
        GlobalVariables.mainUser.friendsArray.append(UserVK.init(id: 0, name: "Hank", surname: "Zakroff", birthday: "01.10.1970"))
        GlobalVariables.mainUser.friendsArray.append(UserVK.init(id: 0, name: "Sylvester", surname: "Stallone", birthday: "01.10.1970"))
        GlobalVariables.mainUser.friendsArray.append(UserVK.init(id: 0, name: "Luke", surname: "Skywalker", birthday: "01.10.1970"))
        GlobalVariables.mainUser.friendsArray.append(UserVK.init(id: 0, name: "Alex", surname: "Murphy", birthday: "01.10.1970"))

        for user in GlobalVariables.mainUser.friendsArray {
            user.avatar = "Users/\(user.name)_\(user.surname)"
        }
        
        for i in 1...10 {
            GlobalVariables.mainUser.friendsArray.append(UserVK.init(id: 0, name: Lorem.firstName, surname: Lorem.lastName, birthday: "01.10.1970"))
            GlobalVariables.mainUser.friendsArray.last?.avatar = "Users/avatar\(String(format: "%02u", i))"
        }
        
        GlobalVariables.mainUser.friendsArray.sort(by: <)
        
        for user in GlobalVariables.mainUser.friendsArray {
            user.photos.append(PhotoVK.init(photoName: "Photos/Photo01", likeCount: UInt(Int.random(in: 0...1000))))
            user.photos.append(PhotoVK.init(photoName: "Photos/Photo02", likeCount: UInt(Int.random(in: 0...1000))))
            user.photos.append(PhotoVK.init(photoName: "Photos/Photo03", likeCount: UInt(Int.random(in: 0...1000))))
            user.photos.append(PhotoVK.init(photoName: "Photos/Photo04", likeCount: UInt(Int.random(in: 0...1000))))
            user.photos.append(PhotoVK.init(photoName: "Photos/Photo05", likeCount: UInt(Int.random(in: 0...1000))))
            user.photos.append(PhotoVK.init(photoName: "Photos/Photo06", likeCount: UInt(Int.random(in: 0...1000))))
            user.photos.append(PhotoVK.init(photoName: "Photos/Photo07", likeCount: UInt(Int.random(in: 0...1000))))
            user.photos.append(PhotoVK.init(photoName: "Photos/Photo08", likeCount: UInt(Int.random(in: 0...1000))))
            user.photos.append(PhotoVK.init(photoName: "Photos/Photo09", likeCount: UInt(Int.random(in: 0...1000))))
            user.photos.append(PhotoVK.init(photoName: "Photos/Photo10", likeCount: UInt(Int.random(in: 0...1000))))
        }
        
        // All Groups Array
        GlobalVariables.allGroupArray.append(GroupVK.init(id: -1, name: "Afisha", image: "Groups/Group01", cntSubscribers: UInt(Float.random(in: 0..<1) * 1000000)))
        GlobalVariables.allGroupArray.append(GroupVK.init(id: -2, name: "Focus", image: "Groups/Group02", cntSubscribers: UInt(Float.random(in: 0..<1) * 1000000)))
        GlobalVariables.allGroupArray.append(GroupVK.init(id: -3, name: "Radio Energy", image: "Groups/Group03", cntSubscribers: UInt(Float.random(in: 0..<1) * 1000000)))
        GlobalVariables.allGroupArray.append(GroupVK.init(id: -4, name: "Vdud", image: "Groups/Group04", cntSubscribers: UInt(Float.random(in: 0..<1) * 1000000)))
        GlobalVariables.allGroupArray.append(GroupVK.init(id: -5, name: "Mash", image: "Groups/Group05", cntSubscribers: UInt(Float.random(in: 0..<1) * 1000000)))
        GlobalVariables.allGroupArray.append(GroupVK.init(id: -6, name: "Forbes", image: "Groups/Group06", cntSubscribers: UInt(Float.random(in: 0..<1) * 1000000)))
        GlobalVariables.allGroupArray.append(GroupVK.init(id: -7, name: "Namedni", image: "Groups/Group07", cntSubscribers: UInt(Float.random(in: 0..<1) * 1000000)))
        GlobalVariables.allGroupArray.append(GroupVK.init(id: -8, name: "Igromania", image: "Groups/Group08", cntSubscribers: UInt(Float.random(in: 0..<1) * 1000000)))
        GlobalVariables.allGroupArray.append(GroupVK.init(id: -9, name: "N plus One", image: "Groups/Group09", cntSubscribers: UInt(Float.random(in: 0..<1) * 1000000)))
        GlobalVariables.allGroupArray.append(GroupVK.init(id: -10, name: "Marylin Manson", image: "Groups/Group10", cntSubscribers: UInt(Float.random(in: 0..<1) * 1000000)))
        GlobalVariables.allGroupArray.append(GroupVK.init(id: -11, name: "Metallica", image: "Groups/Group11", cntSubscribers: UInt(Float.random(in: 0..<1) * 1000000)))
        GlobalVariables.allGroupArray.append(GroupVK.init(id: -12, name: "SwiftBook", image: "Groups/Group12", cntSubscribers: UInt(Float.random(in: 0..<1) * 1000000)))
        GlobalVariables.allGroupArray.append(GroupVK.init(id: -13, name: "PLC-systems", image: "Groups/Group13", cntSubscribers: UInt(Float.random(in: 0..<1) * 1000000)))
        GlobalVariables.allGroupArray.append(GroupVK.init(id: -14, name: "Borland Delphi 7", image: "Groups/Group14", cntSubscribers: UInt(Float.random(in: 0..<1) * 1000000)))
        GlobalVariables.allGroupArray.append(GroupVK.init(id: -15, name: "Apple", image: "Groups/Group15", cntSubscribers: UInt(Float.random(in: 0..<1) * 1000000)))
        GlobalVariables.allGroupArray.append(GroupVK.init(id: -16, name: "Sony Alpha", image: "Groups/Group16", cntSubscribers: UInt(Float.random(in: 0..<1) * 1000000)))
        GlobalVariables.allGroupArray.append(GroupVK.init(id: -17, name: "Lukoil", image: "Groups/Group17", cntSubscribers: UInt(Float.random(in: 0..<1) * 1000000)))
        GlobalVariables.allGroupArray.append(GroupVK.init(id: -18, name: "NBA", image: "Groups/Group18", cntSubscribers: UInt(Float.random(in: 0..<1) * 1000000)))
        GlobalVariables.allGroupArray.append(GroupVK.init(id: -19, name: "Soul Kitchen Bar", image: "Groups/Group19", cntSubscribers: UInt(Float.random(in: 0..<1) * 1000000)))
        GlobalVariables.allGroupArray.append(GroupVK.init(id: -20, name: "Depeche Mode", image: "Groups/Group20", cntSubscribers: UInt(Float.random(in: 0..<1) * 1000000)))
        
        // My Groups
        GlobalVariables.mainUser.groups.append(GlobalVariables.allGroupArray[0])
        GlobalVariables.mainUser.groups.append(GlobalVariables.allGroupArray[1])
        GlobalVariables.mainUser.groups.append(GlobalVariables.allGroupArray[2])
        GlobalVariables.mainUser.groups.append(GlobalVariables.allGroupArray[3])
        GlobalVariables.mainUser.groups.append(GlobalVariables.allGroupArray[4])
        GlobalVariables.mainUser.groups.append(GlobalVariables.allGroupArray[5])
        GlobalVariables.mainUser.groups.append(GlobalVariables.allGroupArray[6])
        GlobalVariables.mainUser.groups.append(GlobalVariables.allGroupArray[7])
        GlobalVariables.mainUser.groups.append(GlobalVariables.allGroupArray[8])
        GlobalVariables.mainUser.groups.append(GlobalVariables.allGroupArray[9])
        */
        
        // News Array
        // "mix" type
//        for i in 1...8 {
//            let dateString: String = String(format: "%02u", Int.random(in: 1...29)) + "." + String(format: "%02u", Int.random(in: 1...10)) + ".2020"
//            let textString = Lorem.sentences(Int.random(in: 1...10))
//            GlobalVariables.newsArray.append(NewsVK.init(publisherAvatar: "Creators/avatar\(String(format: "%02u", i))", publisherFullName: Lorem.fullName, date: dateString, textFull: textString))
//            GlobalVariables.newsArray[i-1].likeCount = Int.random(in: 0...10000)
//            let rnd = UInt.random(in: 1...10)
//            for j in 1...rnd {
//                GlobalVariables.newsArray[i-1].images.append("Photos/Photo\(String(format: "%02u", j))")
//            }
//            GlobalVariables.newsArray[i-1].viewCount = Int.random(in: 0...10000)
//            GlobalVariables.newsArray[i-1].repostCount = Int.random(in: 0...100)
//            GlobalVariables.newsArray[i-1].commentCount = Int.random(in: 0...1000)
//        }
        // "post" type
//        var dateString: String = String(format: "%02u", Int.random(in: 1...29)) + "." + String(format: "%02u", Int.random(in: 1...10)) + ".2020"
//        var textString = Lorem.sentences(Int.random(in: 10...20))
//        GlobalVariables.newsArray.append(NewsVK.init(publisherAvatar: "Creators/avatar\(String(format: "%02u", 9))", publisherFullName: Lorem.fullName, date: dateString, textFull: textString))
//        GlobalVariables.newsArray[8].postType = .post
//        GlobalVariables.newsArray[8].likeCount = Int.random(in: 0...10000)
//        GlobalVariables.newsArray[8].viewCount = Int.random(in: 0...10000)
//        GlobalVariables.newsArray[8].repostCount = Int.random(in: 0...100)
//        GlobalVariables.newsArray[8].commentCount = Int.random(in: 0...1000)
        // "photo" type
//        dateString = String(format: "%02u", Int.random(in: 1...29)) + "." + String(format: "%02u", Int.random(in: 1...10)) + ".2020"
//        textString = ""
//        GlobalVariables.newsArray.append(NewsVK.init(publisherAvatar: "Creators/avatar\(String(format: "%02u", 10))", publisherFullName: Lorem.fullName, date: dateString, textFull: textString))
//        GlobalVariables.newsArray[9].postType = .photo
//        GlobalVariables.newsArray[9].likeCount = Int.random(in: 0...10000)
//        let rnd = UInt.random(in: 1...10)
//        for j in 1...rnd {
//            GlobalVariables.newsArray[9].images.append("Photos/Photo\(String(format: "%02u", j))")
//        }
//        GlobalVariables.newsArray[9].viewCount = Int.random(in: 0...10000)
//        GlobalVariables.newsArray[9].repostCount = Int.random(in: 0...100)
//        GlobalVariables.newsArray[9].commentCount = Int.random(in: 0...1000)
//    }

}

