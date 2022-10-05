//
//  RetouchGroupCollectionViewCell.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 11.02.2021.
//

import UIKit
import RetouchCommon

public final class RetouchGroupCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var checkerImageView: UIImageView!

    // MARK: - awakeFromNib
    public override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.font = .kDescriptionText
        checkerImageView.image =
            UIImage(named: "icCheckerPurple", in: Bundle.common, compatibleWith: nil)

        layer.cornerRadius = 6
        layer.masksToBounds = true
        layer.borderWidth = 1
    }

    func fill(viewModel: RetouchGroupItemViewModelProtocol, isOpenItem: Bool) {
        let imageTintColor: UIColor
        let backgroundColor: UIColor
        let titleColor: UIColor
        let borderColor: UIColor

//        if viewModel.isSelected {
//            imageTintColor = .white
//            backgroundColor = .kPurple
//            titleColor = .white
//            borderColor = .kPurple
//
//        } else
        if isOpenItem {
            imageTintColor = .kPurple
            backgroundColor = .white
            titleColor = .kPurple
            borderColor = .kPurple

        } else {
            imageTintColor = .black
            backgroundColor = .white
            titleColor = .black
            borderColor = .white
        }

        imageView.image = UIImage(named: viewModel.image, in: Bundle.common, compatibleWith: nil)?
            .withRenderingMode(.alwaysTemplate)
        titleLabel.text = viewModel.title

        self.imageView.tintColor = imageTintColor
        self.backgroundColor = backgroundColor
        self.titleLabel.textColor = titleColor
        self.layer.borderColor = borderColor.cgColor

        checkerImageView.isHidden = !viewModel.isSelected

        let scale: CGFloat = isOpenItem ? 1.05 : 1
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        if transform != self.transform {
            UIView.animate(withDuration: 0.2) {
                self.transform = transform
            }
        }
    }
}
