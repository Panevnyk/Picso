//
//  ForgotPasswordViewController.swift
//  SaleUp
//
//  Created by sxsasha on 27.02.18.
//  Copyright © 2018 Devlight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RestApiManager
import RetouchCommon

public protocol ForgotPasswordCoordinatorDelegate: UseAgreementsDelegate {
    func didSelectLoginWith(email: String)
    func dissmiss()
}

public final class ForgotPasswordViewController: BaseScrollViewController {
    // MARK: - Properties
    // UI
    @IBOutlet private var headerView: AuthHeaderView!

    @IBOutlet private var hintLabel: UILabel!
    @IBOutlet private var emailTextField: SUTextField!
    @IBOutlet private var sendButton: PurpleButton!
    @IBOutlet private var useAgreementsLabel: UseAgreementsLabel!
    
    // Coordinator delegate
    public weak var coordinatorDelegate: ForgotPasswordCoordinatorDelegate?

    // ViewModels
    public var viewModel: ForgotPasswordViewModelProtocol!
    private let disposeBag = DisposeBag()

    // MARK: - Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupViewModels()
        AnalyticsService.logScreen(.forgotPassword)
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
}

// MARK: - UI
private extension ForgotPasswordViewController {
    func setupUI() {
        useAgreementsLabel.useAgreementsDelegate = coordinatorDelegate
        
        headerView.setTitle("Forgot password")
        headerView.isBackButtonHidden = false
        headerView.delegate = self

        hintLabel.text = "We will send reset password link to your email"
        hintLabel.textColor = UIColor.kGrayText
        hintLabel.font = UIFont.kPlainText

        emailTextField.placeholder = "Email"
        emailTextField.config = .email

        sendButton.setTitle("Send", for: .normal)
        sendButton.backgroundColor = .kPurple
        sendButton.backgroundDisabledColor = .kNotActivePurple
    }
}

// MARK: - ViewModels
private extension ForgotPasswordViewController {
    func setupViewModels() {
        bindUI()
        bindViewModel()
    }

    func bindUI() {
        emailTextField.textField.rx.text
            .map { $0 ?? "" }
            .bind(to: viewModel.emailText)
            .disposed(by: disposeBag)

        viewModel.isValid
            .bind(to: sendButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.emailValidationResult
            .bind(to: emailTextField.validationResultObservable)
            .disposed(by: disposeBag)
    }

    func bindViewModel() {
//        viewModel.isSuccessSendObservable.subscribe(onNext: { [unowned self] (value) in
//            guard value else {
//                return
//            }

//            let email = self.viewModel.emailText.value
//            AlertHelper.show(message: Localize("temporary_password_was_sent"), okAction: { (_) in
//                self.forgotPasswordCoordinatorDelegate?.didSelectLoginWith(email: email)
//            })
//        }).disposed(by: disposeBag)
    }
}

// MARK: - HeaderViewDelegate
extension ForgotPasswordViewController: AuthHeaderViewDelegate {
    public func backAction(from view: AuthHeaderView) {
        coordinatorDelegate?.dissmiss()
    }
}

// MARK: - Actions
private extension ForgotPasswordViewController {
    @IBAction func sendAction() {
        viewModel.sendActions()
    }
}
