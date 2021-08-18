//
//  WebLoginViewController.swift
//  VKMobile
//
//  Created by Grigory on 25.11.2020.
//

import UIKit
import WebKit
//import FirebaseDatabase

class WebLoginViewController: UIViewController, WKNavigationDelegate {
    
    var usersLogged: [Int] = []
    var usersLoggedReadFlag: Bool = false
    let session = Session.instance
//    let dbRef = Database.database().reference(withPath: "usersLoggedId")
    
    // MARK: - Outlets
    
    @IBOutlet weak var loginWebView: WKWebView! {
        didSet {
            loginWebView.navigationDelegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        readUsersLogged()
        login()
    }
    
    // MARK: - Program Logic
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let url = navigationResponse.response.url, url.path == "/blank.html", let fragment = url.fragment else {
            decisionHandler(.allow)
            return
        }
        let params = fragment.components(separatedBy: "&").map{ $0.components(separatedBy: "=") }.reduce([String : String]()) { result, param in
            var dict = result
            let key = param[0]
            let value = param[1]
            dict[key] = value
            return dict
        }
        
        session.token = params["access_token"] ?? ""
        session.userId = Int(params["user_id"] ?? "") ?? 0
        print(session.token)
        
//        writeUsersLogged(session.userId)
        
        if session.token != "" && session.userId != 0 {
            performSegue(withIdentifier: "Friends", sender: nil)
        } else {
            showAlert()
        }
        decisionHandler(.cancel)
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "VKMobile",
                                                message: "Invalid connection parameters received",
                                                preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func login() {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "oauth.vk.com"
        urlComponents.path = "/authorize"
        urlComponents.queryItems = [
            URLQueryItem (name: "client_id", value: "7675949"),
            URLQueryItem (name: "display", value: "mobile"),
            URLQueryItem (name: "redirect_uri", value: "https://oauth.vk.com/blank.html"),
            URLQueryItem (name: "scope", value: "6270431"),
            URLQueryItem (name: "response_type", value: "token"),
            URLQueryItem (name: "v", value: "5.126"),
            URLQueryItem (name: "revoke", value: "1")
        ]
        let request = URLRequest (url: urlComponents.url!)
//        print(request)
        loginWebView.load(request)
    }
    
//    func readUsersLogged() {
//        dbRef.observeSingleEvent(of: .value) { [weak self] (snapshot) in
//            guard let users = snapshot.value as? [Int] else { return }
//            self?.usersLogged = users
//            self?.usersLoggedReadFlag = true
//        }
//    }
    
//    func writeUsersLogged(_ id: Int) {
//        if !usersLogged.contains(id) {
//            usersLogged.append(session.userId)
//        }
//        if  usersLoggedReadFlag {
//            dbRef.setValue(usersLogged)
//        }
//    }

}
