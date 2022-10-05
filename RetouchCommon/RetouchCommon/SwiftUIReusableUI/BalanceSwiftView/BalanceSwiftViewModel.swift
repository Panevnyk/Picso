//
//  BalanceSwiftViewModel.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 17.09.2022.
//

import Combine

public class BalanceSwiftViewModel: ObservableObject {
    @Published public var gemCount = "0"

    private var gemCountSubscriber: AnyCancellable?

    public init() {
        bindData()
    }

    private func bindData() {
        gemCountSubscriber = UserData.shared.user.$gemCount
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { self.gemCount = String($0) })
    }
}
