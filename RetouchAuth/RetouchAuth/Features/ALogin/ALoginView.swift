//
//  LoginView.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk on 14.07.2023.
//

import SwiftUI
import RetouchCommon

public struct ALoginView: View {
    @ObservedObject
    private var viewModel: ALoginViewModel
    
    public init(viewModel: ALoginViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        bodyView
            .ignoresSafeArea()
            .onAppear(perform: viewModel.onAppear)
    }

    var bodyView: some View {
        VStack(spacing: 16) {
            AuthHeaderSwiftView(
                title: "Login",
                backAction: nil
            )
            
            VStack(spacing: 16) {
                ATextField(
                    viewModel: viewModel.emailViewModel
                )
                .frame(height: 64)
                .padding(.top, 16)
                
                APasswordTextField(
                    viewModel: viewModel.passwordViewModel
                )
                .frame(height: 64)
                
                HStack {
                    ASecondaryButton(
                        text: "Forgot password",
                        action: viewModel.forgotPasswordAction
                    )
                    
                    Spacer()
                }
                
                AMainButton(
                    text: "Sign in",
                    action: viewModel.signInAction
                )
                .isAvailable(viewModel.isSignInAvailable)
                .padding(.top, 32)
                 
                Text("OR")
                    .foregroundColor(.kTextDarkGray)
                    .font(.kTitleText)
                
                ASigninWithAppleView(
                    signinWithAppleViewModel: viewModel.signinWithAppleViewModel
                )
                .frame(height: 44)
                
                UseAgreementsView(
                    delegate: viewModel.coordinatorDelegate
                )
                .padding(.top, 16)
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Text("I don't have an account")
                        .foregroundColor(.kGrayText)
                        .font(.kPlainText)
                    
                    ASecondaryButton(
                        text: "Sign up",
                        action: viewModel.signUpAction
                    )
                    
                    Spacer()
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 16)
            
            Spacer()
        }
    }
}

struct ALoginView_Previews: PreviewProvider {
    static var previews: some View {
        ALoginView(
            viewModel: ALoginViewModel(
                restApiManager: RestApiManagerMock(),
                coordinatorDelegate: nil
            )
        )
    }
}
