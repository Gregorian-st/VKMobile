//
//  GroupViewModelFactory.swift
//  VKMobile
//
//  Created by Grigory Stolyarov on 02.03.2021.
//

import Foundation

final class GroupViewModelFactory {
    
    func constructViewModels (from groups: [GroupVKAdapter]) -> [GroupViewModel] {
        return groups.compactMap(self.viewModel)
    }
    
    private func viewModel (from group: GroupVKAdapter) -> GroupViewModel {
        let groupName = group.name
        let groupType: String = group.isClosed ? "Closed group" : "Open group"
        let groupImageName = group.image
        
        return GroupViewModel (name: groupName, image: groupImageName, isClosed: groupType)
    }

}
