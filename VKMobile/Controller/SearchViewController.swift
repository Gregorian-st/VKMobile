//
//  SearchViewController.swift
//  VKMobile
//
//  Created by Grigory on 14.10.2020.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomSearchBarDelegate {
    
    var availGroupsArray: [GroupVK] = []
    var readGroupsArray: [GroupVK] = []
    var userId: Int = 0
    
    lazy var service = VKAPIService()
    var session = Session.instance
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: CustomSearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0.0
    }

    // MARK: Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availGroupsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell

        cell.groupNameLabel.text = availGroupsArray[indexPath.row].name
        cell.isClosedLabel.text = availGroupsArray[indexPath.row].isClosed ? "Closed group" : "Open group"
        cell.groupImage.imageName = availGroupsArray[indexPath.row].image

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !searchBar.active { return }
        let optionMenu = UIAlertController(title: nil, message: "Please select action", preferredStyle: .actionSheet)
        // for iPads
        if let popoverController = optionMenu.popoverPresentationController {
            if let cell = tableView.cellForRow(at: indexPath) {
                popoverController.sourceView = cell
                popoverController.sourceRect = cell.bounds
            }
        }

        let addActionHandler = { (action: UIAlertAction) -> Void in
            self.addGroup(indexPath)
        }
        let addAction = UIAlertAction(title: "Add Group", style: .default, handler: addActionHandler)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        optionMenu.addAction(addAction)
        optionMenu.addAction(cancelAction)

        present(optionMenu, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if !searchBar.active { return nil }
        let addAction = UIContextualAction(style: .normal, title: "Add") {
            (action, sourceView, completionHandler) in
            self.addGroup(indexPath)
            completionHandler(true)
        }
        
        addAction.backgroundColor = UIColor(red: 0, green: 0.75, blue: 0, alpha: 1)
        addAction.image = UIImage(systemName: "plus.square")
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [addAction])
        
        return swipeConfiguration
    }
    
    func textChanged(_ text: String?) {
        guard let searchText = text else { return }
        
        if searchText != "" {
            service.getSearchGroups(query: searchText) { [weak self] (groups) in
                self?.availGroupsArray = groups
                self?.tableView.reloadData()
            }
        } else {
            if searchBar.active {
                availGroupsArray = []
            } else {
                availGroupsArray = readGroupsArray
            }
            tableView.reloadData()
        }
    }
    
    // MARK: Program Logic
    
    func groupIsAdded(_ id: Int) -> Bool {
        let ids: [Int] = readGroupsArray.map { $0.id }
        return ids.contains(id)
    }
    
    func addGroup(_ indexPath: IndexPath) {
        if !groupIsAdded(availGroupsArray[indexPath.row].id) {
            readGroupsArray.append(availGroupsArray[indexPath.row])
        }
     }
    
}
