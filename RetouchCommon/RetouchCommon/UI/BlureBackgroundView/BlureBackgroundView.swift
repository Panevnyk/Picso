//
//  BlureBackgroundView.swift
//  RetouchCommon
//
//  Created by Panevnyk Vlad on 26.11.2021.
//

import UIKit

public class BlureBackgroundView: BaseCustomView, DetailAnimable {
    @IBOutlet private var visualEfectView: UIVisualEffectView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    
    public override func initialize() {
        addSelfNibUsingConstraints(bundle: Bundle.common)
        
        alpha = 0
        visualEfectView.alpha = 0.9
        
        titleLabel.textColor = .black
        titleLabel.font = UIFont.kBigTitleText
    }
    
    public func setTitle(_ text: String) {
        titleLabel.text = text
    }
    
    public func setImage(_ image: UIImage?) {
        imageView.image = image
    }
}
