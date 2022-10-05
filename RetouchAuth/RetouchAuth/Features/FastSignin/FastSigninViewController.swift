//
//  OnFirstStartTutorialViewController.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk on 12.03.2021.
//

import UIKit
import RetouchCommon

public protocol FastSigninCoordinatorDelegate: UseAgreementsDelegate {
    func didLoginSuccessfully()
    func didSelectUseOtherSigninOptions()
}

public final class FastSigninViewController: UIViewController {
    // MARK: - Properties
    // UI
    @IBOutlet private var backgroundImageView: UIImageView!
    @IBOutlet private var handImageView: UIImageView!
    @IBOutlet private var actionStackView: UIStackView!
    @IBOutlet private var signinWithAppleView: SigninWithAppleView!
    @IBOutlet private var orLabel: UILabel!
    @IBOutlet private var useOtherSininOptionsButton: UIButton!
    @IBOutlet private var useAgreementsLabel: UseAgreementsLabel!
    
    // ViewModel
    public var viewModel: FastSigninViewModelProtocol!

    // Delegate
    public weak var coordinatorDelegate: FastSigninCoordinatorDelegate?

    // MARK: - Life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        signinWithAppleView.viewModel = viewModel.makeSigninWithAppleViewModel()
        setupUI()
        AnalyticsService.logScreen(.fastSignIn)
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - Setup UI
private extension FastSigninViewController {
    func setupUI() {
        useAgreementsLabel.useAgreementsDelegate = coordinatorDelegate
        
        backgroundImageView.image = UIImage(named: "tutorialBGImage4", in: Bundle.common, compatibleWith: nil)
        handImageView.image = UIImage(named: "icBigHandFromTop", in: Bundle.common, compatibleWith: nil)

        signinWithAppleView.delegate = self

        orLabel.font = .kTitleBigText
        orLabel.textColor = .white
        orLabel.text = "OR"

        useOtherSininOptionsButton.layer.cornerRadius = 6
        useOtherSininOptionsButton.layer.masksToBounds = true
        useOtherSininOptionsButton.layer.borderWidth = 1
        useOtherSininOptionsButton.layer.borderColor = UIColor.kSeparatorGray.cgColor
        useOtherSininOptionsButton.backgroundColor = .white
        useOtherSininOptionsButton.setTitleColor(.kGrayText, for: .normal)
        useOtherSininOptionsButton.setTitle("Use other sign in options", for: .normal)
    }
}

// MARK: - SigninWithAppleViewDelegate
extension FastSigninViewController: SigninWithAppleViewDelegate {
    public func didLoginSuccessfully() {
        AnalyticsService.logAction(.fastSignInWithApple)
        coordinatorDelegate?.didLoginSuccessfully()
    }
}

// MARK: - Actions
extension FastSigninViewController {
    @IBAction func useOtherSininOptionsAction(_ sender: Any) {
        AnalyticsService.logAction(.fastSignInOtherOptions)
        coordinatorDelegate?.didSelectUseOtherSigninOptions()
    }
}
