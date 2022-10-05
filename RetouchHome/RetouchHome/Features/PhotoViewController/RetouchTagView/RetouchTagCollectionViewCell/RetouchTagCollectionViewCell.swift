//
//  RetouchTagCollectionViewCell.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 11.02.2021.
//

import UIKit
import RetouchCommon

public final class RetouchTagCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var checkerImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var triangleView: TriangleView!
    
    // MARK: - awakeFromNib
    public override func awakeFromNib() {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 6
        containerView.layer.masksToBounds = true
        
        checkerImageView.image =
            UIImage(named: "icCheckerPurple", in: Bundle.common, compatibleWith: nil)

        titleLabel.font = .kDescriptionText
    }

    func fill(viewModel: RetouchTagItemViewModelProtocol, isOpened: Bool) {
        let isSelected = viewModel.isSelected

        titleLabel.text = viewModel.title
        titleLabel.textColor = isOpened ? .kPurple : .black
        containerView.backgroundColor = isOpened ? .kPurpleAlpha10 : .white
        checkerImageView.isHidden = !isSelected
        triangleView.isHidden = !isOpened
    }
}
