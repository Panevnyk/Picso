//
//  MoreViewModel.swift
//  RetouchMore
//
//  Created by Vladyslav Panevnyk on 08.03.2021.
//

import UIKit
import RestApiManager
import RetouchCommon

public protocol MoreViewModelProtocol {
    var isUserLoginedWithSecondaryLogin: Bool { get }
    var isRemoveAccountAvailable: Bool { get }
    var signInOutTitle: String? { get }
    var signInDescriptionTitle: String? { get }
    var userIdTitle: String { get }
    
    func removeAccount(completion: (() -> Void)?)
    func signOut(completion: (() -> Void)?)

    func makeTermsAndConditionsViewModel() -> InfoViewModelProtocol
    func makePrivacyPolicyViewModel() -> InfoViewModelProtocol
}

public final class MoreViewModel: MoreViewModelProtocol {
    // MARK: - Properties
    private let restApiManager: RestApiManager
    private let dataLoader: DataLoaderProtocol

    // MARK: - Init
    public init(restApiManager: RestApiManager, dataLoader: DataLoaderProtocol) {
        self.restApiManager = restApiManager
        self.dataLoader = dataLoader
    }

    // MARK: - Public methods
    public var isUserLoginedWithSecondaryLogin: Bool {
        UserData.shared.loginStatus == .secondaryLogin
    }
    
    public var isRemoveAccountAvailable: Bool {
        UserData.shared.loginStatus == .primaryLogin
        || UserData.shared.loginStatus == .secondaryLogin
    }
    
    public var signInOutTitle: String? {
        switch UserData.shared.loginStatus {
        case .autoLogin, .noLogin: return "Sign in"
        case .primaryLogin: return "Sign in to other account"
        case .secondaryLogin: return "Sign out"
        }
    }
    
    public var signInDescriptionTitle: String? {
        UserData.shared.loginStatus == .autoLogin || UserData.shared.loginStatus == .noLogin
            ? "Signing up helps you to save your credits and ready photos\nin case of loosing or changing mobile" : nil
    }
    
    public var userIdTitle: String {
        "UserId: " + UserData.shared.user.id
    }
    
    public func signOut(completion: (() -> Void)?) {
        let method = AuthRestApiMethods.signout
        restApiManager.call(method: method) { [weak self] (result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                UserData.shared.remove()
                self.dataLoader.loadData(completion: completion)
            }
        }
    }
    
    public func removeAccount(completion: (() -> Void)?) {
        let method = AuthRestApiMethods.removeAccount
        restApiManager.call(method: method) { [weak self] (result) in
            self?.signOut(completion: completion)
        }
    }
    
    public func makeTermsAndConditionsViewModel() -> InfoViewModelProtocol {
        return TermsAndConditionsViewModel()
    }

    public func makePrivacyPolicyViewModel() -> InfoViewModelProtocol {
        return PrivacyPolicyViewModel()
    }
}
