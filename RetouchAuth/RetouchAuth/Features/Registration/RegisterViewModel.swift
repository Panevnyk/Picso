//
//  RegistrationViewModel.swift
//  SaleUp
//
//  Created by sxsasha on 15.03.18.
//  Copyright © 2018 Devlight. All rights reserved.
//

import RestApiManager
import RxSwift
import RxCocoa
import RestApiManager
import RetouchCommon

public protocol RegisterViewModelProtocol {
    // To View
    var isSuccessRegisterObservable: Observable<Bool> { get }
    var successLoginedObservable: Observable<Bool> { get }

    // From View
    var emailText: BehaviorRelay<String> { get }
    var passwordText: BehaviorRelay<String> { get }

    // Observables
    var emailValidationResult: Observable<ValidationResult> { get }
    var passwordValidationResult: Observable<ValidationResult> { get }

    var isValid: Observable<Bool> { get }

    // Actions
    func registerAction()

    func makeSigninWithAppleViewModel() -> SigninWithAppleViewModelProtocol
}

public final class RegisterViewModel: RegisterViewModelProtocol {
    // MARK: - Properties
    // Boundaries
    private let restApiManager: RestApiManager

    // Validators
    private var emailValidator: ValidatorProtocol = EmailValidator()
    private var passwordValidator: ValidatorProtocol = PasswordValidator()

    // From View
    public var emailText = BehaviorRelay<String>(value: "")
    public var passwordText = BehaviorRelay<String>(value: "")

    // Observables
    private var isSuccessRegister = BehaviorRelay<Bool>(value: false)
    public lazy var isSuccessRegisterObservable = isSuccessRegister.asObservable()

    private var successLogined = BehaviorRelay(value: false)
    public lazy var successLoginedObservable = successLogined.asObservable()

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
        return Observable.combineLatest(
            emailValidationResult,
            passwordValidationResult
        ) { email, password in
            return email.isValid
                && password.isValid
        }
    }

    // MARK: - Inits
    public init(restApiManager: RestApiManager) {
        self.restApiManager = restApiManager
    }

    // MARK: - ViewModel Factories
    public func makeSigninWithAppleViewModel() -> SigninWithAppleViewModelProtocol {
        return SigninWithAppleViewModel(restApiManager: restApiManager)
    }
}

// MARK: - RestApiable
extension RegisterViewModel {
    public func registerAction() {
        let parameters = SignupParameters(email: emailText.value,
                                          password: passwordText.value)
        let method = AuthRestApiMethods.signup(parameters)

        ActivityIndicatorHelper.shared.show()
        restApiManager.call(method: method) { [weak self] (result: Result<UserData>) in
            DispatchQueue.main.async {
                ActivityIndicatorHelper.shared.hide()
                switch result {
                case .success(let userData):
                    UserData.save(userData: userData)
                    self?.isSuccessRegister.accept(true)
                case .failure(let error):
                    NotificationBannerHelper.showBanner(error)
                }
            }
        }
    }
}

extension String {
    func validateRepeatField(object: String?) -> ValidationResult {
        guard let secondString = object, !secondString.isEmpty else {
            return .noResult
        }

        if self == secondString {
            return .success
        } else {
            return .error("Incorrect repeate")
        }
    }
}
