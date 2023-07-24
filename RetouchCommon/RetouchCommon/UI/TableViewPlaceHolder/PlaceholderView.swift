//
//  TableViewPlaceholder.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 8/8/17.

import UIKit

public protocol PlaceholderViewDelegate: AnyObject {
    func didTapActionButton(from view: PlaceholderView)
}

public final class PlaceholderView: BaseCustomView {
    // MARK: - Propeties
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var textContentView: UIView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var actionButton: PurpleButton!

    // Delegate
    public weak var delegate: PlaceholderViewDelegate?

    // MARK: - initialize
    public override func initialize() {
        addSelfNibUsingConstraints(bundle: Bundle.common)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .white
        titleLabel.font = .kBigTitleText
        titleLabel.textColor = UIColor.kTextDarkGray
        
        subtitleLabel.font = .kTitleBigText
        subtitleLabel.textColor = UIColor.kGrayText
    }
}

// MARK: - Public methods
extension PlaceholderView {
    public func setTitle(_ text: String?) {
        titleLabel.text = text
    }
    
    public func setSubtitle(_ text: String?) {
        subtitleLabel.text = text
    }
    
    public func setImage(_ image: UIImage?) {
        imageView.image = image
    }

    public func setActionButtonTitle(_ text: String?) {
        actionButton.setTitle(text, for: .normal)
    }

    public func setActionButtonIsHidden(_ isHidden: Bool) {
        actionButton.isHidden = isHidden
    }
}

// MARK: - Actions
private extension PlaceholderView {
    @IBAction func actionOfActionButton(_ sender: Any) {
        delegate?.didTapActionButton(from: self)
    }
}
