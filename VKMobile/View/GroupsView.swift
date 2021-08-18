//
//  GroupsView.swift
//  VKMobile
//
//  Created by Grigory on 27.01.2021.
//

import UIKit

final class GroupsView: UIView, UITableViewDataSource, UITableViewDelegate, CustomSearchBarDelegate {
    
    private let viewModelFactory = GroupViewModelFactory()
    private var myGroupsArrayFiltered: [GroupViewModel] = []
    var myGroupsArray: [GroupVKAdapter] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: CustomSearchBar!
    
    // MARK: - tableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myGroupsArrayFiltered.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupsCell", for: indexPath) as! GroupsTableViewCell
        cell.configure(with: myGroupsArrayFiltered[indexPath.row])
        return cell
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0.0
    }
    
    func textChanged(_ text: String?) {
        guard let searchText = text else { return }
        
        fillMyGroups(searchText)
    }
    
    // MARK: Program Logic
    
    func registerElements() {
        searchBar.delegate = self
        tableView.backgroundColor = .white
    }
    
    func fillMyGroups(_ filterGroupName: String) {
        if filterGroupName == "" {
            myGroupsArrayFiltered = viewModelFactory.constructViewModels(from: myGroupsArray)
        } else {
            var groupsFiltered: [GroupVKAdapter] = []
            for group in myGroupsArray {
                if group.name.localizedCaseInsensitiveContains(filterGroupName) {
                    groupsFiltered.append(group)
                }
            }
            myGroupsArrayFiltered = viewModelFactory.constructViewModels(from: groupsFiltered)
        }
        tableView.reloadData()
    }
    
}
