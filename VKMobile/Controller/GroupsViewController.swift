//
//  GroupsTableViewController.swift
//  VKMobile
//
//  Created by Grigory on 14.10.2020.
//

import UIKit
import RealmSwift

class GroupsTableViewController: UIViewController {
    
    lazy var contentView = self.view as! GroupsView
    
    private let service = GroupsAdapter()
    
    var session = Session.instance
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBarCustomization()
        contentView.registerElements()
        
        // RefreshControl
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        contentView.tableView.addSubview(refreshControl)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getGroups()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        getGroups()
        refreshControl.endRefreshing()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let searchViewController = segue.destination as? SearchViewController else { return }
        searchViewController.userId = mainUser.id
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
    
    func getGroups() {
        service.getGroups(userId: session.userId) { [ weak self ] groups in
            self?.contentView.myGroupsArray = groups
            self?.contentView.fillMyGroups("")
        }
    }
    
}
