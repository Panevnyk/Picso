//
//  ARegisterationView.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk  on 21.07.2023.
//

import SwiftUI
import RetouchCommon

public struct ARegisterationView: View {
    @ObservedObject
    private var viewModel: ARegisterationViewModel
    
    public init(viewModel: ARegisterationViewModel) {
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
                title: "Registration",
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
                
                AMainButton(
                    text: "Sign up",
                    action: viewModel.signUpAction
                )
                .isAvailable(viewModel.isSignUpAvailable)
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
                    
                    Text("I already have an account")
                        .foregroundColor(.kGrayText)
                        .font(.kPlainText)
                    
                    ASecondaryButton(
                        text: "Sign in",
                        action: viewModel.signInAction
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

struct ARegisterationView_Previews: PreviewProvider {
    static var previews: some View {
        ARegisterationView(
            viewModel: ARegisterationViewModel(
                restApiManager: RestApiManagerMock(),
                coordinatorDelegate: nil
            )
        )
    }
}
