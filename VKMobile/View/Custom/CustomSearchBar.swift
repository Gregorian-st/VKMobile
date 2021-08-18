//
//  CustomSearchBar.swift
//  VKMobile
//
//  Created by Grigory on 07.11.2020.
//

import UIKit

protocol CustomSearchBarDelegate: AnyObject {
    func textChanged(_ text: String?)
}

class CustomSearchBar: UIView, UITextFieldDelegate {
    
    weak var delegate: CustomSearchBarDelegate?
    
    var view: UIView!
    
    var active: Bool {
        get {
            return cancelButtonTrailing.constant > 0
        }
    }
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
    }
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var textFieldLeading: NSLayoutConstraint!
    @IBOutlet weak var searchIconCenterX: NSLayoutConstraint!
    @IBOutlet weak var cancelButtonTrailing: NSLayoutConstraint!
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        textField.resignFirstResponder()
        textField.text = ""
        
        searchIconCenterX.constant = 0
        textFieldLeading.constant = 0
        cancelButtonTrailing.constant = -100
        
        UIView.animate(withDuration: 0.5) {
            self.layoutIfNeeded()
        }
        
        delegate?.textChanged(textField.text)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    private func xibSetup() {
        Bundle.main.loadNibNamed("CustomSearchBar", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let iconWidth = searchIcon.frame.width
        searchIconCenterX.constant = -(bounds.width / 2 - iconWidth)
        textFieldLeading.constant = iconWidth + 20
        cancelButtonTrailing.constant = 10
        
        UIView.animate(withDuration: 0.5) {
            self.layoutIfNeeded()
        }
        
        delegate?.textChanged(textField.text)
        
        return true
    }
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        delegate?.textChanged(sender.text)
    }
    
}
