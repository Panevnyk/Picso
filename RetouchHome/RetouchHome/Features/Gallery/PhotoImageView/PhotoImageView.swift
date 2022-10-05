//
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 09.02.2021.
//

import UIKit
import Photos

final class PhotoImageView: UIImageView {
    var currentIndexPath: IndexPath?
}

// MARK: - PhotoImageView + PHAsset
extension PhotoImageView {
    func fetchImageAsset(_ asset: PHAsset?,
                         indexPath: IndexPath? = nil,
                         targetSize size: CGSize,
                         contentMode: PHImageContentMode = .aspectFill,
                         options: PHImageRequestOptions? = nil,
                         completionHandler: ((Bool) -> Void)?) {
        
        guard let asset = asset else { completionHandler?(false); return }
        
        let resultHandler: (UIImage?, [AnyHashable: Any]?) -> Void = { [weak self] image, info in
            var isNeedToUpdate = true
            if let indexPath = indexPath,
               let currentIndexPath = self?.currentIndexPath,
               indexPath != currentIndexPath {
                isNeedToUpdate = false
            }
            
            if isNeedToUpdate {
                self?.image = image
            }
            completionHandler?(isNeedToUpdate)
        }
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: size,
            contentMode: contentMode,
            options: options,
            resultHandler: resultHandler)
    }
}
