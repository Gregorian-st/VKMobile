//
//  FriendsView.swift
//  VKMobile
//
//  Created by Grigory on 27.01.2021.
//

import UIKit

protocol FriendsViewDelegate: AnyObject {
    func userSelected(at index: Int)
}

final class FriendsView: UIView, UITableViewDataSource, UITableViewDelegate, CustomSearchBarDelegate, UserLetterPickerDelegate {
    
    weak var delegate: FriendsViewDelegate?
    
    private var firstLettersArray: [String] = []
    private var firstLettersDict: Dictionary<String, UInt> = [:]
    var myFriendsArray: [UserVK] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userLetterPicker: UserLetterPicker!
    @IBOutlet weak var searchBar: CustomSearchBar!
    
    // MARK: - tableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return firstLettersArray.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sect = firstLettersArray[section]
        return Int(firstLettersDict[sect]!)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FriendsHeader") as? FriendsHeader else { return nil }
        headerView.titleLabel.text = "- \(firstLettersArray[section]) -"
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendsCell", for: indexPath) as! FriendsTableViewCell
        let index = getUserIndex(for: indexPath)
        
        cell.userNameLabel.text = "\(myFriendsArray[index].surname), \(myFriendsArray[index].name)"
        cell.userAgeLabel.text = myFriendsArray[index].birthdayFormatted != "" ? "Birthday: \(myFriendsArray[index].birthdayFormatted)" : "Birthday is hidden"
        cell.userAvatarImage.imageName = myFriendsArray[index].avatar
        
        cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        cell.userNameLabel.alpha = 0
        cell.userAgeLabel.alpha = 0
        cell.userAvatarImage.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
            cell.transform = .identity
            cell.userNameLabel.alpha = 1
            cell.userAgeLabel.alpha = 1
            cell.userAvatarImage.alpha = 1
        }, completion: nil)
        
        return cell
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0.0
    }
    
    func textChanged(_ text: String?) {
        guard let searchText = text else { return }
        fillMyFriends(searchText)
        getFirstLetters()
        tableView.reloadData()
    }
    
    func letterPicked(_ letter: String) {
        guard let index = firstLettersArray.firstIndex(of: letter) else { return }
        let indexPath = IndexPath(row: 0, section: index)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    // MARK: - Program Logic
    
    func registerElements() {
        tableView.register(UINib(nibName: "FriendsHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "FriendsHeader")
        tableView.backgroundColor = .white
        
        userLetterPicker.delegate = self
        searchBar.delegate = self
    }
    
    func getFirstLetters() {
        var tempSet: Set<String> = []
        firstLettersDict = [:]
        for user in myFriendsArray {
            let ts: String = String(user.surname.first!).uppercased()
            let (isInserted, _) = tempSet.insert(ts)
            if isInserted {
                firstLettersDict.updateValue(1, forKey: ts)
            } else {
                var val = UInt(firstLettersDict[ts]!)
                val += 1
                firstLettersDict.updateValue(val, forKey: ts)
            }
        }
        firstLettersArray = tempSet.sorted()
        userLetterPicker.letters = firstLettersArray
    }
    
    func getUserIndex(for indexPath: IndexPath) -> Int {
        var index:Int = 0
        if indexPath.section == 0 {
            index = indexPath.item
        } else {
            for i in 0...indexPath.section - 1 {
                let sect = firstLettersArray[i]
                index += Int(firstLettersDict[sect]!)
            }
            index += indexPath.item
        }
        
        return index
    }
    
    func fillMyFriends(_ filterFriendName: String) {
        myFriendsArray.removeAll()
        for friend in mainUser.friendsArray {
            if filterFriendName == "" {
                myFriendsArray.append(friend)
            } else if friend.name.localizedCaseInsensitiveContains(filterFriendName)||friend.surname.localizedCaseInsensitiveContains(filterFriendName) {
                myFriendsArray.append(friend)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userIndex = getUserIndex(for: indexPath)
        delegate?.userSelected(at: userIndex)
    }
    
}
