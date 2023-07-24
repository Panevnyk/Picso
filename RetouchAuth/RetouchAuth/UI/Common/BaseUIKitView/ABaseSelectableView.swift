//
//  BaseSelectableView.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 02.12.2020.
//

import UIKit

public class ABaseSelectableView: ABaseTapableView {
    public override func initialize() {
        super.initialize()
        animationDelegate = self
    }
}

// MARK: - BaseTapableViewAnimationDelegate
extension ABaseSelectableView: ABaseTapableViewAnimationDelegate {
    public func animateToSelectSize(inView view: ABaseTapableView) {
        UIView.animate(withDuration: 0.1) {
            self.alpha = 0.2
        }
    }

    public func animateToNormalSize(inView view: ABaseTapableView) {
        UIView.animate(withDuration: 0.1) {
            self.alpha = 1
        }
    }
}
