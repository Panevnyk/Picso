//
//  ARegisterationViewModel.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk  on 21.07.2023.
//

import Combine
import RetouchCommon
import RestApiManager

public protocol ARegistrationViewCoordinatorDelegate: BaseAuthCoordinatorDelegate {
    func successRegistration()
}

public class ARegisterationViewModel: ObservableObject {
    // MARK: - Properties
    // Boundaries
    private let restApiManager: RestApiManager
    
    // ViewModels
    let emailViewModel: ATextFieldViewModel
    let passwordViewModel: ATextFieldViewModel
    let signinWithAppleViewModel: SigninWithAppleViewModel
    
    // Delegates
    private(set) var coordinatorDelegate: ARegistrationViewCoordinatorDelegate?
    
    // Combine
    @Published var isSignUpAvailable: Bool = false
    
    private lazy var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Init
    public init(
        restApiManager: RestApiManager,
        coordinatorDelegate: ARegistrationViewCoordinatorDelegate?
    ) {
        self.restApiManager = restApiManager
        self.coordinatorDelegate = coordinatorDelegate

        emailViewModel = ATextFieldViewModel(
            placeholder: "Email",
            config: .email,
            validator: EmailValidator()
        )
        
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
        AnalyticsService.logScreen(.registration)
    }
    
    func signInAction() {
        coordinatorDelegate?.didSelectLogin()
    }
    
    func signUpAction() {
        registerAction()
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
                self.isSignUpAvailable = emailValidationResult.isValid && passwordValidationResult.isValid
            }
            .store(in: &subscriptions)
    }
}

// MARK: - RestApiable
extension ARegisterationViewModel {
    public func registerAction() {
        guard let email = emailViewModel.text,
              let password = passwordViewModel.text
        else {
            return
        }
        
        let parameters = SignupParameters(email: email, password: password)
        let method = AuthRestApiMethods.signup(parameters)

        ActivityIndicatorHelper.shared.show()
        restApiManager.call(method: method) { [weak self] (result: Result<UserData>) in
            DispatchQueue.main.async {
                ActivityIndicatorHelper.shared.hide()
                
                switch result {
                case .success(let userData):
                    UserData.save(userData: userData)
                    self?.didRegisterSuccessfully()
                case .failure(let error):
                    NotificationBannerHelper.showBanner(error)
                }
            }
        }
    }
    
    private func didRegisterSuccessfully() {
        coordinatorDelegate?.successRegistration()
    }
}

