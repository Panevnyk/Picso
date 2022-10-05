//
//  BeforeAfterView.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 13.02.2021.
//

import UIKit

public final class BeforeAfterImagePresentableView: BaseCustomView {
    // MARK: - Properties
    // UI
    @IBOutlet private var xibView: UIView!
    @IBOutlet public var beforeImagePresentableView: ImagePresentableView!
    @IBOutlet public var afterImagePresentableView: ImagePresentableView!

    // Data
    private var isAfter = true

    // MARK: - initialize
    public override func initialize() {
        addSelfNibUsingConstraints(bundle: Bundle.common)

        afterImagePresentableView.alpha = 1
        beforeImagePresentableView.alpha = 0
        
        afterImagePresentableView.delegate = self
        
        beforeImagePresentableView.imageView.contentMode = .scaleAspectFill
        afterImagePresentableView.imageView.contentMode = .scaleAspectFill

        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        lpgr.minimumPressDuration = 0.1
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        afterImagePresentableView.scrollView.addGestureRecognizer(lpgr)
        
    }

    // MARK: - Public methods
    public func setBeforeImage(_ image: UIImage?) {
        beforeImagePresentableView.setImage(image)
    }

    public func setAfterImage(_ image: UIImage?) {
        afterImagePresentableView.setImage(image)
    }

    public func setBeforeImageURL(_ url: URL) {
        beforeImagePresentableView.setImageURL(url)
    }

    public func setAfterImageURL(_ url: URL) {
        afterImagePresentableView.setImageURL(url)
    }
}

// MARK: - ImagePresentableViewDelegate
extension BeforeAfterImagePresentableView: ImagePresentableViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView, from view: UIView) {
        beforeImagePresentableView.scrollView.zoomScale = scrollView.zoomScale
        beforeImagePresentableView.scrollView.contentOffset = scrollView.contentOffset
    }
}

//MARK: - UIGestureRecognizerDelegate
extension BeforeAfterImagePresentableView: UIGestureRecognizerDelegate {
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizer.State.ended {
            // When lognpress is start or running
            if isAfter {
                isAfter = false
                afterImagePresentableView.alpha = 0
                beforeImagePresentableView.alpha = 1
            }

        } else {
            //When lognpress is finish
            if !isAfter {
                isAfter = true
                afterImagePresentableView.alpha = 1
                beforeImagePresentableView.alpha = 0
            }
        }
    }
}
