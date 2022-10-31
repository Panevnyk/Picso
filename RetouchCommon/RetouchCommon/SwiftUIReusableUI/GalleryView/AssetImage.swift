//
//  AssetImage.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 19.09.2022.
//

import SwiftUI
import Photos

public struct AssetImage: View {
    private var viewModel: AssetImageViewModel

    public init(asset: PHAsset?,
                index: Int,
                targetSize: CGSize,
                completionHandler: ((Bool) -> Void)?) {
        self.viewModel = AssetImageViewModel()
        viewModel.fetchImageAsset(asset,
                                  index: index,
                                  targetSize: targetSize,
                                  completionHandler: completionHandler)
    }

    public var body: some View {
        GeometryReader { proxy in
            makeImage()
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
        }
    }

    private func makeImage() -> Image {
        if let image = viewModel.image {
            return Image(uiImage: image)
        } else {
            return Image("icImagePlaceholder", bundle: .common)
        }
    }
}

final class AssetImageViewModel: ObservableObject {
    @Published var image: UIImage?

    private var currentIndex: Int?

    func fetchImageAsset(_ asset: PHAsset?,
                         index: Int? = nil,
                         targetSize size: CGSize,
                         contentMode: PHImageContentMode = .aspectFill,
                         options: PHImageRequestOptions? = nil,
                         completionHandler: ((Bool) -> Void)?) {

        guard let asset = asset else { completionHandler?(false); return }

        let resultHandler: (UIImage?, [AnyHashable: Any]?) -> Void = { [weak self] image, info in
            var isNeedToUpdate = true
            if let index = index,
               let currentIndex = self?.currentIndex,
               index != currentIndex {
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
