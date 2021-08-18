//
//  CloudAnimateView.swift
//  VKMobile
//
//  Created by Grigory on 10.11.2020.
//

import UIKit

class CloudAnimateView: UIView {

    var color: CGColor = UIColor.gray.cgColor {
        didSet {
            draw(bounds)
        }
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let middleX = rect.width * 0.5
        let middleY = rect.height * 0.5
        let lineWidth: CGFloat = 5
        
        let cloudPath = UIBezierPath()
        cloudPath.move(to: CGPoint(x: 0.75 * middleX, y: 0.75 * middleY))
        cloudPath.addQuadCurve(to: CGPoint(x: 1.25 * middleX, y: 0.75 * middleY), controlPoint: CGPoint(x: middleX, y: 0))
        cloudPath.addQuadCurve(to: CGPoint(x: 1.25 * middleX, y: 1.5 * middleY), controlPoint: CGPoint(x: 0.85 * rect.width, y: 1.125 * middleY))
        cloudPath.addQuadCurve(to: CGPoint(x: 0.75 * middleX, y: 1.5 * middleY), controlPoint: CGPoint(x: middleX, y: 0.9 * rect.height))
        cloudPath.addQuadCurve(to: CGPoint(x: 0.75 * middleX, y: 0.75 * middleY), controlPoint: CGPoint(x: 0.2 * rect.width, y: middleY))
        cloudPath.close()
        
        context.setStrokeColor(UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.1).cgColor)
        context.setLineWidth(lineWidth)
        context.move(to: CGPoint(x: 0.75 * middleX, y: 0.75 * middleY))
        context.addQuadCurve(to: CGPoint(x: 1.25 * middleX, y: 0.75 * middleY), control: CGPoint(x: middleX, y: 0))
        context.addQuadCurve(to: CGPoint(x: 1.25 * middleX, y: 1.5 * middleY), control: CGPoint(x: 0.85 * rect.width, y: 1.125 * middleY))
        context.addQuadCurve(to: CGPoint(x: 0.75 * middleX, y: 1.5 * middleY), control: CGPoint(x: middleX, y: 0.9 * rect.height))
        context.addQuadCurve(to: CGPoint(x: 0.75 * middleX, y: 0.75 * middleY), control: CGPoint(x: 0.2 * rect.width, y: middleY))
        context.closePath()
        context.strokePath()
        
        let cloudLayer = CAShapeLayer()
        cloudLayer.fillColor = nil
        cloudLayer.strokeColor = UIColor.black.cgColor
        cloudLayer.lineWidth = lineWidth
        
        cloudLayer.path = cloudPath.cgPath
        layer.addSublayer(cloudLayer)

        let strokeStartAnimation = CABasicAnimation (keyPath: "strokeStart" )
        strokeStartAnimation.fromValue = 0
        strokeStartAnimation.toValue = 1
        let strokeEndAnimation = CABasicAnimation (keyPath: "strokeEnd" )
        strokeEndAnimation.fromValue = 0.1
        strokeEndAnimation.toValue = 1.2
        let animationGroup = CAAnimationGroup ()
        animationGroup.duration = 1
        animationGroup.repeatCount = .infinity
        animationGroup.animations = [strokeStartAnimation, strokeEndAnimation]
        cloudLayer.add(animationGroup, forKey: nil)
        
    }

}
