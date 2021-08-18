//
//  LikeControl.swift
//  VKMobile
//
//  Created by Grigory on 21.10.2020.
//

import UIKit

protocol LikeControlDelegate: AnyObject {
    func likeChanged(_ id: Int, likeCount: Int, isActivated: Bool)
}

@IBDesignable class LikeControl: UIControl {
    
    weak var delegate: LikeControlDelegate?
    
    @IBInspectable var likeCount: Int = 0 {
        didSet {
            self.updateView()
            self.sendActions(for: .valueChanged)
        }
    }
    var isActivated: Bool = false {
        didSet {
            self.updateView()
            self.sendActions(for: .valueChanged)
        }
    }
    
    @IBInspectable var fontSize: CGFloat = 12 {
        didSet {
            self.updateFontSize()
        }
    }

    private var likeButton: UIButton!
    
    private func setupView() {
        likeButton = UIButton(type: .system)
        likeButton.setTitle("\(self.likeCount) 🤍", for : .normal)
        likeButton.setTitleColor(.lightGray, for : .normal)
        likeButton.setTitleColor(.lightGray, for : .selected)
        likeButton.titleLabel?.font = likeButton.titleLabel?.font.withSize(self.fontSize)
        likeButton.contentHorizontalAlignment = .trailing
        likeButton.contentVerticalAlignment = .center
        likeButton.addTarget(self,
                             action: #selector(touchButton(_ :)),
                             for : .touchUpInside)
        
        addSubview(likeButton)
     }
    
    private func updateView() {
        var title: String = ""
        var color: UIColor = .gray
        
        if self.isActivated {
            title = "\(self.likeCount) ❤️"
            color = .red
        } else {
            title = "\(self.likeCount) 🤍"
            color = .lightGray
        }
        UIView.transition(with: likeButton, duration: 0.5, options: [.transitionFlipFromLeft], animations: {
            self.likeButton.setTitle(title, for : .normal)
            self.likeButton.setTitleColor(color, for : .normal)
            self.likeButton.setTitleColor(color, for : .selected)
            self.likeButton.contentHorizontalAlignment = .trailing
            self.likeButton.contentVerticalAlignment = .center
        })
    }
    
    private func updateFontSize() {
        likeButton.titleLabel?.font = likeButton.titleLabel?.font.withSize(self.fontSize)
    }
    
    @objc private func touchButton(_ sender: UIButton) {
        if self.isActivated {
            self.likeCount -= 1
        } else {
            self.likeCount += 1
        }
        self.isActivated.toggle()
        self.sendActions(for: .valueChanged)
        delegate?.likeChanged(tag, likeCount: self.likeCount, isActivated: self.isActivated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        likeButton.frame = bounds
    }
    
    override init(frame: CGRect) {
        super.init (frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder ) {
        super.init (coder: aDecoder)
        self.setupView()
    }
 
}
