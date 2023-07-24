//
//  AMainGrayButton.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk  on 21.07.2023.
//

import SwiftUI

public struct AMainGrayButton: View {
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
                        .foregroundColor(.kGrayText)
                        .font(.kTitleBigText)
                        .padding(.horizontal, 16)
                }
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.kGrayText, lineWidth: 1)
                )
            }
        )
    }
    
    public func isAvailable(_ isAvailable: Bool) -> some View {
        self.disabled(!isAvailable)
            .opacity(isAvailable ? 1 : 0.6)
    }
}

struct AMainGrayButton_Previews: PreviewProvider {
    static var previews: some View {
        AMainGrayButton(
            text: "Button",
            action: {}
        )
    }
}
