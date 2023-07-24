//
//  AForgotPasswordView.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk  on 21.07.2023.
//

import SwiftUI
import RetouchCommon

public struct AForgotPasswordView: View {
    @ObservedObject
    private var viewModel: AForgotPasswordViewModel
    
    public init(viewModel: AForgotPasswordViewModel) {
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
                title: "Forgot password",
                isBackButtonAvailable: true,
                backAction: viewModel.backAction
            )
            
            VStack(alignment: .leading, spacing: 16) {
                Text("We will send reset password link to your email")
                    .foregroundColor(.kGrayText)
                    .font(.kPlainText)
                    .padding(.top, 16)
                
                ATextField(
                    viewModel: viewModel.emailViewModel
                )
                .frame(height: 64)
                .padding(.top, 16)
                
                AMainButton(
                    text: "Send",
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

struct AForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        AForgotPasswordView(
            viewModel: AForgotPasswordViewModel(
                restApiManager: RestApiManagerMock(),
                coordinatorDelegate: nil
            )
        )
    }
}
