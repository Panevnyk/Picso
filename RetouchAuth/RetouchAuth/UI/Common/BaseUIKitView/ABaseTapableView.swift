//
//  BaseTapableView.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 02.12.2020.
//

import UIKit

public protocol ABaseTapableViewDelegate: AnyObject {
    func didTapAction(inView view: ABaseTapableView)
}

public protocol ABaseTapableViewAnimationDelegate: AnyObject {
    func animateToSelectSize(inView view: ABaseTapableView)
    func animateToNormalSize(inView view: ABaseTapableView)
}

public class ABaseTapableView: ABaseCustomView {
    // UI
    private var cardButton: UIButton!

    // Delegates
    public weak var delegate: ABaseTapableViewDelegate?
    public weak var animationDelegate: ABaseTapableViewAnimationDelegate?

    // initialize
    public override func initialize() {
        super.initialize()

        translatesAutoresizingMaskIntoConstraints = false

        cardButton = UIButton(type: .system)
        cardButton.backgroundColor = UIColor.clear
        cardButton.addTarget(self, action: #selector(cardButtonTouchDown), for: .touchDown)
        cardButton.addTarget(self, action: #selector(cardButtonUpInside), for: .touchUpInside)
        cardButton.addTarget(self, action: #selector(cardButtonUpOutSide), for: .touchUpOutside)
        cardButton.addTarget(self, action: #selector(cardButtonCancel), for: .touchCancel)
        addSubviewUsingConstraints(view: cardButton)
    }
}

// MARK: - Actions
private extension ABaseTapableView {
    @IBAction func cardButtonTouchDown(_ sender: UIButton) {
        animationDelegate?.animateToSelectSize(inView: self)
    }

    @IBAction func cardButtonUpInside(_ sender: UIButton) {
        animationDelegate?.animateToNormalSize(inView: self)
        delegate?.didTapAction(inView: self)
    }

    @IBAction func cardButtonUpOutSide(_ sender: UIButton) {
        animationDelegate?.animateToNormalSize(inView: self)
    }

    @IBAction func cardButtonCancel(_ sender: UIButton) {
        animationDelegate?.animateToNormalSize(inView: self)
    }
}
