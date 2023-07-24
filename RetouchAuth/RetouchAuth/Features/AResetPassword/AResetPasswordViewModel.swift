//
//  AResetPasswordViewModel.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk  on 21.07.2023.
//

import Combine
import RetouchCommon
import RestApiManager

public protocol AResetPasswordViewCoordinatorDelegate: UseAgreementsDelegate {
    func didLoginSuccessfully()
    func dissmiss()
}

public class AResetPasswordViewModel: ObservableObject {
    // MARK: - Properties
    // Boundaries
    private let resetPasswordToken: String
    private let restApiManager: RestApiManager
    
    // ViewModels
    let passwordViewModel: ATextFieldViewModel
    
    // Delegates
    private(set) var coordinatorDelegate: AResetPasswordViewCoordinatorDelegate?
    
    // Combine
    @Published var isSendAvailable: Bool = false
    
    private lazy var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Init
    public init(
        resetPasswordToken: String,
        restApiManager: RestApiManager,
        coordinatorDelegate: AResetPasswordViewCoordinatorDelegate?
    ) {
        self.resetPasswordToken = resetPasswordToken
        self.restApiManager = restApiManager
        self.coordinatorDelegate = coordinatorDelegate

        passwordViewModel = ATextFieldViewModel(
            placeholder: "New password",
            config: .password,
            validator: PasswordValidator()
        )
        
        bindData()
    }
    
    // MARK: - Actions
    func onAppear() {
        AnalyticsService.logScreen(.resetPassword)
    }
    
    func sendAction() {
        resetPasswordAction()
    }
    
    func backAction() {
        coordinatorDelegate?.dissmiss()
    }
    
    // MARK: - Bind
    private func bindData() {
        passwordViewModel.validationResultPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (emailValidationResult) in
                guard let self = self else { return }
                self.isSendAvailable = emailValidationResult.isValid
            }
            .store(in: &subscriptions)
    }
}

// MARK: - RestApiable
extension AResetPasswordViewModel {
    public func resetPasswordAction() {
        guard let password = passwordViewModel.text
        else {
            return
        }
        
        let parameters = ResetPasswordParameters(password: password,
                                                 resetPasswordToken: resetPasswordToken)

        ActivityIndicatorHelper.shared.show()
        let method = AuthRestApiMethods.resetPassword(parameters)
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
