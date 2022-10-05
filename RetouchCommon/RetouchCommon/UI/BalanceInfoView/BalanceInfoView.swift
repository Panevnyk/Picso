//
//  BalanceInfoView.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 21.04.2021.
//

import UIKit

public final class BalanceInfoView: BaseCustomView {
    // MARK: - Properties
    @IBOutlet private var xibView: UIView!
    @IBOutlet private var topTitleLabel: UILabel!
    @IBOutlet private var balanceLabel: UILabel!
    @IBOutlet private var balanceImageView: UIImageView!

    // MARK: - initialize
    public override func initialize() {
        addSelfNibUsingConstraints(bundle: Bundle.common)

        backgroundColor = .clear
        layer.cornerRadius = 6
        layer.masksToBounds = true
        layer.borderWidth = 1

        topTitleLabel.font = .kTitleBigText
        
        balanceLabel.font = .kPlainBigText
        balanceLabel.text = "0"

        balanceImageView.image =
            UIImage(named: "icDiamondPurple", in: Bundle.common, compatibleWith: nil)?
                .withRenderingMode(.alwaysTemplate)

        setColor(.black)
    }

    public func setAmount(_ value: String?) {
        balanceLabel.text = value
    }

    public func setTopTitle(_ value: String) {
        topTitleLabel.text = value
    }

    public func setColor(_ color: UIColor) {
        topTitleLabel.textColor = color
        balanceLabel.textColor = color
        layer.borderColor = color.cgColor
        balanceImageView.tintColor = color
    }
}
