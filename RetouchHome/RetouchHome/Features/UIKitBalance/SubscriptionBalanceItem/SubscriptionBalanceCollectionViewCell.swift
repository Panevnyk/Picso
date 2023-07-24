//
//  SubscriptionBalanceCollectionViewCell.swift
//  RetouchHome
//
//  Created by Panevnyk Vlad on 11.07.2022.
//

import UIKit
import RetouchCommon

final class SubscriptionBalanceCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var priceView: PriceView!
    @IBOutlet private var usdPriceContainerView: UIView!
    @IBOutlet private var usdPriceLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 6
        containerView.layer.masksToBounds = true

        usdPriceContainerView.backgroundColor = .kPurple

        priceView.setPriceFont(.kPlainBigText)

        usdPriceLabel.font = .kTitleText
        usdPriceLabel.textColor = .white

        descriptionLabel.font = .kPlainText
        descriptionLabel.textColor = .kTextDarkGray
    }

//    func fill(viewModel: BalanceItemViewModelProtocol) {
//        priceView.setPrice(viewModel.diamondPrice)
//        usdPriceLabel.text = viewModel.usdPrice
//        bonusesLabel.text = viewModel.bonuses
//    }
}
