//
//  NewsViewController.swift
//  VKMobile
//
//  Created by Grigory on 03.11.2020.
//

import UIKit

var newsArray: [NewsVK] = []

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching, NewsTextCellSizeDelegate {
    
    private lazy var service = VKAPIService()
    private lazy var proxy = VKAPIServiceProxy(service: service)
    private var refreshControl = UIRefreshControl()
    private var nextFrom: String = ""
    private var isLoading: Bool = false
    private let maxTextHeight: CGFloat = 200
    
    private lazy var photoCache = PhotoCacheServiceAlt()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerNibs()
        navBarCustomization()
        tableView.prefetchDataSource = self
        tableView.delegate = self
        
        // RefreshControl
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if newsArray.isEmpty {
            getAllNews()
        } else {
            getNewsRefresh()
        }
    }
    
    @objc func refresh(_ sender: AnyObject) {
        if newsArray.isEmpty {
            getAllNews()
        } else {
            getNewsRefresh()
        }
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if newsArray.isEmpty {
            tableView.showEmptyMessage("The news are updating now...\nPlease wait")
        } else {
            tableView.hideEmptyMessage()
        }
        return newsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cnt = newsArray[section].postType == .mix ? 2 : 1
        return cnt
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 1:
            return getPhotoCellHeight(indexPath: indexPath)
        default:
            if newsArray[indexPath.section].postType != .photo {
                return newsArray[indexPath.section].desiredTextHeight
            } else {
                return getPhotoCellHeight(indexPath: indexPath)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "NewsHeader") as? NewsHeader else { return nil }
        headerView.creatorAvatarImage.imageName = newsArray[section].publisherAvatar
        headerView.creatorNameLabel.text = newsArray[section].publisherFullName
        headerView.dateLabel.text = newsArray[section].dateStr
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "NewsFooter") as? NewsFooter else { return nil }
        let item = newsArray[section]
        
        footerView.likeButton.tag = section
        footerView.likeButton.likeCount = item.likeCount
        footerView.likeButton.isActivated = item.liked
        footerView.viewCount = item.viewCount
        footerView.repostCount = item.repostCount
        footerView.commentCount = item.commentCount
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 1:
            return getPhotoCell(indexPath: indexPath)
        default:
            if newsArray[indexPath.section].postType != .photo {
                let cell = tableView.dequeueReusableCell(withIdentifier: "newsText", for: indexPath) as! NewsTextTableViewCell
                cell.backgroundView?.backgroundColor = .white
                cell.contentView.backgroundColor = .white
                cell.textView.text = newsArray[indexPath.section].textFull
                cell.newsID = indexPath.section
                newsArray[indexPath.section].desiredTextHeight = cell.desiredHeight
                
                cell.delegate = self
                return cell
            } else {
                return getPhotoCell(indexPath: indexPath)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard
            let maxNewsSection = indexPaths.map({ $0.section }).max(),
            maxNewsSection > newsArray.count - 5,
            isLoading == false
        else { return }
        
        getNewsMore()
    }
    
    func newsTextCellHeightUpdated(for newsID: Int, desiredHeight: CGFloat) {
        newsArray[newsID].desiredTextHeight = desiredHeight
        var indexPath = IndexPath(row: 0, section: 1)
        if newsID > 0 {
            indexPath = IndexPath(row: 0, section: newsID - 1)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Program Logic
    
    func registerNibs() {
        tableView.register(UINib(nibName: "NewsHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "NewsHeader")
        tableView.register(UINib(nibName: "NewsFooter", bundle: nil), forHeaderFooterViewReuseIdentifier: "NewsFooter")
        
        tableView.register(UINib(nibName: "NewsImageTableViewCell", bundle: nil), forCellReuseIdentifier: "newsImage")
        tableView.register(UINib(nibName: "NewsImages3TableViewCell", bundle: nil), forCellReuseIdentifier: "newsImages3")
        tableView.register(UINib(nibName: "NewsImages2TableViewCell", bundle: nil), forCellReuseIdentifier: "newsImages2")
        tableView.register(UINib(nibName: "NewsTextTableViewCell", bundle: nil), forCellReuseIdentifier: "newsText")
    }
    
    func navBarCustomization() {
        navigationController?.navigationBar.backgroundColor = .white
        
        if let font = UIFont.brandVKFont {
            navigationController?.navigationBar.largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.brandVKColor,
                NSAttributedString.Key.font: font
            ]
        }
    }
    
    func getPhotoCell(indexPath: IndexPath) -> UITableViewCell {
        if newsArray[indexPath.section].images.count > 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "newsImages3", for: indexPath) as! NewsImages3TableViewCell
            if let imageURL = URL.init(string: newsArray[indexPath.section].images[0]) {
                cell.photoImage1.load(url: imageURL)
            }
            if let imageURL = URL.init(string: newsArray[indexPath.section].images[1]) {
                cell.photoImage2.load(url: imageURL)
            }
            if let imageURL = URL.init(string: newsArray[indexPath.section].images[2]) {
                cell.photoImage3.load(url: imageURL)
            }
            if let imageURL = URL.init(string: newsArray[indexPath.section].images[3]) {
                cell.photoImage4.load(url: imageURL)
            }
            cell.photoImage4.alpha = 1
            cell.plusLabel.text = ""
            if newsArray[indexPath.section].images.count > 4 {
                cell.photoImage4.alpha = 0.5
                let plus = newsArray[indexPath.section].images.count - 4
                cell.plusLabel.text = "+\(plus)"
            }
            return cell
        } else if newsArray[indexPath.section].images.count > 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "newsImages3", for: indexPath) as! NewsImages3TableViewCell
            if let imageURL = URL.init(string: newsArray[indexPath.section].images[0]) {
                cell.photoImage1.load(url: imageURL)
            }
            if let imageURL = URL.init(string: newsArray[indexPath.section].images[1]) {
                cell.photoImage2.load(url: imageURL)
            }
            if let imageURL = URL.init(string: newsArray[indexPath.section].images[2]) {
                cell.photoImage3.load(url: imageURL)
            }
            cell.photoImage4.image = nil
            cell.plusLabel.text = ""
            return cell
        } else if newsArray[indexPath.section].images.count == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "newsImages2", for: indexPath) as! NewsImages2TableViewCell
            if let imageURL = URL.init(string: newsArray[indexPath.section].images[0]) {
                cell.photoImage1.load(url: imageURL)
            }
            if let imageURL = URL.init(string: newsArray[indexPath.section].images[1]) {
                cell.photoImage2.load(url: imageURL)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "newsImage", for: indexPath) as! NewsImageTableViewCell
            if newsArray[indexPath.section].images.count > 0 {
                if let imageURL = URL.init(string: newsArray[indexPath.section].images[0]) {
                    cell.photoImage.load(url: imageURL)
                }
            }
            return cell
        }
    }
    
    func getPhotoCellHeight(indexPath: IndexPath) -> CGFloat {
        var height: CGFloat
        if newsArray[indexPath.section].images.count == 2 {
            height = tableView.frame.width / 2
        } else {
            height = tableView.frame.width
        }
        return height
    }
    
    func getAllNews() {
        proxy.getNewsFeed(startFrom: "") { [weak self] (news, next) in
            newsArray = news
            self?.nextFrom = next
            self?.tableView.reloadData()
            self?.refreshControl.endRefreshing()
        }
    }
    
    func getNewsRefresh() {
        guard
            let startTimeDbl = newsArray.first?.date
        else {
            refreshControl.endRefreshing()
            return
        }
        let startTime = String(startTimeDbl+1)
        proxy.getNewsFeedRefresh(startTime: startTime) { [weak self] (news) in
            newsArray = news + newsArray
            self?.tableView.reloadData()
            self?.refreshControl.endRefreshing()
        }
    }
    
    func getNewsMore() {
        isLoading = true
        proxy.getNewsFeed(startFrom: nextFrom) { [weak self] (news, next) in
            let oldNewsCount = newsArray.count
            let newSections = ( oldNewsCount..<( oldNewsCount + news.count ) ).map { $0 }
            
            newsArray.append(contentsOf: news)
            self?.nextFrom = next
            print(next)
            self?.tableView.insertSections(IndexSet(newSections), with: .automatic)
            self?.isLoading = false
        }
    }
    
}
