//
//  AuthHeaderView.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 26.03.2021.
//

import UIKit
import RxSwift
import RxCocoa

public protocol AuthHeaderViewDelegate: AnyObject {
    func backAction(from view: AuthHeaderView)
}

final public class AuthHeaderView: BaseCustomView {
    // MARK: - Properties
    // UI
    @IBOutlet private var xibView: UIView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var bottomContainerView: UIView!

    @IBOutlet private var headerImageView: UIImageView!

    @IBOutlet private var actionStackView: UIStackView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var titleLabel: UILabel!

    public var isBackButtonHidden: Bool = true {
        didSet { backButton.isHidden = isBackButtonHidden }
    }

    private var isExpanded = false
    private var expandableContainerView: UIView?
    private var topExpandableContainerAnchor: NSLayoutConstraint?

    // Delegate
    public weak var balanceDelegate: BalanceViewDelegate?
    public weak var delegate: AuthHeaderViewDelegate?

    private let disposeBag = DisposeBag()

    // MARK: - initialize
    override public func initialize() {
        super.initialize()

        addSelfNibUsingConstraints(bundle: Bundle.common)
        setupUI()
    }
}

// MARK: - Public methods
extension AuthHeaderView {
    public func setTitle(_ text: String) {
        titleLabel.text = text
    }
}

// MARK: - UI
private extension AuthHeaderView {
    func setupUI() {
        isBackButtonHidden = true
        clipsToBounds = true
        layer.zPosition = 100

        backgroundColor = .clear
        xibView.backgroundColor = .clear

        backButton.layer.cornerRadius = 16
        backButton.layer.masksToBounds = true
        backButton.backgroundColor = .white
        let backImage = UIImage(named: "icLeftArrowPurple", in: Bundle.common, compatibleWith: nil)
        backButton.setImage(backImage, for: .normal)

        titleLabel.font = UIFont.kBigTitleText
        titleLabel.textColor = .white

        let headerImage = UIImage(named: "icAuthHeader", in: Bundle.common, compatibleWith: nil)
        headerImageView.image = headerImage
    }
}


// MARK: - Actions
private extension AuthHeaderView {
    @IBAction func backAction(_ sender: Any) {
        delegate?.backAction(from: self)
    }
}
