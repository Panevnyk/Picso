//
//  PhotosCollectionViewCell.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 12.02.2021.
//

import UIKit

final class PhotosCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoView: PhotoImageView!
    @IBOutlet weak var livePhotoIndicator: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()
        photoView.image = nil
        livePhotoIndicator.isHidden = true
    }
}
