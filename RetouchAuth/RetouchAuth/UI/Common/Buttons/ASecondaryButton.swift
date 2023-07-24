//
//  ASecondaryButton.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk  on 21.07.2023.
//

import SwiftUI

struct ASecondaryButton: View {
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
                        .foregroundColor(Color.kPurple)
                        .font(.kPlainText)
                }
            }
        )
    }
    
    public func isAvailable(_ isAvailable: Bool) -> some View {
        self.disabled(!isAvailable)
            .opacity(isAvailable ? 1 : 0.6)
    }
}

struct ASecondaryButton_Previews: PreviewProvider {
    static var previews: some View {
        ASecondaryButton(
            text: "Button",
            action: {}
        )
    }
}
