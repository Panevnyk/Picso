//
//  LoginViewController.swift
//  SaleUp
//
//  Created by Panevnyk Vlad on 2/22/18.
//  Copyright © 2018 Devlight. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RetouchCommon
import RestApiManager

public protocol BaseAuthCoordinatorDelegate: UseAgreementsDelegate {
    func didSelectLogin()
    func didSelectSignUp()

    func didLoginSuccessfully()
}

public protocol LoginViewControllerCoordinatorDelegate: BaseAuthCoordinatorDelegate {
    func didSelectForgotPassword()
}

public final class LoginViewController: BaseScrollViewController {
    // MARK: - Properties
    // UI
    @IBOutlet private var headerView: AuthHeaderView!

    @IBOutlet private var emailTextField: SUTextField!
    @IBOutlet private var passwordTextField: SUPasswordTextField!
    @IBOutlet private var loginButton: PurpleButton!
    @IBOutlet private var signinWithAppleView: SigninWithAppleView!

    @IBOutlet private var orLabel: UILabel!
    @IBOutlet private var dontHaveAccountLabel: UILabel!

    @IBOutlet private var forgotPasswordButton: UIButton!
    @IBOutlet private var signUpButton: UIButton!
    @IBOutlet private var useAgreementsLabel: UseAgreementsLabel!
    
    // Coordinator delegate
    public weak var coordinatorDelegate: LoginViewControllerCoordinatorDelegate?

    // ViewModels
    public var viewModel: LoginViewModelProtocol!
    private let disposeBag = DisposeBag()

    // MARK: - Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        signinWithAppleView.viewModel = viewModel.makeSigninWithAppleViewModel()
        setupUI()
        setupViewModels()

        // get default email if contains
        if let defaultEmail = viewModel.getDefaultEmail() {
            emailTextField.text = defaultEmail
        }
        AnalyticsService.logScreen(.login)
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
}

// MARK: - ViewModels
private extension LoginViewController {
    func setupViewModels() {
        bindUI()
        bindViewModel()
    }

    func bindUI() {
        emailTextField.textField.rx.text
            .map { $0 ?? "" }
            .bind(to: viewModel.emailText)
            .disposed(by: disposeBag)

        passwordTextField.textField.rx.text
            .map { $0 ?? "" }
            .bind(to: viewModel.passwordText)
            .disposed(by: disposeBag)

        viewModel.isValid
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.emailValidationResult
            .bind(to: emailTextField.validationResultObservable)
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

// MARK: - Customize
private extension LoginViewController {
    func setupUI() {
        useAgreementsLabel.useAgreementsDelegate = coordinatorDelegate
        
        headerView.setTitle("Login")

        emailTextField.placeholder = "Email"
        passwordTextField.placeholder = "Password"

        loginButton.setTitle("Sign in", for: .normal)
        loginButton.backgroundColor = .kPurple
        loginButton.backgroundDisabledColor = .kNotActivePurple
        loginButton.isEnabled = true

        signinWithAppleView.delegate = self

        emailTextField.config = .email

        orLabel.text = "OR"
        orLabel.textColor = UIColor.kTextDarkGray
        orLabel.font = UIFont.kTitleText

        dontHaveAccountLabel.text = "I dont have an account"
        dontHaveAccountLabel.textColor = UIColor.kTextMiddleGray
        dontHaveAccountLabel.font = UIFont.kPlainText

        forgotPasswordButton.setTitle("Forgot password", for: .normal)
        forgotPasswordButton.setTitleColor(.kPurple, for: .normal)

        signUpButton.setTitle("Sign up", for: .normal)
        signUpButton.setTitleColor(.kPurple, for: .normal)
    }
}

// MARK: - SigninWithAppleViewDelegate
extension LoginViewController: SigninWithAppleViewDelegate {
    public func didLoginSuccessfully() {
        coordinatorDelegate?.didLoginSuccessfully()
    }
}

// MARK: - Actions
private extension LoginViewController {
    @IBAction func forgotPasswordAction() {
        coordinatorDelegate?.didSelectForgotPassword()
    }
    
    @IBAction func loginAction() {
        viewModel.loginActions()
    }

    @IBAction func signUpAction() {
        coordinatorDelegate?.didSelectSignUp()
    }
}
