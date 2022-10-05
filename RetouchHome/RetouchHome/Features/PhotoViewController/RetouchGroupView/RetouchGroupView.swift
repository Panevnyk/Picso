//
//  RetouchGroupView.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 11.02.2021.
//

import UIKit
import RetouchCommon

public final class RetouchGroupView: BaseCustomView {
    // MARK: - Properties
    // UI
    @IBOutlet private var xibView: UIView!
    @IBOutlet private var collectionView: UICollectionView!

    // ViewModel
    public var viewModel: RetouchGroupViewModelProtocol!

    // MARK: - initialize
    public override func initialize() {
        addSelfNibUsingConstraints(bundle: Bundle.home)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .white
        collectionView.backgroundColor = .white
        
        collectionView.register(cell: RetouchGroupCollectionViewCell.self, bundle: Bundle.home)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension RetouchGroupView: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemsCount(in: section)
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: RetouchGroupCollectionViewCell = collectionView.dequeueReusableCellWithIndexPath(indexPath)
        let itemViewModel = viewModel.retouchGroupItem(for: indexPath.item)
        let isOpenItem = viewModel.isOpenItem(for: indexPath.item)
        cell.fill(viewModel: itemViewModel, isOpenItem: isOpenItem)
        
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItem(for: indexPath.item)
    }
}

// MARK: - RetouchGroupViewModelDelegate
extension RetouchGroupView: RetouchGroupViewModelDelegate {
    public func reloadData() {
        collectionView.reloadDataAndKeepOffset()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension RetouchGroupView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 70)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}
