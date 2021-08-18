//
//  UITableViewExt.swift
//  VKMobile
//
//  Created by Grigory on 31.01.2021.
//

import UIKit

extension UITableView {
    
    func showEmptyMessage(_ message: String) {
        let label = UILabel()
        label.textColor = .gray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.text = message
        
        self.backgroundView = label
    }
    
    func hideEmptyMessage() {
        self.backgroundView = nil
    }
}
