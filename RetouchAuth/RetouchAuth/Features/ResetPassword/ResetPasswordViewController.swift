//
//  ResetPasswordViewController.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk on 26.03.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RestApiManager
import RetouchCommon

public protocol ResetPasswordCoordinatorDelegate: UseAgreementsDelegate {
    func didLoginSuccessfully()
    func dissmiss()
}

public final class ResetPasswordViewController: BaseScrollViewController {
    // MARK: - Properties
    // UI
    @IBOutlet private var headerView: AuthHeaderView!

    @IBOutlet private var hintLabel: UILabel!
    @IBOutlet private var passwordTextField: SUPasswordTextField!
    @IBOutlet private var sendButton: PurpleButton!
    @IBOutlet private var useAgreementsLabel: UseAgreementsLabel!
    
    // Coordinator delegate
    public weak var coordinatorDelegate: ResetPasswordCoordinatorDelegate?

    // ViewModels
    public var viewModel: ResetPasswordViewModelProtocol!
    private let disposeBag = DisposeBag()

    // MARK: - Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupViewModels()
        AnalyticsService.logScreen(.resetPassword)
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
}

// MARK: - UI
private extension ResetPasswordViewController {
    func setupUI() {
        useAgreementsLabel.useAgreementsDelegate = coordinatorDelegate
        
        headerView.setTitle("Reset password")
        headerView.isBackButtonHidden = false
        headerView.delegate = self

        hintLabel.text = "Create your new password and sign in"
        hintLabel.textColor = UIColor.kGrayText
        hintLabel.font = UIFont.kPlainText

        passwordTextField.placeholder = "New password"
        passwordTextField.config = .password

        sendButton.setTitle("Sign in", for: .normal)
        sendButton.backgroundColor = .kPurple
        sendButton.backgroundDisabledColor = .kNotActivePurple
    }
}

// MARK: - ViewModels
private extension ResetPasswordViewController {
    func setupViewModels() {
        bindUI()
        bindViewModel()
    }

    func bindUI() {
        passwordTextField.textField.rx.text
            .map { $0 ?? "" }
            .bind(to: viewModel.passwordText)
            .disposed(by: disposeBag)

        viewModel.isValid
            .bind(to: sendButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.passwordValidationResult
            .bind(to: passwordTextField.validationResultObservable)
            .disposed(by: disposeBag)
    }

    func bindViewModel() {
        viewModel.successLoginedObservable
            .filter { $0 == true }
            .subscribe(onNext: { [unowned self] _ in
                self.coordinatorDelegate?.didLoginSuccessfully()
            }).disposed(by: disposeBag)
    }
}

// MARK: - HeaderViewDelegate
extension ResetPasswordViewController: AuthHeaderViewDelegate {
    public func backAction(from view: AuthHeaderView) {
        coordinatorDelegate?.dissmiss()
    }
}

// MARK: - Actions
private extension ResetPasswordViewController {
    @IBAction func sendAction() {
        viewModel.sendActions()
    }
}
