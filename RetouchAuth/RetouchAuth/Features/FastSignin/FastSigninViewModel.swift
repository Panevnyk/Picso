//
//  OnFirstStartTutorialViewModel.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk on 12.03.2021.
//

import UIKit
import RetouchCommon
import RestApiManager

public protocol FastSigninViewModelProtocol {
    func makeSigninWithAppleViewModel() -> SigninWithAppleViewModelProtocol
}

public final class FastSigninViewModel: FastSigninViewModelProtocol {
    // MARK: - Properties
    private let restApiManager: RestApiManager

    // MARK: - Inits
    public init(restApiManager: RestApiManager) {
        self.restApiManager = restApiManager
    }
    
    // MARK: - ViewModel Factories
    public func makeSigninWithAppleViewModel() -> SigninWithAppleViewModelProtocol {
        return SigninWithAppleViewModel(restApiManager: restApiManager)
    }
}
