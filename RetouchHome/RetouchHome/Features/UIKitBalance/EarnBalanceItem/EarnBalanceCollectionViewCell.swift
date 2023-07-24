//
//  EarnBalanceCollectionViewCell.swift
//  RetouchHome
//
//  Created by Panevnyk Vlad on 11.07.2022.
//

import UIKit
import RetouchCommon

final class EarnBalanceCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var priceView: PriceView!
    @IBOutlet private var bottomContainerView: UIView!
    @IBOutlet private var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 6
        containerView.layer.masksToBounds = true

        bottomContainerView.backgroundColor = .kPurple

        priceView.setPriceFont(.kPlainBigText)

        descriptionLabel.font = .kPlainText
        descriptionLabel.textColor = .white
    }

    func fill(viewModel: EarnBalanceItemViewModelProtocol) {
        priceView.setPrice(viewModel.diamondPrice)
        descriptionLabel.text = viewModel.descriptionTitle
        containerView.alpha = viewModel.isAvailable ? 1 : 0.3
        contentView.superview?.isUserInteractionEnabled = viewModel.isAvailable
    }
}
