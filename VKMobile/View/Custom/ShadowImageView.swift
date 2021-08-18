//
//  ShadowImageView.swift
//  VKMobile
//
//  Created by Grigory on 21.10.2020.
//

import UIKit

@IBDesignable class ShadowImageView: UIView {
    
    @IBInspectable var imageName: String = "" {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var shadowColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0.25 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 4 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = .zero {
        didSet {
            setNeedsDisplay()
        }
    }
        
    func checkURL(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
    
    private func setupView() {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.width))
        if checkURL(urlString: imageName) {
            if let imageURL = URL.init(string: imageName) {
                imageView.loadCached(url: imageURL, directory: "avatar")
            }
        } else {
            if let myImage = UIImage(named: imageName) {
                imageView.image = myImage
            }
        }
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.layer.masksToBounds = true
        
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.width))
        backgroundView.layer.cornerRadius = imageView.frame.width / 2
        backgroundView.layer.masksToBounds = false
        backgroundView.layer.shadowColor = shadowColor.cgColor
        backgroundView.layer.shadowOpacity = shadowOpacity
        backgroundView.layer.shadowRadius = shadowRadius
        backgroundView.layer.shadowOffset = shadowOffset
        backgroundView.backgroundColor = .white
        
        self.addSubview(backgroundView)
        self.addSubview(imageView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        addGestureRecognizer(tap)
    }
    
    override init(frame: CGRect) {
        super.init (frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder ) {
        super.init (coder: aDecoder)
        self.setupView()
    }
    
    override func draw (_ rect: CGRect) {
        super.draw(rect)
        setupView()
    }
    
    @objc func avatarTapped(sender: UIGestureRecognizer) {
        transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0.5, options: [], animations: {
            self.transform = .identity
        }, completion: nil)
    }
    
}
