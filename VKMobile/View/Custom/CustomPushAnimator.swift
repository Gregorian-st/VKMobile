//
//  CustomPushAnimator.swift
//  VKMobile
//
//  Created by Grigory on 11.11.2020.
//

import UIKit

final class CustomPushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.75
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let source = transitionContext.viewController(forKey: .from),
            let destination = transitionContext.viewController(forKey: .to)
        else { return }
        
        transitionContext.containerView.addSubview(destination.view)
        
        source.view.layer.anchorPoint = CGPoint(x: 0, y: 0)
        source.view.frame.origin = CGPoint(x: 0, y: 0)
        destination.view.layer.anchorPoint = CGPoint(x: 1, y: 0)
        destination.view.frame.origin = CGPoint(x: 0, y: 0)
        destination.view.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        
        UIView.animateKeyframes(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: [],
            animations: {
                UIView.addKeyframe(
                    withRelativeStartTime: 0,
                    relativeDuration: 0.75,
                    animations: {
                        let translation = CGAffineTransform(rotationAngle: .pi / 2)
                        source.view.transform = translation
                    })
                UIView.addKeyframe(
                    withRelativeStartTime: 0,
                    relativeDuration: 0.75,
                    animations: {
                        let translation = CGAffineTransform(rotationAngle: .pi * 2)
                        destination.view.transform = translation
                    })
                UIView.addKeyframe(
                    withRelativeStartTime: 0.8,
                    relativeDuration: 1,
                    animations: {
                        destination.view.transform = .identity
                    })
            },
            completion: { finished in
                let finishedAndNotCancelled = finished && !transitionContext.transitionWasCancelled
                
                if finishedAndNotCancelled {
                    source.view.transform = .identity
                }
                
                transitionContext.completeTransition(finishedAndNotCancelled)
            })
    }
}
