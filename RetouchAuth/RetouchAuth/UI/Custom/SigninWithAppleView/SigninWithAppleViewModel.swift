//
//  SigninWithAppleViewModel.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk on 16.03.2021.
//

import UIKit
import RestApiManager
import RetouchCommon

public protocol SigninWithAppleViewModelProtocol {
    func signin(appleUserId: String, fullName: String?, email: String?,
                completion: ((_ isLogined: Bool) -> Void)?)
}

public final class SigninWithAppleViewModel: SigninWithAppleViewModelProtocol {
    // MARK: - Properties
    // Boundaries
    private let restApiManager: RestApiManager
    
    // Delegate
    public weak var delegate: BaseLoginCoordinatorDelegate?

    // MARK: - Inits
    public init(
        restApiManager: RestApiManager,
        delegate: BaseLoginCoordinatorDelegate?
    ) {
        self.restApiManager = restApiManager
        self.delegate = delegate
    }

    // MARK: - Public methods
    public func signin(appleUserId: String, fullName: String?, email: String?,
                       completion: ((_ isLogined: Bool) -> Void)?) {
        AnalyticsService.logAction(.fastSignInWithApple)

        let parameters = SigninWithAppleParameters(appleUserId: appleUserId,
                                                   fullName: fullName,
                                                   email: email)
        let method = AuthRestApiMethods.signinWithApple(parameters)

        restApiManager.call(method: method) { [weak self] (result: Result<UserData>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let userData):
                    UserData.save(userData: userData)
                    self.delegate?.didLoginSuccessfully()
                    completion?(true)
                case .failure(let error):
                    NotificationBannerHelper.showBanner(error)
                    completion?(false)
                }
            }
        }
    }
}
