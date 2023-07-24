//
//  LoginViewModel.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk on 14.07.2023.
//

import Combine
import RetouchCommon
import RestApiManager

public protocol BaseLoginCoordinatorDelegate: AnyObject {
    func didLoginSuccessfully()
}

public protocol BaseAuthCoordinatorDelegate: BaseLoginCoordinatorDelegate, UseAgreementsDelegate {
    func didSelectLogin()
    func didSelectSignUp()
}

public protocol ALoginViewCoordinatorDelegate: BaseAuthCoordinatorDelegate {
    func didSelectForgotPassword()
}

public class ALoginViewModel: ObservableObject {
    // MARK: - Properties
    // Boundaries
    private let restApiManager: RestApiManager
    
    // ViewModels
    let emailViewModel: ATextFieldViewModel
    let passwordViewModel: ATextFieldViewModel
    let signinWithAppleViewModel: SigninWithAppleViewModel
    
    // Delegates
    private(set) var coordinatorDelegate: ALoginViewCoordinatorDelegate?
    
    // Combine
    @Published var isSignInAvailable: Bool = false
    
    private lazy var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Init
    public init(
        restApiManager: RestApiManager,
        defaultEmail: String? = nil,
        coordinatorDelegate: ALoginViewCoordinatorDelegate?
    ) {
        self.restApiManager = restApiManager
        self.coordinatorDelegate = coordinatorDelegate

        emailViewModel = ATextFieldViewModel(
            placeholder: "Email",
            config: .email,
            validator: EmailValidator()
        )
        emailViewModel.text = defaultEmail
        
        passwordViewModel = ATextFieldViewModel(
            placeholder: "Password",
            config: .password,
            validator: PasswordValidator()
        )
        
        signinWithAppleViewModel = SigninWithAppleViewModel(
            restApiManager: restApiManager,
            delegate: coordinatorDelegate
        )
        
        bindData()
    }
    
    // MARK: - Actions
    func onAppear() {
        AnalyticsService.logScreen(.login)
    }
    
    func signInAction() {
        loginActions()
    }
    
    func signUpAction() {
        coordinatorDelegate?.didSelectSignUp()
    }
    
    func forgotPasswordAction() {
        coordinatorDelegate?.didSelectForgotPassword()
    }
    
    // MARK: - Bind
    private func bindData() {
        Publishers
            .CombineLatest(
                emailViewModel.validationResultPublisher,
                passwordViewModel.validationResultPublisher
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (emailValidationResult, passwordValidationResult) in
                guard let self = self else { return }
                self.isSignInAvailable = emailValidationResult.isValid && passwordValidationResult.isValid
            }
            .store(in: &subscriptions)
    }
}

// MARK: - RestApiable
extension ALoginViewModel {
    public func loginActions() {
        guard let email = emailViewModel.text,
              let password = passwordViewModel.text
        else {
            return
        }
        
        let parameters = SigninParameters(email: email, password: password)
        let method = AuthRestApiMethods.signin(parameters)

        ActivityIndicatorHelper.shared.show()
        restApiManager.call(method: method) { [weak self] (result: Result<UserData>) in
            DispatchQueue.main.async {
                ActivityIndicatorHelper.shared.hide()

                switch result {
                case .success(let userData):
                    UserData.save(userData: userData)
                    self?.didLoginSuccessfully()
                case .failure(let error):
                    NotificationBannerHelper.showBanner(error)
                }
            }
        }
    }
    
    private func didLoginSuccessfully() {
        coordinatorDelegate?.didLoginSuccessfully()
    }
}

