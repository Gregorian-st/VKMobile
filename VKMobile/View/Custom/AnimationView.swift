//
//  AnimationView.swift
//  VKMobile
//
//  Created by Grigory on 06.11.2020.
//

import UIKit

class AnimationView: UIView {
    
    enum AnimationType {
        case dots, cloud
    }
    
    let animationType = AnimationType.cloud
    
    override func layoutMarginsDidChange() {
        drawAnimationContent()
        animate()
    }
    
    public func drawAnimationContent() {
        backgroundColor = UIColor.white
        let positionHeight = Int(frame.height)
        let positionWidth = Int(frame.width)
        for view in subviews {
            view.removeFromSuperview()
        }
        
        switch animationType {
        case .dots:
            let circleSide = 10
            let circleSpacing = 10
            let yPosition = Int(positionHeight / 2) - circleSide / 2
            let circle1 = CircleAnimateView.init(frame: CGRect(x: Int(positionWidth / 2) - circleSpacing - Int(1.5 * Double(circleSide)), y: yPosition, width: circleSide, height: circleSide))
            let circle2 = CircleAnimateView.init(frame: CGRect(x: Int(positionWidth / 2) - Int(0.5 * Double(circleSide)), y: yPosition, width: circleSide, height: circleSide))
            let circle3 = CircleAnimateView.init(frame: CGRect(x: Int(positionWidth / 2) + circleSpacing + Int(0.5 * Double(circleSide)), y: yPosition, width: circleSide, height: circleSide))
            circle1.backgroundColor = backgroundColor
            circle1.color = UIColor.gray.cgColor
            circle2.backgroundColor = backgroundColor
            circle2.color = UIColor.gray.cgColor
            circle3.backgroundColor = backgroundColor
            circle3.color = UIColor.gray.cgColor

            addSubview(circle1)
            addSubview(circle2)
            addSubview(circle3)
        case .cloud:
            let cloudWidth = 200
            let cloudHeight = 80
            let cloud1 = CloudAnimateView.init(frame: CGRect.init(x: Int(positionWidth / 2 - cloudWidth / 2), y: Int(positionHeight / 2 - cloudHeight / 2), width: cloudWidth, height: cloudHeight))
            cloud1.backgroundColor = backgroundColor
            addSubview(cloud1)
        }
    }
    
    public func animate() {
        switch animationType {
        case .dots:
            guard subviews.count > 2 else { return }
            
            UIView.animate(withDuration: 0.9, delay: 0, options: [.repeat], animations: {
                self.subviews[0].alpha = 0.2
            })
            UIView.animate(withDuration: 0.9, delay: 0.3, options: [.repeat], animations: {
                self.subviews[1].alpha = 0.2
            })
            UIView.animate(withDuration: 0.9, delay: 0.6, options: [.repeat], animations: {
                self.subviews[2].alpha = 0.2
            })
        default:
            return
        }
    }
}
