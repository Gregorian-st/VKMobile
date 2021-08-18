//
//  NewsTextTableViewCell.swift
//  VKMobile
//
//  Created by Grigory on 04.11.2020.
//

import UIKit

protocol NewsTextCellSizeDelegate: AnyObject {
    func newsTextCellHeightUpdated(for newsID: Int, desiredHeight: CGFloat)
}

class NewsTextTableViewCell: UITableViewCell, UITextViewDelegate {
    
    weak var delegate: NewsTextCellSizeDelegate?
    
    var newsID: Int = 0
    var calculatedHeight: CGFloat = 0
    var desiredHeight: CGFloat = 0
    let maxHeight: CGFloat = 200
    let spanHeight: CGFloat = 10
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var expandButton: UIButton!
    
    @IBAction func ExpandButtonTapped(_ sender: UIButton) {
        calculateHeight()
        if desiredHeight <= maxHeight {
            desiredHeight = calculatedHeight
            sender.setImage(UIImage(systemName: "chevron.up.circle"), for: .normal)
        } else {
            desiredHeight = maxHeight
            sender.setImage(UIImage(systemName: "chevron.down.circle"), for: .normal)
        }
        self.frame.size = CGSize(width: self.frame.width, height: desiredHeight)
        delegate?.newsTextCellHeightUpdated(for: newsID, desiredHeight: desiredHeight)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.textView.addObserver(self, forKeyPath: "text", options: [.new, .old], context: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? UITextView == self.textView {
            calculateHeight()
            if calculatedHeight <= maxHeight {
                desiredHeight = calculatedHeight
                expandButton.isHidden = true
            } else {
                desiredHeight = maxHeight
                expandButton.setImage(UIImage(systemName: "chevron.down.circle"), for: .normal)
                expandButton.isHidden = false
            }
        }
    }
    
    func calculateHeight() {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        calculatedHeight = newSize.height + spanHeight
    }
    
}
