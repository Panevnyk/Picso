//
//  AlbumGalleryItemView.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 11.10.2022.
//

import SwiftUI
import Photos
import RetouchCommon

public protocol AlbumGalleryCoordinatorDelegate {
    func didSelectAlbum(assets: PHFetchResult<PHAsset>, title: String)
}

struct AlbumGalleryItemView: View {
    private var assets: PHFetchResult<PHAsset>
    private var title: String
    private var coordinatorDelegate: AlbumGalleryCoordinatorDelegate?

    init?(assets: PHFetchResult<PHAsset>, title: String?, coordinatorDelegate: AlbumGalleryCoordinatorDelegate?) {
        guard assets.count > 0 else { return nil }

        self.assets = assets
        self.title = title ?? "Untitled"
        self.coordinatorDelegate = coordinatorDelegate
    }

    var body: some View {
        HStack(spacing: 16) {
            AssetImage(asset: assets.firstObject,
                       index: 0,
                       targetSize: CGSize(width: 64, height: 64),
                       completionHandler: nil)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(6)

            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(.kTitleText)
                    .foregroundColor(.black)

                Text("\(assets.count) \(assets.count == 1 ? "photo" : "photos")")
                    .font(.kPlainText)
                    .foregroundColor(.kGrayText)
            }

            Spacer()

            Image("icRightArrowGray", bundle: Bundle.common)
                .frame(width: 10, height: 18)
        }
        .frame(height: 64)
        .frame(maxWidth: .infinity)
        .onTapGesture {
            coordinatorDelegate?.didSelectAlbum(assets: assets, title: title)
        }
    }
}
