//
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 09.02.2021.
//

import UIKit
import RetouchCommon
import Photos

public final class HomeGalleryViewController: UIViewController {
    // MARK: - Properties
    // UI
    @IBOutlet private var headerView: HeaderView!
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var cameraButton: CameraButton!
    private var refreshControl = UIRefreshControl()

    // Data
    public var dataLoader: DataLoaderProtocol!
    public var phImageLoader: PHImageLoaderProtocol!
    public var assets: PHFetchResult<PHAsset>!
    public var expandableTitle: String = ""
    public var isBackHidden = true

    // Delegates
    public weak var coordinatorDelegate: HomeGalleryCoordinatorDelegate?

    // MARK: - Life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()

        PHPhotoLibrary.shared().register(self)
        setupUI()
        AnalyticsService.logScreen(.homeGallery)
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
    
    // MARK: - Public methods
    public func didSelectAlbum(assets: PHFetchResult<PHAsset>, title: String) {
        self.assets = assets
        self.expandableTitle = title

        headerView.closeExpandableView()
        reloadData()
        updateHeaderView()
    }

    // MARK: - deinit
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}

// MARK: - SetupUI
private extension HomeGalleryViewController {
    func setupUI() {
        headerView.setTitle("Home")
        headerView.expandableDelegate = self
        headerView.balanceDelegate = self
        headerView.setBackgroundColor(.kBackground)
        headerView.isBackButtonHidden = isBackHidden
        if !isBackHidden {
            headerView.delegate = self
        }
        updateHeaderView()

        refreshControl.tintColor = .black
        refreshControl.addTarget(self, action: #selector(updateList), for: .valueChanged)

        collectionView.backgroundColor = .kBackground
        collectionView.register(cell: PhotosCollectionViewCell.self, bundle: Bundle.home)
        collectionView.refreshControl = refreshControl
    }

    func updateHeaderView() {
        headerView.setExpandableTitle(expandableTitle)
    }

    func reloadData() {
        collectionView.reloadData()
    }

    @objc private func updateList() {
        AnalyticsService.logAction(.refreshGallery)
        dataLoader.loadData { [weak self] in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
                self?.reloadData()
            }
        }
    }
}

// MARK: - BalanceViewDelegate
extension HomeGalleryViewController: BalanceViewDelegate {
    public func didTapAction(from view: BalanceView) {
        coordinatorDelegate?.didSelectBalanceAction()
    }
}

// MARK: - PHPhotoLibraryChangeObserver
extension HomeGalleryViewController: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let change = changeInstance.changeDetails(for: assets) else { return }
        DispatchQueue.main.sync {
            assets = change.fetchResultAfterChanges
            reloadData()
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension HomeGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PhotosCollectionViewCell = collectionView.dequeueReusableCellWithIndexPath(indexPath)
        let asset = assets[indexPath.item]
        let size = CGSize(width: cell.photoView.bounds.size.width * 2,
                          height: cell.photoView.bounds.size.height * 2)
        cell.photoView.currentIndexPath = indexPath
        cell.photoView.fetchImageAsset(asset,
                                       indexPath: indexPath,
                                       targetSize: size,
                                       completionHandler: nil)
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = assets[indexPath.item]
        coordinatorDelegate?.didSelectPhoto(asset: asset, from: self)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeGalleryViewController: UICollectionViewDelegateFlowLayout {
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
        return UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)
    }

    private var sizeForItem: CGSize {
        let itemsPerRow: CGFloat = 3
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
}

// MARK: - HeaderViewDelegate
extension HomeGalleryViewController: HeaderViewExpandableDelegate {
    public func getFromViewController() -> UIViewController { self }
    public func getPresentableViewController() -> UIViewController {
        return coordinatorDelegate!.makeAlbumViewController(from: self)
    }
}

// MARK: - HeaderViewDelegate
extension HomeGalleryViewController: HeaderViewDelegate {
    public func backAction(from view: HeaderView) {
        coordinatorDelegate?.didSelectBackAction()
    }
}

// MARK: - Actions
private extension HomeGalleryViewController {
    @IBAction func cameraAction(_ sender: Any) {
        AnalyticsService.logAction(.cameraFromGallery)
        coordinatorDelegate?.didSelectCamera(from: self)
    }
}
