//
//  ExpandableSwiftView.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 17.09.2022.
//

import SwiftUI

public struct ExpandableSwiftView: View {
    private var title: String

    @State private var showDetail = false

    init?(title: String?) {
        guard let title = title else { return nil }
        self.title = title
    }

    public var body: some View {
        Button {
            showDetail = !showDetail
        } label: {
            HStack(spacing: 6) {
                Text(title)
                    .font(.kTitleBigText)
                    .foregroundColor(.black)

                Image("icDownArrowBlack", bundle: .common)
                    .rotationEffect(.degrees(showDetail ? 180 : 0))
                    .animation(.easeInOut, value: showDetail)
            }
        }
    }
}

struct ExpandableSwiftView_Previews: PreviewProvider {
    static var previews: some View {
        ExpandableSwiftView(title: "Example")
    }
}
