//
//  AlbumCollectionViewCell.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 12.02.2021.
//

import UIKit
import RetouchCommon

final class AlbumCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    @IBOutlet var emptyView: UIImageView!
    @IBOutlet var photoView: PhotoImageView!
    @IBOutlet var albumTitle: UILabel!
    @IBOutlet var albumCount: UILabel!
    @IBOutlet var rightArrowImageView: UIImageView!

    // MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()

        albumTitle.font = .kTitleText
        albumTitle.textColor = .black

        albumCount.font = .kPlainText
        albumCount.textColor = .kGrayText

        photoView.layer.cornerRadius = 6
        photoView.layer.masksToBounds = true

        rightArrowImageView.image =
            UIImage(named: "icRightArrowGray", in: Bundle.common, compatibleWith: nil)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        albumTitle.text = "Untitled"
        albumCount.text = "0 photos"

        photoView.image = nil
        photoView.isHidden = true
        emptyView.isHidden = false
    }

    func update(title: String?, count: Int) {
        albumTitle.text = title ?? "Untitled"
        albumCount.text = "\(count.description) \(count == 1 ? "photo" : "photos")"
    }
}
