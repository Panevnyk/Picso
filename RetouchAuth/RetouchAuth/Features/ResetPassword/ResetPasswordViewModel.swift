//
//  ResetPasswordViewModel.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk on 26.03.2021.
//

import RestApiManager
import RxSwift
import RxCocoa
import RetouchCommon

public protocol ResetPasswordViewModelProtocol {
    // To View
    var successLoginedObservable: Observable<Bool> { get }

    // From View
    var passwordText: BehaviorRelay<String> { get }

    // Observables
    var passwordValidationResult: Observable<ValidationResult> { get }
    var isValid: Observable<Bool> { get }

    // Methods
    func sendActions()
}

public final class ResetPasswordViewModel: ResetPasswordViewModelProtocol {
    // MARK: - Properties
    // Boundaries
    private let resetPasswordToken: String
    private let restApiManager: RestApiManager

    // Variables
    private var isSuccessSend = BehaviorRelay<Bool>(value: false)
    var loginInfo = BehaviorRelay<LoginInfo>(value: LoginInfo())

    // Validators
    private var passwordValidator = PasswordValidator()

    // From View
    public var passwordText = BehaviorRelay<String>(value: "")

    // Observables
    private var successLogined = BehaviorRelay(value: false)
    public lazy var successLoginedObservable = successLogined.asObservable()

    public var passwordValidationResult: Observable<ValidationResult> {
        return passwordText.asObservable().map({ (value) -> ValidationResult in
            return self.passwordValidator.validate(value)
        })
    }

    public var isValid: Observable<Bool> {
        return passwordValidationResult.map({ $0.isValid })
    }

    // MARK: - Inits
    public init(resetPasswordToken: String,
                restApiManager: RestApiManager) {
        self.resetPasswordToken = resetPasswordToken
        self.restApiManager = restApiManager
    }
}

// MARK: - Public functions
extension ResetPasswordViewModel {
    public func sendActions() {
        let parameters = ResetPasswordParameters(password: passwordText.value,
                                                 resetPasswordToken: resetPasswordToken)

        ActivityIndicatorHelper.shared.show()
        let method = AuthRestApiMethods.resetPassword(parameters)
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
