//
//  AssetPhotoGalleryViewModel.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 18.10.2022.
//

import UIKit
import Photos
import RetouchCommon

public class AssetPhotoGalleryViewModel: PhotoGalleryViewModel {
    public init(ordersLoader: OrdersLoaderProtocol,
                phImageLoader: PHImageLoaderProtocol,
                retouchGroups: [RetouchGroup],
                iapService: IAPServiceProtocol,
                freeGemCreditCountService: FreeGemCreditCountServiceProtocol,
                asset: PHAsset) {
        super.init(ordersLoader: ordersLoader,
                   phImageLoader: phImageLoader,
                   retouchGroups: retouchGroups,
                   iapService: iapService,
                   freeGemCreditCountService: freeGemCreditCountService,
                   image: nil)

        loadImage(asset: asset)
    }

    private func loadImage(asset: PHAsset) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true

        ActivityIndicatorHelper.shared.show()
        DispatchQueue(label: "Fetch image", qos: DispatchQoS.userInteractive).async {
            self.phImageLoader.fetchImage(asset,
                                          targetSize: PHImageManagerMaximumSize,
                                          contentMode: .aspectFill,
                                          options: options)
            { [weak self] (image, info) in
                DispatchQueue.main.async {
                    ActivityIndicatorHelper.shared.hide()
                    self?.image = image
                }
            }
        }
    }
}
