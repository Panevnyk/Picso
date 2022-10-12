//
//  HeaderViewSwift.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 17.09.2022.
//

import SwiftUI

public struct HeaderSwiftView: View {
    public var title: String
    public var expandableTitle: String?
    public var expandableShowDetail: Binding<Bool>?
    public var isBackButtonHidden: Bool

    public init(title: String = "",
                expandableTitle: String? = nil,
                expandableShowDetail: Binding<Bool>? = nil,
                isBackButtonHidden: Bool = true) {
        self.title = title
        self.expandableTitle = expandableTitle
        self.expandableShowDetail = expandableShowDetail
        self.isBackButtonHidden = isBackButtonHidden
    }

    public var body: some View {
        VStack {
            Spacer()

            HStack(spacing: 16) {
                BackSwiftButton()
                    .isHidden(isBackButtonHidden)

                HStack {
                    Text(title)
                        .font(.kBigTitleText)

                    Spacer()

                    ExpandableSwiftView(title: expandableTitle, showDetail: expandableShowDetail)

                    Spacer()

                    BalanceSwiftView()
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .padding([.leading, .trailing], 16)
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .zIndex(100)
    }
}

struct HeaderSwiftView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderSwiftView()
    }
}
