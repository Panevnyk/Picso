//
//  PhotoGalleryView.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 19.09.2022.
//

import SwiftUI
import Photos

public struct GalleryView: View {
    private static let spacing: CGFloat = 2

    private let assets: PHFetchResult<PHAsset>
    private var action: (_ asset: PHAsset) -> Void

    private let columns = [
        GridItem(spacing: GalleryView.spacing),
        GridItem(spacing: GalleryView.spacing),
        GridItem(spacing: GalleryView.spacing)
    ]

    public init(assets: PHFetchResult<PHAsset>,
                action: @escaping (_ asset: PHAsset) -> Void) {
        self.assets = assets
        self.action = action
    }

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: GalleryView.spacing) {
                ForEach(0 ..< assets.count, id: \.self) { index in
                    AssetImage(asset: assets[index],
                               index: index,
                               targetSize: CGSize(width: 150, height: 150),
                               completionHandler: nil)
                        .aspectRatio(1, contentMode: .fit)
                        .onTapGesture {
                            action(assets[index])
                        }
                }
            }
        }
        .padding([.all], GalleryView.spacing)
    }
}
