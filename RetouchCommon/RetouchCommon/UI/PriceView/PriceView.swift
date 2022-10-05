//
//  PriceView.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 13.02.2021.
//

import UIKit

public final class PriceView: BaseCustomView {
    // MARK: - Properties
    @IBOutlet public var xibView: UIView!
    @IBOutlet public var stackView: UIStackView!
    @IBOutlet public var priceLabel: UILabel!
    @IBOutlet public var currencyImageView: UIImageView!

    // MARK: - initialize
    public override func initialize() {
        addSelfNibUsingConstraints(bundle: Bundle.common)

        backgroundColor = .clear

        priceLabel.font = .kPlainText
        priceLabel.textColor = .kPurple

        currencyImageView.image = UIImage(named: "icDiamondPurple", in: Bundle.common, compatibleWith: nil)
    }

    public func setPriceFont(_ font: UIFont) {
        priceLabel.font = font
    }

    public func setPrice(_ text: String) {
        priceLabel.text = text
    }
}
