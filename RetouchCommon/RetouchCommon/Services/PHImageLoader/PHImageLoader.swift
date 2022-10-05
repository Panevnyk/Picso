//
//  PHImageLoader.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 16.02.2021.
//

import UIKit
import Photos

public protocol PHImageLoaderProtocol {
    func fetchImage(_ asset: PHAsset?,
                    targetSize size: CGSize,
                    contentMode: PHImageContentMode,
                    options: PHImageRequestOptions?,
                    completionHandler: ((_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void)?)
}

public final class PHImageLoader: PHImageLoaderProtocol {
    public init() {}

    public func fetchImage(_ asset: PHAsset?,
                           targetSize size: CGSize,
                           contentMode: PHImageContentMode = .aspectFill,
                           options: PHImageRequestOptions? = nil,
                           completionHandler: ((_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void)?) {
        guard let asset = asset else {
            completionHandler?(nil, nil)
            return
        }

        let resultHandler: (UIImage?, [AnyHashable: Any]?) -> Void = { image, info in
            completionHandler?(image, info)
        }

        PHImageManager.default().requestImage(
            for: asset,
            targetSize: size,
            contentMode: contentMode,
            options: options,
            resultHandler: resultHandler)
    }
}
