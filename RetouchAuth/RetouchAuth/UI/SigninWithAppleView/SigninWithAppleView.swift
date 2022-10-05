//
//  SigninWithAppleView.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk on 16.03.2021.
//

import UIKit
import RetouchCommon
import AuthenticationServices

public protocol SigninWithAppleViewDelegate: AnyObject {
    func didLoginSuccessfully()
}

public final class SigninWithAppleView: BaseCustomView {
    // MARK: - Properties
    public var viewModel: SigninWithAppleViewModelProtocol!

    public weak var delegate: SigninWithAppleViewDelegate?

    // MARK: - initialize
    public override func initialize() {
        setupUI()
    }
}

// MARK: - SetupUI
extension SigninWithAppleView {
    func setupUI() {
        backgroundColor = .clear
        
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)
        authorizationButton.cornerRadius = 6

        addSubviewUsingConstraints(view: authorizationButton)
    }
}

// MARK: - Public methods
extension SigninWithAppleView {
    func signinWithApple(appleUserId: String, fullName: String?, email: String?) {
        ActivityIndicatorHelper.shared.show()
        viewModel.signin(appleUserId: appleUserId, fullName: fullName, email: email) { [weak self] isLogined in
            if isLogined {
                self?.delegate?.didLoginSuccessfully()
            }
            ActivityIndicatorHelper.shared.hide()
        }
    }
}

// MARK: - Actions
extension SigninWithAppleView {
    @objc func handleAppleIdRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension SigninWithAppleView: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            var fullName: String? = nil
            if let credentialFullname = appleIDCredential.fullName,
               let givenName = credentialFullname.givenName,
               let familyName = credentialFullname.familyName {
                fullName = givenName + " " + familyName
            }
            let email = appleIDCredential.email

            signinWithApple(appleUserId: userIdentifier,
                            fullName: fullName,
                            email: email)
        }
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error)
    }
}
