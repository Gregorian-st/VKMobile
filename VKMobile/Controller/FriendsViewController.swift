//
//  FriendsViewController.swift
//  VKMobile
//
//  Created by Grigory on 14.10.2020.
//

import UIKit
import RealmSwift

var mainUser: UserVK = UserVK.init(id: 0, name: "Grigory", surname: "Stolyarov", birthday: "29.06.1976")

class FriendsViewController: UIViewController, FriendsViewDelegate {
    
    lazy var contentView = self.view as! FriendsView
    
    lazy var service = VKAPIService()
    var session = Session.instance
    var refreshControl = UIRefreshControl()
    
    var notificationToken: NotificationToken?
    
    lazy var realm: Realm = {
        let realmConfig = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        let realmDB = try! Realm(configuration: realmConfig)
        return realmDB
    }()
    lazy var friends: Results<UserVK> = {
        return realm.objects(UserVK.self).filter("userId == %@", session.userId)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBarCustomization()
        contentView.registerElements()
        contentView.delegate = self
        
        mainUser.id = session.userId
        subscribeToRealm()
        
        // RefreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        contentView.tableView.addSubview(refreshControl)
        
        service.getUserFriends(userId: session.userId, completion: {})
    }
    
    @objc func refresh() {
        service.getUserFriends(userId: session.userId, completion: {})
        refreshControl.endRefreshing()
    }
    
    func userSelected(at index: Int) {
        let controller = AsyncAlbumCollectionViewController()
        controller.title = "\(mainUser.friendsArray[index].name) \(mainUser.friendsArray[index].surname)"
        controller.userPhotos = mainUser.friendsArray[index]
        controller.view.backgroundColor = .white
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let photosViewController = segue.destination as? PhotosCollectionViewController,
              let index = contentView.tableView.indexPathForSelectedRow
        else { return }
        let filteredUserIndex = contentView.getUserIndex(for: index)
        guard let userIndex = mainUser.friendsArray.firstIndex(of: contentView.myFriendsArray[filteredUserIndex])
        else { return }
        
        photosViewController.title = "\(mainUser.friendsArray[userIndex].name) \(mainUser.friendsArray[userIndex].surname)"
        photosViewController.userPhotos = mainUser.friendsArray[userIndex]
    }
    
    // MARK: - Program Logic
    
    func navBarCustomization() {
        navigationController?.navigationBar.backgroundColor = .white
        
        if let font = UIFont.brandVKFont {
            navigationController?.navigationBar.largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.brandVKColor,
                NSAttributedString.Key.font: font
            ]
        }
    }
    
    func subscribeToRealm() {
        notificationToken = friends.observe{ (changes) in
            mainUser.friendsArray = Array(self.friends)
            mainUser.friendsArray.sort(by: <)
            self.contentView.fillMyFriends("")
            self.contentView.getFirstLetters()
            self.contentView.tableView.reloadData()
        }
    }
    
}
