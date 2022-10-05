//
//  HomeGalleryViewHolder.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 17.09.2022.
//

import UIKit
import SwiftUI
import Photos
import RetouchCommon

public protocol HomeGalleryCoordinatorDelegate: BaseCoordinatorDelegate, BaseBalanceCoordinatorDelegate {
    func didSelectPhoto(asset: PHAsset, from viewController: UIViewController)
    func makeAlbumViewController(from viewController: HomeGalleryViewController) -> AlbumCollectionViewController
    func didSelectCamera(from viewController: HomeGalleryViewController)
}

public class HomeGalleryViewHosting: UIHostingController<HomeGalleryView> {
    // MARK: - Properties
    // Data
    public var isBackHidden = true

    // Delegates
    public weak var coordinatorDelegate: HomeGalleryCoordinatorDelegate?

    // MARK: - Public methods
    public func didSelectAlbum(assets: PHFetchResult<PHAsset>, title: String) {
//        self.assets = assets
//        self.expandableTitle = title
//
//        headerView.closeExpandableView()
//        reloadData()
//        updateHeaderView()
    }
}
