//
//  RetouchTagView.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 11.02.2021.
//

import UIKit
import RetouchCommon

public final class RetouchTagView: BaseCustomView {
    // MARK: - Properties
    // UI
    @IBOutlet private var xibView: UIView!
    @IBOutlet private var collectionView: UICollectionView!

    // ViewModel
    public var viewModel: RetouchTagViewModelProtocol!

    // MARK: - initialize
    public override func initialize() {
        addSelfNibUsingConstraints(bundle: Bundle.home)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .white
        collectionView.backgroundColor = .white

        collectionView.register(cell: RetouchTagCollectionViewCell.self, bundle: Bundle.home)
        collectionView.delegate = self
        collectionView.dataSource = self

        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension RetouchTagView: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemsCount(in: section)
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: RetouchTagCollectionViewCell = collectionView.dequeueReusableCellWithIndexPath(indexPath)
        updateCell(cell, by: indexPath)
        
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItem(for: indexPath.item)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? RetouchTagCollectionViewCell {
            updateCell(cell, by: indexPath)
        }
        
        if let interactedItem = viewModel.getPreviousOpenedValue() {
            let interactedIndexPath = IndexPath(item: interactedItem, section: 0)
            if let cell = collectionView.cellForItem(at: interactedIndexPath) as? RetouchTagCollectionViewCell {
                updateCell(cell, by: interactedIndexPath)
            }
        }
    }
    
    private func updateCell(_ cell: RetouchTagCollectionViewCell, by indexPath: IndexPath) {
        let itemViewModel = viewModel.retouchTagItem(for: indexPath.item)
        let isOpened = viewModel.isOpenedTag(for: indexPath.item)
        cell.fill(viewModel: itemViewModel, isOpened: isOpened)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension RetouchTagView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

// MARK: - RetouchTagViewModelDelegate
extension RetouchTagView: RetouchTagViewModelDelegate {
    public func reloadData() {
        collectionView.reloadDataAndKeepOffset()
    }
    
    public func scrollToStart() {
        collectionView.setContentOffset(CGPoint.zero, animated: false)
    }
}
