//
//  UserLetterPicker.swift
//  VKMobile
//
//  Created by Grigory on 27.10.2020.
//

import UIKit

protocol UserLetterPickerDelegate: AnyObject {
    func letterPicked(_ letter: String)
}

class UserLetterPicker: UIView {
    
    weak var delegate: UserLetterPickerDelegate?

    var letters: [String] = [] {
        didSet {
            reloadButtons()
        }
    }
    
    private var buttons:[UIButton] = []
    private var lastPressedButton: UIButton?
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()
    
    private func setupView() {
        backgroundColor = .clear
        setupButtons()
        
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        let pan = UIPanGestureRecognizer(target: self,
                                         action: #selector(panAction))
        addGestureRecognizer(pan)
    }
    
    private func setupButtons() {
        for letter in letters {
            let button = UIButton(type: .system)
            button.setTitle(letter.uppercased(), for: .normal)
            button.addTarget(self,
                             action: #selector(letterTapped),
                             for: .touchDown)
            buttons.append(button)
            stackView.addArrangedSubview(button)
            button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        }
    }
    
    override init(frame: CGRect) {
        super.init (frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder ) {
        super.init (coder: aDecoder)
        self.setupView()
    }
    
    @objc private func letterTapped(_ sender: UIButton) {
        guard lastPressedButton != sender else { return }
        lastPressedButton = sender
        let letter = sender.title(for: .normal) ?? ""
        delegate?.letterPicked(letter)
    }
    
    @objc private func panAction(_ recognizer: UIPanGestureRecognizer) {
        let anchorPoint = recognizer.location(in: self)
        let buttonHeight = bounds.height / CGFloat(buttons.count)
        let buttonIndex = Int(anchorPoint.y / buttonHeight)
        
        if (buttonIndex < 0)||(buttonIndex >= buttons.count) {
            unhighlightButtons()
            return
        }
        
        let button = buttons[buttonIndex]
        unhighlightButtons()
        button.isHighlighted = true
        letterTapped(button)
        
        switch recognizer.state {
        case .ended:
            unhighlightButtons()
        default:
            break
        }
        
    }
    
    private func unhighlightButtons() {
        buttons.forEach { $0.isHighlighted = false }
    }
    
    private func reloadButtons() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        buttons = []
        lastPressedButton = nil
        setupButtons()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
