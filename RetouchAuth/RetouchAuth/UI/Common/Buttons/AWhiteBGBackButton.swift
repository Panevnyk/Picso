//
//  WhiteBGBackButton.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 14.07.2023.
//

import SwiftUI

struct AWhiteBGBackButton: View {
    private var action: () -> Void
    
    public init(
        action: @escaping () -> Void
    ) {
        self.action = action
    }
    
    var body: some View {
        Button(
            action: action,
            label: {
                ZStack {
                    Image("icLeftArrowPurple", bundle: .common)
                }
                .frame(width: 32, height: 32)
                .background(.white)
                .cornerRadius(16)
            }
        )
    }
}

struct WhiteBGBackButton_Previews: PreviewProvider {
    static var previews: some View {
        AWhiteBGBackButton(action: {})
    }
}
