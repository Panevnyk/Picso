//
//  HomeHistoryViewController.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 14.02.2021.
//

import UIKit
import RetouchCommon

public protocol HomeHistoryCoordinatorDelegate: BaseBalanceCoordinatorDelegate {
    func didTapGallery(from viewController: HomeHistoryViewController)
    func didTapCamera(from viewController: HomeHistoryViewController)
    func didSelectItem(_ item: Int, from viewController: HomeHistoryViewController)
}

public final class HomeHistoryViewController: UIViewController {
    // MARK: - Properties
    // UI
    @IBOutlet private var headerView: HeaderView!
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet private var galleryAndPhotoView: GalleryAndPhotoView!
    private var refreshControl = UIRefreshControl()

    // ViewModel
    public var viewModel: HomeHistoryViewModelProtocol!

    // Delegates
    public weak var coordinatorDelegate: HomeHistoryCoordinatorDelegate?

    // MARK: - Life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        viewModel.bindData()
        AnalyticsService.logScreen(.homeHistory)
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
}

// MARK: - SetupUI
private extension HomeHistoryViewController {
    func setupUI() {
        headerView.setTitle("Home")
        headerView.setBackgroundColor(.kBackground)
        headerView.hideExpandableView()
        headerView.balanceDelegate = self

        refreshControl.tintColor = .black
        refreshControl.addTarget(self, action: #selector(updateList), for: .valueChanged)

        collectionView.backgroundColor = .kBackground
        collectionView.register(cell: HomeHistoryItemCollectionViewCell.self, bundle: Bundle.home)
        collectionView.register(UINib(nibName: "NotificationHeaderView",
                                      bundle: Bundle.home),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "NotificationHeaderView")
        collectionView.refreshControl = refreshControl
        reloadFlowLayout()

        galleryAndPhotoView.delegate = self
    }

    @objc private func updateList() {
        AnalyticsService.logAction(.refreshHistory)
        viewModel.reloadList { [weak self] in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }
        }
    }
}

// MARK: - BalanceViewDelegate
extension HomeHistoryViewController: BalanceViewDelegate {
    public func didTapAction(from view: BalanceView) {
        coordinatorDelegate?.didSelectBalanceAction()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension HomeHistoryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemsCount(in: section)
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: HomeHistoryItemCollectionViewCell = collectionView.dequeueReusableCellWithIndexPath(indexPath)
        let itemViewModel = viewModel.itemViewModel(for: indexPath.item)
        cell.fill(viewModel: itemViewModel)

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        coordinatorDelegate?.didSelectItem(indexPath.item, from: self)
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView: NotificationHeaderView = collectionView.dequeueReusableSupplementaryViewWithIndexPath(
            indexPath,
            kind: UICollectionView.elementKindSectionHeader)
        let notificationViewModel = viewModel.getNotificationViewModel()
        headerView.setup(viewModel: notificationViewModel)
        return headerView
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeHistoryViewController: UICollectionViewDelegateFlowLayout {
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

// MARK: - GalleryAndPhotoViewDelegate
extension HomeHistoryViewController: GalleryAndPhotoViewDelegate {
    func didTapGallery(from view: GalleryAndPhotoView) {
        coordinatorDelegate?.didTapGallery(from: self)
        AnalyticsService.logAction(.galleryFromHistory)
    }

    func didTapCamera(from view: GalleryAndPhotoView) {
        coordinatorDelegate?.didTapCamera(from: self)
        AnalyticsService.logAction(.cameraFromHistory)
    }
}

// MARK: - HomeHistoryViewModelDelegate
extension HomeHistoryViewController: HomeHistoryViewModelDelegate {
    public func reloadData() {
        collectionView.reloadData()
        reloadFlowLayout()
    }
    
    private func reloadFlowLayout() {
        collectionViewFlowLayout.headerReferenceSize = viewModel.isNotificationsAvailable()
            ? CGSize(width: collectionView.frame.width, height: 144)
            : CGSize.zero
    }
}
