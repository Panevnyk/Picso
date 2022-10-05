//
//  RegistrationViewController.swift
//  SaleUp
//
//  Created by sxsasha on 02.03.18.
//  Copyright © 2018 Devlight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RestApiManager
import RetouchCommon

public protocol RegistrationViewControllerCoordinatorDelegate: BaseAuthCoordinatorDelegate {
    func successRegistration()
    func didLoginSuccessfully()
}

public final class RegistrationViewController: BaseScrollViewController {
    // MARK: - Properties
    // UI
    @IBOutlet private var headerView: AuthHeaderView!

    @IBOutlet private var emailTextField: SUTextField!
    @IBOutlet private var passwordTextField: SUPasswordTextField!

    @IBOutlet private var nextStepButton: PurpleButton!

    @IBOutlet private var orLabel: UILabel!
    @IBOutlet private var alreadyHaveAccountLabel: UILabel!

    @IBOutlet private var loginButton: UIButton!
    @IBOutlet private var signinWithAppleView: SigninWithAppleView!
    @IBOutlet private var useAgreementsLabel: UseAgreementsLabel!
    
    // Coordinator delegate
    public weak var coordinatorDelegate: RegistrationViewControllerCoordinatorDelegate?

    // ViewModels
    public var viewModel: RegisterViewModelProtocol!
    private let disposeBag = DisposeBag()

    // MARK: - Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        signinWithAppleView.viewModel = viewModel.makeSigninWithAppleViewModel()
        setupUI()
        setupViewModels()
        AnalyticsService.logScreen(.registration)
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
}

// MARK: - Customize
private extension RegistrationViewController {
    func setupUI() {
        useAgreementsLabel.useAgreementsDelegate = coordinatorDelegate
        
        headerView.setTitle("Registration")

        emailTextField.placeholder = "Email"
        passwordTextField.placeholder = "Password"

        emailTextField.config = .email

        nextStepButton.setTitle("Sign up", for: .normal)
        nextStepButton.backgroundColor = .kPurple
        nextStepButton.backgroundDisabledColor = .kNotActivePurple
        nextStepButton.isEnabled = true //false

        orLabel.text = "OR"
        orLabel.textColor = UIColor.kTextDarkGray
        orLabel.font = UIFont.kTitleText

        alreadyHaveAccountLabel.text = "I already have an account"
        alreadyHaveAccountLabel.textColor = UIColor.kTextMiddleGray
        alreadyHaveAccountLabel.font = UIFont.kPlainText

        loginButton.setTitle("Sign in", for: .normal)
        loginButton.setTitleColor(.kPurple, for: .normal)

        signinWithAppleView.delegate = self
    }
}

// MARK: - ViewModels
private extension RegistrationViewController {
    func setupViewModels() {
        bindUI()
        bindViewModel()
    }

    func bindUI() {
        emailTextField.textField.rx.text.map { $0 ?? "" }.bind(to: viewModel.emailText).disposed(by: disposeBag)

        passwordTextField.textField.rx.text.map { $0 ?? "" }.bind(to: viewModel.passwordText).disposed(by: disposeBag)
    }

    func bindViewModel() {
        // personal data
        viewModel.emailValidationResult.bind(to: emailTextField.validationResultObservable).disposed(by: disposeBag)

        viewModel.passwordValidationResult.bind(to: passwordTextField.validationResultObservable).disposed(by: disposeBag)

        // isValid
        viewModel.isValid.bind(to: nextStepButton.rx.isEnabled).disposed(by: disposeBag)

        // isSuccess
        viewModel.isSuccessRegisterObservable.subscribe(onNext: { [unowned self] (value) in
            guard value else { return }
            self.coordinatorDelegate?.successRegistration()
        }).disposed(by: disposeBag)

        viewModel.successLoginedObservable
            .filter { $0 == true }
            .subscribe(onNext: { [unowned self] _ in
                self.coordinatorDelegate?.didLoginSuccessfully()
            }).disposed(by: disposeBag)
    }
}

// MARK: - SigninWithAppleViewDelegate
extension RegistrationViewController: SigninWithAppleViewDelegate {
    public func didLoginSuccessfully() {
        coordinatorDelegate?.didLoginSuccessfully()
    }
}

// MARK: - Actions
private extension RegistrationViewController {
    @IBAction func nextStepAction() {
        viewModel.registerAction()
    }

    @IBAction func loginAction() {
        coordinatorDelegate?.didSelectLogin()
    }
}

