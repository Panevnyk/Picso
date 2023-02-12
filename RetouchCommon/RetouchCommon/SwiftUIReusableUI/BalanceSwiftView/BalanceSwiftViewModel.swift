//
//  BalanceSwiftViewModel.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 17.09.2022.
//

import Combine

public class BalanceSwiftViewModel: ObservableObject {
    @Published public var gemCount: String

    private var gemCountSubscriber: AnyCancellable?

    public init() {
        gemCount = String(UserData.shared.user.gemCount)
        bindData()
    }

    private func bindData() {
        gemCountSubscriber = UserData.shared.user.$gemCount
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {
                let newValue = String($0)
                if String(newValue) != self.gemCount {
                    self.gemCount = String(newValue)
                }
            })
    }
}
