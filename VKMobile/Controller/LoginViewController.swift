//
//  LoginViewController.swift
//  VKMobile
//
//  Created by Grigory on 10.10.2020.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var usernameTextField: UITextField! {
        didSet {
            usernameTextField.layer.cornerRadius = usernameTextField.frame.size.height / 2
            usernameTextField.layer.borderWidth = 0.2
            usernameTextField.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.layer.cornerRadius = passwordTextField.frame.size.height / 2
            passwordTextField.layer.borderWidth = 0.2
            passwordTextField.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.layer.cornerRadius = loginButton.frame.size.height / 2
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        (animationView as! AnimationView).drawAnimationContent()
        (animationView as! AnimationView).animate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            for view in self.animationView.subviews {
                view.removeFromSuperview()
            }
            self.animationView.removeFromSuperview()
        }
        
        // for test
        usernameTextField.text = "User"
        passwordTextField.text = "password"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let checkAccess = checkCredentials()
        
        if !checkAccess { showAlert() }
        
        return checkAccess
    }
    
    // MARK: IBActions
    
    @IBAction func scrollTapped(_ sender: UIGestureRecognizer) {
        scrollView.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
    }
    
    @objc func keyboardWillHide() {
        scrollView.contentInset = .zero
    }

    // MARK: Program Logic
    
    func checkCredentials() -> Bool {
        guard let login = usernameTextField.text,
              let password = passwordTextField.text else { return false }
        if login == "User" && password == "password" {
            return true
        } else {
            return false
        }
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "VKMobile",
                                                message: "Wrong credentials",
                                                preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

}

