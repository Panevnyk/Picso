//
//  HomeGalleryViewModel.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 19.09.2022.
//

import Combine
import Photos
import RetouchCommon

public protocol HomeGalleryViewModelProtocol: AnyObject {
    var assets: PHFetchResult<PHAsset> { get }
    var expandableTitle: String? { get }
    var isBackHidden: Bool { get }

    func updateList()
}

public class HomeGalleryViewModel: NSObject, ObservableObject, HomeGalleryViewModelProtocol {
    // MARK: - Properties
    private var dataLoader: DataLoaderProtocol!
    private var phImageLoader: PHImageLoaderProtocol!

    @Published public var assets: PHFetchResult<PHAsset>
    @Published public var expandableTitle: String?
    @Published public var isBackHidden: Bool

    // MARK: - Inits
    public init(dataLoader: DataLoaderProtocol,
                phImageLoader: PHImageLoaderProtocol,
                assets: PHFetchResult<PHAsset>,
                expandableTitle: String? = nil,
                isBackHidden: Bool = true) {
        self.dataLoader = dataLoader
        self.phImageLoader = phImageLoader
        self.assets = assets
        self.expandableTitle = expandableTitle
        self.isBackHidden = isBackHidden

        super.init()

        PHPhotoLibrary.shared().register(self)
    }

    // MARK: - Public
    public func updateList() {
        dataLoader.loadData(completion: nil)
    }
}

// MARK: - PHPhotoLibraryChangeObserver
extension HomeGalleryViewModel: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let change = changeInstance.changeDetails(for: assets) else { return }
        DispatchQueue.main.sync {
            assets = change.fetchResultAfterChanges
        }
    }
}
