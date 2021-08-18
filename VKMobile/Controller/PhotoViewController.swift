//
//  PhotoViewController.swift
//  VKMobile
//
//  Created by Grigory on 09.11.2020.
//

import UIKit

class PhotoViewController: UIViewController {
    
    enum Direction {
        case left, right, none
        
        init(x: CGFloat) {
            if x == 0 {
                self = .none
            } else {
                self = x > 0 ? .right : .left
            }
        }
    }
    
    var photosArray: [PhotoVK] = []
    
    var photoID: Int = 0
    private var firstViewActive: Bool = false
    private var animator: UIViewPropertyAnimator!
    private let photoDirectory = "photo"
    
    @IBOutlet var photoView1: UIImageView!
    @IBOutlet var photoView2: UIImageView!

    override func viewWillAppear(_ animated: Bool) {
        firstViewActive = true
        if photosArray.count > 0 {
            if let imageURL = URL.init(string: photosArray[photoID].photoName) {
                photoView1.loadCached(url: imageURL, directory: photoDirectory)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan))
        self.view.addGestureRecognizer(pan)
    }
    
    @objc private func onPan(_ recognizer: UIPanGestureRecognizer) {
        guard let panView = recognizer.view else { return }
        
        let translation = recognizer.translation(in: panView)
        let direction = Direction(x: translation.x)
        
        switch recognizer.state {
        case .began:
            animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut, animations: {
                self.photoView1.alpha = 0
                self.photoView1.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            })
            if canSlide(direction) {
                var newPhotoID: Int
                if direction == .none {
                    newPhotoID = photoID
                } else {
                    newPhotoID = direction == .left ? photoID + 1 : photoID - 1
                }
                if let imageURL = URL.init(string: photosArray[newPhotoID].photoName) {
                    photoView2.loadCached(url: imageURL, directory: photoDirectory)
                }
                let offsetX = direction == .left ? view.bounds.width : -view.bounds.width
                photoView2.frame = view.bounds.offsetBy(dx: offsetX, dy: 0)
                
                animator.addAnimations ({
                    self.photoView2.center = self.photoView1.center
                }, delayFactor: 0.2)
            }
            
            animator.addCompletion{ (position) in
                if direction != .none {
                    self.photoID = direction == .left ? self.photoID + 1 : self.photoID - 1
                }
                self.photoView1.image = nil
                if let imageURL = URL.init(string: self.photosArray[self.photoID].photoName) {
                    self.photoView1.loadCached(url: imageURL, directory: self.photoDirectory)
                }
                self.photoView1.alpha = 1
                self.photoView1.transform = .identity
                
            }
            animator.pauseAnimation()
        case .changed:
            let relativeTranslation = abs(translation.x) / (recognizer.view?.bounds.width ?? 1)
            let progress = max(0, min (1, relativeTranslation))
            let relativeTranslationY = translation.y / (recognizer.view?.bounds.height ?? 1)
            
            if relativeTranslationY > 0.2 {
                photoView1.alpha = 1
                self.performSegue(withIdentifier: "unwindFromPhoto", sender: self)
            } else {
                if relativeTranslation > 0.1 {
                    animator.fractionComplete = progress
                }
            }
        case .ended:
            if canSlide(direction), animator.fractionComplete > 0.5 {
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            } else {
                animator.stopAnimation(true)
                UIView.animate(withDuration: 0) {
                    self.photoView1.transform = .identity
                    self.photoView1.alpha = 1
                    let offsetX = direction == .left ? self.view.bounds.width : -self.view.bounds.width
                    self.photoView2.frame = self.view.bounds.offsetBy(dx: offsetX, dy: 0)
                }
            }
        default:
            break
        }
    }
        
    private func canSlide(_ direction: Direction) -> Bool {
        if direction == .none {
            return false
        }
        if direction == .left {
            return photoID < photosArray.count - 1
        } else {
            return photoID > 0
        }
    }

}
