//
//  ExamplesTableViewCell.swift
//  RetouchExamples
//
//  Created by Vladyslav Panevnyk on 13.02.2021.
//

import UIKit
import RetouchCommon

final class ExamplesTableViewCell: UITableViewCell {
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var exampleImageView: UIImageView!
    @IBOutlet private var exampleTitleLabel: UILabel!
    @IBOutlet private var exampleDescriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
        containerView.layer.borderColor = UIColor.kSeparatorGray.cgColor
        containerView.layer.borderWidth = 1

        exampleImageView.layer.cornerRadius = 6
        exampleImageView.layer.masksToBounds = true
        exampleImageView.contentMode = .scaleAspectFill

        exampleTitleLabel.font = .kTitleBigText
        exampleTitleLabel.textColor = .black

        exampleDescriptionLabel.font = .kPlainText
        exampleDescriptionLabel.textColor = .kGrayText
    }

    func fill(viewModel: ExampleItemViewModelProtocol) {
        exampleTitleLabel.text = viewModel.title
        exampleDescriptionLabel.text = viewModel.description
        if let url = URL(string: viewModel.imageAfter) {
            exampleImageView.setImage(with: url)
        }
    }
}
