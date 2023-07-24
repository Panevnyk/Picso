//
//  AForgotPasswordViewModel.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk  on 21.07.2023.
//

import Combine
import RetouchCommon
import RestApiManager

public protocol AForgotPasswordViewCoordinatorDelegate: UseAgreementsDelegate {
    func didSelectLoginWith(email: String)
    func dissmiss()
}

public class AForgotPasswordViewModel: ObservableObject {
    // MARK: - Properties
    // Boundaries
    private let restApiManager: RestApiManager
    
    // ViewModels
    let emailViewModel: ATextFieldViewModel
    
    // Delegates
    private(set) var coordinatorDelegate: AForgotPasswordViewCoordinatorDelegate?
    
    // Combine
    @Published var isSendAvailable: Bool = false
    
    private lazy var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Init
    public init(
        restApiManager: RestApiManager,
        coordinatorDelegate: AForgotPasswordViewCoordinatorDelegate?
    ) {
        self.restApiManager = restApiManager
        self.coordinatorDelegate = coordinatorDelegate

        emailViewModel = ATextFieldViewModel(
            placeholder: "Email",
            config: .email,
            validator: EmailValidator()
        )
        
        bindData()
    }
    
    // MARK: - Actions
    func onAppear() {
        AnalyticsService.logScreen(.forgotPassword)
    }
    
    func sendAction() {
        sendEmailAction()
    }
    
    func backAction() {
        coordinatorDelegate?.dissmiss()
    }
    
    // MARK: - Bind
    private func bindData() {
        emailViewModel.validationResultPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (emailValidationResult) in
                guard let self = self else { return }
                self.isSendAvailable = emailValidationResult.isValid
            }
            .store(in: &subscriptions)
    }
}

// MARK: - RestApiable
extension AForgotPasswordViewModel {
    public func sendEmailAction() {
        guard let email = emailViewModel.text
        else {
            return
        }
        
        let parameters = ForgotPasswordParameters(email: email)

        ActivityIndicatorHelper.shared.show()
        let method = AuthRestApiMethods.forgotPassword(parameters)
        restApiManager.call(method: method) { [weak self] (result: Result<String>) in
            DispatchQueue.main.async {
                ActivityIndicatorHelper.shared.hide()
                switch result {
                case .success:
                    self?.didSelectLoginWith(email: email)
                case .failure(let error):
                    NotificationBannerHelper.showBanner(error)
                }
            }
        }
    }
    
    private func didSelectLoginWith(email: String) {
        AlertHelper.show(title: nil, message: "Temporary password has been sent to your email", action: { (_) in
            self.coordinatorDelegate?.didSelectLoginWith(email: email)
        })
    }
}
