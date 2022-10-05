//
//  CurrentUserLoader.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 23.04.2021.
//

import RestApiManager

public protocol CurrentUserLoaderProtocol {
    func autoSigninUser(completion: ((Result<User>) -> Void)?)
    func loadUser(completion: ((Result<User>) -> Void)?)
}

public final class CurrentUserLoader: CurrentUserLoaderProtocol {
    // MARK: - Properties
    // Boundaries
    private let restApiManager: RestApiManager

    // MARK: - Inits
    public init(restApiManager: RestApiManager) {
        self.restApiManager = restApiManager
    }

    // MARK: - Load
    public func autoSigninUser(completion: ((Result<User>) -> Void)? = nil) {
        switch UserData.shared.loginStatus {
        case .noLogin, .autoLogin:
            autoSigninUserWithDeviceId(completion: completion)
        case .primaryLogin, .secondaryLogin:
            loadUser(completion: completion)
        }
    }
    
    private func autoSigninUserWithDeviceId(completion: ((Result<User>) -> Void)? = nil) {
        let parameters = SigninWithDeviceIdParameters(deviceId: DeviceHelper.deviceId)
        let method = AuthRestApiMethods.signinWithDeviceId(parameters)
        restApiManager.call(method: method) { (result: Result<UserData>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let userData):
                    UserData.save(userData: userData)
                    completion?(.success(userData.user))
                case .failure(let error):
                    completion?(.failure(error))
                }
            }
        }
    }

    public func loadUser(completion: ((Result<User>) -> Void)? = nil) {
        let method = AuthRestApiMethods.currentUser
        restApiManager.call(method: method, completion: { (result: Result<User>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    UserData.save(user: user)
                case .failure:
                    break
                }

                completion?(result)
            }
        })
    }
}
