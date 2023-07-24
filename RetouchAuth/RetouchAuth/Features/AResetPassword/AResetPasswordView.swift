//
//  AResetPasswordView.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk  on 21.07.2023.
//

import SwiftUI
import RetouchCommon

public struct AResetPasswordView: View {
    @ObservedObject
    private var viewModel: AResetPasswordViewModel
    
    public init(viewModel: AResetPasswordViewModel) {
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
                title: "Reset password",
                isBackButtonAvailable: true,
                backAction: viewModel.backAction
            )
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Create your new password and sign in")
                    .foregroundColor(.kGrayText)
                    .font(.kPlainText)
                    .padding(.top, 16)
                
                APasswordTextField(
                    viewModel: viewModel.passwordViewModel
                )
                .frame(height: 64)
                .padding(.top, 16)
                
                AMainButton(
                    text: "Sign in",
                    action: viewModel.sendAction
                )
                .isAvailable(viewModel.isSendAvailable)
                .padding(.top, 16)
                 
                UseAgreementsView(
                    delegate: viewModel.coordinatorDelegate
                )
                .padding(.top, 16)
            }
            .padding(.horizontal, 16)
            
            Spacer()
        }
    }
}

struct AResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        AResetPasswordView(
            viewModel: AResetPasswordViewModel(
                resetPasswordToken: "",
                restApiManager: RestApiManagerMock(),
                coordinatorDelegate: nil
            )
        )
    }
}
