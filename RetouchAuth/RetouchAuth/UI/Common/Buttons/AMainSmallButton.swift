//
//  AMainSmallButton.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk  on 21.07.2023.
//

import SwiftUI

public struct AMainSmallButton: View {
    private let text: String
    private var action: () -> Void

    public init(
        text: String,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.action = action
    }

    public var body: some View {
        Button(
            action: action,
            label: {
                ZStack {
                    Text(text)
                        .foregroundColor(.white)
                        .font(.kTitleBigText)
                        .padding(.horizontal, 16)
                }
                .frame(height: 44)
                .background(Color.kPurple)
                .cornerRadius(6)
            }
        )
    }
    
    public func isAvailable(_ isAvailable: Bool) -> some View {
        self.disabled(!isAvailable)
            .opacity(isAvailable ? 1 : 0.6)
    }
}

struct AMainSmallButton_Previews: PreviewProvider {
    static var previews: some View {
        AMainSmallButton(
            text: "Button",
            action: {}
        )
    }
}

