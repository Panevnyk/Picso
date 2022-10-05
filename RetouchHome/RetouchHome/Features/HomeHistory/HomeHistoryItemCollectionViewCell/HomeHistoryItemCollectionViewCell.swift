//
//  HomeHistoryItemCollectionViewCell.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 16.02.2021.
//

import UIKit
import Kingfisher
import RetouchCommon

public final class HomeHistoryItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var buyButton: StatusButton!
    @IBOutlet weak var statusButton: StatusButton!

    public override func awakeFromNib() {
        super.awakeFromNib()

        photoView.image = nil

        statusButton.setTitleColor(.white, for: .normal)
        statusButton.isUserInteractionEnabled = false

        buyButton.backgroundColor = .white
        buyButton.layer.borderColor = UIColor.kPurple.cgColor
        buyButton.setTitleColor(.kPurple, for: .normal)
        buyButton.setTitle("Buy", for: .normal)
    }

    func fill(viewModel: HomeHistoryItemViewModelProtocol) {
        if let imageToShow = viewModel.imageToShow {
            let url = URL(string: imageToShow)
            let placeholder = UIImage(named: "icImagePlaceholder", in: Bundle.common, compatibleWith: nil)
            photoView.kf.setImage(with: url, placeholder: placeholder)
        }

        statusButton.isHidden = viewModel.status == .completed
        statusButton.backgroundColor = viewModel.status.backgroundColor
        statusButton.setTitle(viewModel.status.title, for: .normal)
        buyButton.isHidden = !(viewModel.status == .completed && !viewModel.isPayed)
    }
}

extension OrderStatus {
    var title: String? {
        switch self {
        case .waiting: return "Waiting"
        case .canceled: return "Canceled"
        case .confirmed: return "Confirmed"
        case .waitingForReview, .inReview, .redoByLeadDesigner: return "Waiting"
        case .completed: return nil
        }
    }

    var backgroundColor: UIColor? {
        switch self {
        case .waiting: return .kBlue
        case .canceled: return .kRed
        case .confirmed: return .kGreen
        case .waitingForReview, .inReview, .redoByLeadDesigner: return .kBlue
        case .completed: return nil
        }
    }
}
