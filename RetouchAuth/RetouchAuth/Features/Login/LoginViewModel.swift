//
//  LoginViewModel.swift
//  SaleUp
//
//  Created by sxsasha on 12.03.18.
//  Copyright © 2018 Devlight. All rights reserved.
//

import RestApiManager
import RxSwift
import RxCocoa
import RetouchCommon

public protocol LoginViewModelProtocol {
    /// To View
    var successLoginedObservable: Observable<Bool> { get }

    /// default email
    func getDefaultEmail() -> String?

    /// From View
    var emailText: BehaviorRelay<String> { get }
    var passwordText: BehaviorRelay<String> { get }

    /// Observables
    var emailValidationResult: Observable<ValidationResult> { get }
    var passwordValidationResult: Observable<ValidationResult> { get }
    var isValid: Observable<Bool> { get }

    /// Actions
    func loginActions()

    func makeSigninWithAppleViewModel() -> SigninWithAppleViewModelProtocol
}

public final class LoginViewModel: LoginViewModelProtocol {
    // MARK: - Properties
    // Boundaries
    private let restApiManager: RestApiManager

    // Variables
    private var isAccountNotConfirm = BehaviorRelay<Bool>(value: false)
    private var defaultEmail: String?

    // Observables
    private var successLogined = BehaviorRelay(value: false)
    public lazy var successLoginedObservable = successLogined.asObservable()

    // Validators
    private let emailValidator: ValidatorProtocol = EmailValidator()
    private let passwordValidator: ValidatorProtocol = PasswordValidator()

    // From View
    public var emailText = BehaviorRelay<String>(value: "")
    public var passwordText = BehaviorRelay<String>(value: "")

    public var emailValidationResult: Observable<ValidationResult> {
        return emailText.asObservable().map({ (email) -> ValidationResult in
            return self.emailValidator.validate(email)
        })
    }

    public var passwordValidationResult: Observable<ValidationResult> {
        return passwordText.asObservable().map({ (password) -> ValidationResult in
            return self.passwordValidator.validate(password)
        })
    }

    public var isValid: Observable<Bool> {
        return Observable.combineLatest(emailValidationResult, passwordValidationResult) { email, password in
            return email.isValid && password.isValid
        }
    }

    public func getDefaultEmail() -> String? {
        return defaultEmail
    }

    // MARK: - Inits
    public init(defaultEmail: String? = nil,
                restApiManager: RestApiManager) {
        self.restApiManager = restApiManager
        self.defaultEmail = defaultEmail
    }

    // MARK: - ViewModel Factories
    public func makeSigninWithAppleViewModel() -> SigninWithAppleViewModelProtocol {
        return SigninWithAppleViewModel(restApiManager: restApiManager)
    }
}

// MARK: - RestApiable
extension LoginViewModel {
    public func loginActions() {
        let email = emailText.value
        let password = passwordText.value
        let parameters = SigninParameters(email: email, password: password)
        let method = AuthRestApiMethods.signin(parameters)

        ActivityIndicatorHelper.shared.show()
        restApiManager.call(method: method) { [weak self] (result: Result<UserData>) in
            DispatchQueue.main.async {
                ActivityIndicatorHelper.shared.hide()

                switch result {
                case .success(let userData):
                    UserData.save(userData: userData)
                    self?.successLogined.accept(true)
                case .failure(let error):
                    NotificationBannerHelper.showBanner(error)
                }
            }
        }
    }
}
