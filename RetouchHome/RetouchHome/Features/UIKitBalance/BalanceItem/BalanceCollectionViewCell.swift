//
//  BalanceCollectionViewCell.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 17.02.2021.
//

import UIKit
import RetouchCommon

final class BalanceCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var priceView: PriceView!
    @IBOutlet private var bottomContainerView: UIView!
    @IBOutlet private var usdPriceLabel: UILabel!
    @IBOutlet private var bonusesLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 6
        containerView.layer.masksToBounds = true

        bottomContainerView.backgroundColor = .kPurple

        priceView.setPriceFont(.kPlainBigText)

        usdPriceLabel.font = .kTitleText
        usdPriceLabel.textColor = .white

        bonusesLabel.font = .kPlainText
        bonusesLabel.textColor = .kTextDarkGray
    }

    func fill(viewModel: BalanceItemViewModelProtocol) {
        priceView.setPrice(viewModel.diamondPrice)
        usdPriceLabel.text = viewModel.usdPrice
        bonusesLabel.text = viewModel.bonuses
    }
}
