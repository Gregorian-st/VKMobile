//
//  GroupsAdapter.swift
//  VKMobile
//
//  Created by Grigory Stolyarov on 02.03.2021.
//

import Foundation
import RealmSwift

final class GroupsAdapter {
    
    private var notificationToken: NotificationToken?

    private lazy var realm: Realm = {
        let realmConfig = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        let realmDB = try! Realm(configuration: realmConfig)
        return realmDB
    }()
    private lazy var groupsVK: Results<GroupVK> = {
        return realm.objects(GroupVK.self).filter("userId == %@", Session.instance.userId)
    }()
    
    func getGroups(userId: Int, completion: @escaping ([GroupVKAdapter]) -> Void) {
        var groups: [GroupVKAdapter] = []
        notificationToken = groupsVK.observe{ [weak self] (changes) in
            groups = Array(self!.groupsVK).map { (self?.group(from: $0))! }
            completion(groups)
        }
    }
    
    private func group(from rlmGroup: GroupVK) -> GroupVKAdapter {
        return GroupVKAdapter(id: rlmGroup.id, name: rlmGroup.name, image: rlmGroup.image, cntSubscribers: rlmGroup.cntSubscribers, isClosed: rlmGroup.isClosed, userId: rlmGroup.userId)
    }
    
}
