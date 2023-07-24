//
//  ASigninWithAppleView.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk [Contractor] on 17.07.2023.
//

import SwiftUI
import RetouchCommon

public struct ASigninWithAppleView: UIViewRepresentable {
    public typealias UIViewType = AUIKitSigninWithAppleView
    
    private let signinWithAppleViewModel: SigninWithAppleViewModel
    
    public init(signinWithAppleViewModel: SigninWithAppleViewModel) {
        self.signinWithAppleViewModel = signinWithAppleViewModel
    }
  
    public func makeUIView(context: Context) -> AUIKitSigninWithAppleView {
        let view = AUIKitSigninWithAppleView()
        view.viewModel = signinWithAppleViewModel
        return view
    }
    
    public func updateUIView(_ uiView: AUIKitSigninWithAppleView, context: Context) {}
}

struct ASigninWithAppleView_Previews: PreviewProvider {
    static var previews: some View {
        ASigninWithAppleView(
            signinWithAppleViewModel: SigninWithAppleViewModel(
                restApiManager: RestApiManagerMock(),
                delegate: nil
            )
        )
    }
}
