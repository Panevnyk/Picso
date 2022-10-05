//
//  MoreActionButton.swift
//  RetouchMore
//
//  Created by Vladyslav Panevnyk on 08.03.2021.
//

import UIKit
import RetouchCommon

final class MoreActionButton: BaseCustomView {
    // MARK: - Properties
    @IBOutlet var xibView: BaseSelectableView!
    @IBOutlet private var actionImageView: UIImageView!
    @IBOutlet private var actionTitle: UILabel!
    @IBOutlet private var rightArrowImageView: UIImageView!

    weak var delegate: BaseTapableViewDelegate? {
        get { xibView.delegate }
        set { xibView.delegate = newValue }
    }

    // MARK: - initialize
    override func initialize() {
        addSelfNibUsingConstraints(bundle: Bundle.more)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear

        xibView.layer.cornerRadius = 6
        xibView.layer.masksToBounds = true
        xibView.layer.borderWidth = 1
        xibView.layer.borderColor = UIColor.kSeparatorGray.cgColor
        xibView.backgroundColor = .white

        rightArrowImageView.image =
            UIImage(named: "icRightArrowGray", in: Bundle.common, compatibleWith: nil)

        actionTitle.font = .kPlainText
        actionTitle.textColor = .black
    }

    public func setTitle(_ text: String) {
        actionTitle.text = text
    }

    public func setImage(_ image: String) {
        actionImageView.image =
            UIImage(named: image, in: Bundle.common, compatibleWith: nil)
    }
}
