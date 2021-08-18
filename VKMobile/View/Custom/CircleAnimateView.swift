//
//  CircleAnimateView.swift
//  VKMobile
//
//  Created by Grigory on 06.11.2020.
//

import UIKit

class CircleAnimateView: UIView {
    
    var color: CGColor = UIColor.gray.cgColor {
        didSet {
            draw(bounds)
        }
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color)
        let radius = rect.width / 2
        context.fillEllipse(in: CGRect(x: rect.midX - radius,
                                       y: rect.midY - radius,
                                       width: radius * 2,
                                       height: radius * 2 ))
    }

}
