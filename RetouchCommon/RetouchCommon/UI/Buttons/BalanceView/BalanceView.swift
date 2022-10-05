//
//  BalanceView.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 12.02.2021.
//

import UIKit

public protocol BalanceViewDelegate: AnyObject {
    func didTapAction(from view: BalanceView)
}

final public class BalanceView: BaseCustomView {
    // MARK: - Properties
    @IBOutlet private var xibView: BaseSelectableView!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var balanceLabel: UILabel!
    @IBOutlet private var balanceImageView: UIImageView!

    public weak var delegate: BalanceViewDelegate?

    // MARK: - initialize
    public override func initialize() {
        addSelfNibUsingConstraints(bundle: Bundle.common)

        xibView.delegate = self

        backgroundColor = .clear
        layer.cornerRadius = 16
        layer.masksToBounds = true
        layer.borderWidth = 1

        balanceLabel.font = .kPlainBigText
        balanceLabel.text = "0"

        balanceImageView.image =
            UIImage(named: "icDiamondPurple", in: Bundle.common, compatibleWith: nil)?
                .withRenderingMode(.alwaysTemplate)

        setColor(.kPurple)
    }

    public func setBalance(_ value: Int) {
        balanceLabel.text = String(value)
    }

    public func setColor(_ color: UIColor) {
        balanceLabel.textColor = color
        layer.borderColor = color.cgColor
        balanceImageView.tintColor = color
    }
}

// MARK: - BaseTapableViewDelegate
extension BalanceView: BaseTapableViewDelegate {
    public func didTapAction(inView view: BaseTapableView) {
        delegate?.didTapAction(from: self)
    }
}
