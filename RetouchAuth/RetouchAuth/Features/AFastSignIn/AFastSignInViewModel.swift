//
//  AFastSignInViewModel.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk  on 21.07.2023.
//

import UIKit
import RetouchCommon
import RestApiManager

public protocol AFastSignInViewCoordinatorDelegate: BaseLoginCoordinatorDelegate, UseAgreementsDelegate {
    func didSelectUseOtherSigninOptions()
}

public final class AFastSignInViewModel: ObservableObject {
    // MARK: - Properties
    // Boundaries
    private let restApiManager: RestApiManager
    
    // ViewModels
    let signinWithAppleViewModel: SigninWithAppleViewModel
    
    // Delegates
    private(set) var coordinatorDelegate: AFastSignInViewCoordinatorDelegate?

    // MARK: - Inits
    public init(
        restApiManager: RestApiManager,
        coordinatorDelegate: AFastSignInViewCoordinatorDelegate?
    ) {
        self.restApiManager = restApiManager
        self.coordinatorDelegate = coordinatorDelegate
        
        signinWithAppleViewModel = SigninWithAppleViewModel(
            restApiManager: restApiManager,
            delegate: coordinatorDelegate
        )
    }
    
    // MARK: - Actions
    func onAppear() {
        AnalyticsService.logScreen(.fastSignIn)
    }
    
    func signInWithOtherOptionAction() {
        coordinatorDelegate?.didSelectUseOtherSigninOptions()
        AnalyticsService.logAction(.fastSignInOtherOptions)
    }
}
