//
//  GroupsTableViewCell.swift
//  VKMobile
//
//  Created by Grigory on 18.10.2020.
//

import UIKit

class GroupsTableViewCell: UITableViewCell {

    @IBOutlet weak var groupImage: ShadowImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var isClosedLabel: UILabel!
    
    func configure (with viewModel: GroupViewModel) {
        groupNameLabel.text = viewModel.name
        groupImage.imageName = viewModel.image
        isClosedLabel.text = viewModel.isClosed
    }
    
}
