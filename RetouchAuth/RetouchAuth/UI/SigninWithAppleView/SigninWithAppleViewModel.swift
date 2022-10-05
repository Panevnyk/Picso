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
    private let restApiManager: RestApiManager

    // MARK: - Inits
    public init(restApiManager: RestApiManager) {
        self.restApiManager = restApiManager
    }

    // MARK: - Public methods
    public func signin(appleUserId: String, fullName: String?, email: String?,
                       completion: ((_ isLogined: Bool) -> Void)?) {

        let parameters = SigninWithAppleParameters(appleUserId: appleUserId,
                                                   fullName: fullName,
                                                   email: email)
        let method = AuthRestApiMethods.signinWithApple(parameters)

        restApiManager.call(method: method) { (result: Result<UserData>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let userData):
                    UserData.save(userData: userData)
                    completion?(true)
                case .failure(let error):
                    NotificationBannerHelper.showBanner(error)
                    completion?(false)
                }
            }
        }
    }
}
