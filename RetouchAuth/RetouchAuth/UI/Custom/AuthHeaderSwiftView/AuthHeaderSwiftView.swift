//
//  AuthHeaderSwiftView.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 14.07.2023.
//

import SwiftUI

public struct AuthHeaderSwiftView: View {
    private let title: String
    private let isBackButtonAvailable: Bool
    private var backAction: (() -> Void)?
    
    public init(
        title: String,
        isBackButtonAvailable: Bool = false,
        backAction: (() -> Void)?
    ) {
        self.title = title
        self.isBackButtonAvailable = isBackButtonAvailable
        self.backAction = backAction
    }
    
    public var body: some View {
        ZStack {
            Image("icAuthHeader", bundle: .common)
                .resizable()
                .frame(maxWidth: .infinity)
            
            VStack {
                Spacer()
                
                HStack(spacing: 16) {
                    AWhiteBGBackButton { backAction?() }
                        .isHidden(!isBackButtonAvailable)
                    
                    Text(title)
                        .foregroundColor(.white)
                        .font(.kBigTitleText)
                    
                    Spacer()
                }
                .padding(.leading, 16)
                .frame(height: 56)
            }
        }
        .frame(height: 124)
        .frame(maxWidth: .infinity)
    }
}

struct AuthHeaderSwiftView_Previews: PreviewProvider {
    static var previews: some View {
        AuthHeaderSwiftView(
            title: "Login",
            isBackButtonAvailable: true,
            backAction: nil
        )
    }
}
