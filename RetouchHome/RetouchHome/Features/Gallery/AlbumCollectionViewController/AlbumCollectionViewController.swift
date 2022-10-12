//
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 09.02.2021.
//

import UIKit
import Photos
import RetouchCommon

public protocol AlbumCollectionCoordinatorDelegate: AnyObject {
    func didSelectAlbum(assets: PHFetchResult<PHAsset>, title: String)
}

public final class AlbumCollectionViewController: UICollectionViewController {
    // MARK: - Properties
    var sections: [AlbumCollectionSectionType] = [.all, .smartAlbums, .userCollections]
    var allPhotos = PHFetchResult<PHAsset>()
    var smartAlbums = PHFetchResult<PHAssetCollection>()
    var userCollections = PHFetchResult<PHAssetCollection>()

    // Delegates
    public weak var coordinatorDelegate: AlbumCollectionCoordinatorDelegate?

    // MARK: - Life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        getPermissionIfNecessary { granted in
            guard granted else { return }
            self.fetchAssets()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        PHPhotoLibrary.shared().register(self)

        collectionView.register(cell: AlbumCollectionViewCell.self, bundle: Bundle.home)
        AnalyticsService.logScreen(.albumGallery)
    }

    // MARK: - Deinit
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }


    // MARK: - CollectionView mothods
    public override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AlbumCollectionViewCell = collectionView.dequeueReusableCellWithIndexPath(indexPath)

        var coverAsset: PHAsset?
        let sectionType = sections[indexPath.section]
        switch sectionType {

        case .all:
            coverAsset = allPhotos.firstObject
            cell.update(title: sectionType.description, count: allPhotos.count)

        case .smartAlbums, .userCollections:
            let collection = sectionType == .smartAlbums ?
                smartAlbums[indexPath.item] :
                userCollections[indexPath.item]
            let fetchedAssets = PHAsset.fetchAssets(in: collection, options: nil)
            coverAsset = fetchedAssets.firstObject
            cell.update(title: collection.localizedTitle, count: fetchedAssets.count)
        }
        guard let asset = coverAsset else { return cell }
        cell.photoView.currentIndexPath = indexPath
        cell.photoView.fetchImageAsset(asset, indexPath: indexPath, targetSize: cell.bounds.size) { success in
            cell.photoView.isHidden = !success
            cell.emptyView.isHidden = success
        }
        return cell
    }

    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .all: return 1
        case .smartAlbums: return smartAlbums.count
        case .userCollections: return userCollections.count
        }
    }

    public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        push(toIndexPath: indexPath)
    }

    func getPermissionIfNecessary(completionHandler: @escaping (Bool) -> Void) {
        guard PHPhotoLibrary.authorizationStatus() != .authorized else {
            completionHandler(true)
            return
        }

        PHPhotoLibrary.requestAuthorization { status in
            completionHandler(status == .authorized ? true : false)
        }
    }

    func fetchAssets() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)

        let smartAlbumOptions = PHFetchOptions()
        smartAlbums = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .albumRegular,
            options: smartAlbumOptions)

        let albumOptions = PHFetchOptions()
        albumOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        userCollections = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .albumRegular,
            options: albumOptions)
    }
}

// MARK: - Push
private extension AlbumCollectionViewController {
    func push(toIndexPath indexPath: IndexPath) {
        let sectionType = sections[indexPath.section]
        let item = indexPath.item

        let assets: PHFetchResult<PHAsset>
        let title: String

        switch sectionType {
        case .all:
            assets = allPhotos
            title = AlbumCollectionSectionType.all.description
        case .smartAlbums, .userCollections:
            let album =
                sectionType == .smartAlbums ? smartAlbums[item] : userCollections[item]
            assets = PHAsset.fetchAssets(in: album, options: nil)
            title = album.localizedTitle ?? ""
        }

        coordinatorDelegate?.didSelectAlbum(assets: assets, title: title)
    }
}

// MARK: - PHPhotoLibraryChangeObserver
extension AlbumCollectionViewController: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.sync {
            if let changeDetails = changeInstance.changeDetails(for: allPhotos) {
                allPhotos = changeDetails.fetchResultAfterChanges
            }
            if let changeDetails = changeInstance.changeDetails(for: smartAlbums) {
                smartAlbums = changeDetails.fetchResultAfterChanges
            }
            if let changeDetails = changeInstance.changeDetails(for: userCollections) {
                userCollections = changeDetails.fetchResultAfterChanges
            }
            collectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension AlbumCollectionViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeForItem
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }

    private var sectionInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    private var sizeForItem: CGSize {
        let itemsPerRow: CGFloat = 1
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: 64)
    }
}
