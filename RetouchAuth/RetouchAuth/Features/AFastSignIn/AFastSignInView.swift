//
//  AFastSignInView.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk  on 21.07.2023.
//

import SwiftUI
import RetouchCommon

public struct AFastSignInView: View {
    @ObservedObject
    private var viewModel: AFastSignInViewModel
    
    public init(viewModel: AFastSignInViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        bodyView
            .ignoresSafeArea()
            .onAppear(perform: viewModel.onAppear)
    }

    var bodyView: some View {
        ZStack(alignment: .topLeading) {
            Image("tutorialBGImage4", bundle: .common)
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Image("icBigHandFromTop", bundle: .common)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            
            VStack(spacing: 16) {
                Spacer()
                
                ASigninWithAppleView(
                    signinWithAppleViewModel: viewModel.signinWithAppleViewModel
                )
                .frame(height: 44)

                Text("OR")
                    .foregroundColor(.white)
                    .font(.kTitleText)
                
                AMainGrayButton(
                    text: "Use other sign in options",
                    action: viewModel.signInWithOtherOptionAction
                )
                
                UseAgreementsView(
                    delegate: viewModel.coordinatorDelegate,
                    isLightStyle: true
                )
                .frame(height: 44)
                .padding(.top, 16)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 64)
        }
    }
}

struct AFastSignInView_Previews: PreviewProvider {
    static var previews: some View {
        AFastSignInView(
            viewModel: AFastSignInViewModel(
                restApiManager: RestApiManagerMock(),
                coordinatorDelegate: nil
            )
        )
    }
}
