//
//  UIColorExt.swift
//  VKMobile
//
//  Created by Grigory on 19.11.2020.
//

import UIKit

extension UIColor {
    
    convenience init(red: UInt, green: UInt, blue: UInt) {
        let redValue = CGFloat(red) / 255
        let greenValue = CGFloat(green) / 255
        let blueValue = CGFloat(blue) / 255
        self.init(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0)
    }
    
}

extension UIColor {
    
    static let brandVKColor = UIColor(red: 39, green: 135, blue: 245)
    
}
