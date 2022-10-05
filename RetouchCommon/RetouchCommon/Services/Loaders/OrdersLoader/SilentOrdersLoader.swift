//
//  SilentOrdersLoader.swift
//  RetouchCommon
//
//  Created by Panevnyk Vlad on 20.08.2022.
//

import RxSwift

public protocol SilentOrdersLoaderProtocol: AnyObject {
    func startListenersIfNeeded()
}

public class SilentOrdersLoader: SilentOrdersLoaderProtocol {
    // MARK: - Properties
    private let ordersLoader: OrdersLoaderProtocol
    private let currentUserLoader: CurrentUserLoaderProtocol
    
    private var refreshTimer: Timer?
    
    private let disposeBag = DisposeBag()
    
    private var isListenersStarted = false

    // MARK: - Inits
    public init(ordersLoader: OrdersLoaderProtocol,
                currentUserLoader: CurrentUserLoaderProtocol) {
        self.ordersLoader = ordersLoader
        self.currentUserLoader = currentUserLoader
    }

    // MARK: - Public methods
    public func startListenersIfNeeded() {
        guard !isListenersStarted else { return }
        isListenersStarted = true
        ordersLoader.ordersPublisher
            .bind { (orders) in
                self.startTimerIfNeeded(orders: orders)
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    private func startTimerIfNeeded(orders: [Order]) {
        if isNeedToStartListeners(orders: orders) {
            startTimer()
        }
    }
    
    private func startTimer() {
        refreshTimer = Timer.scheduledTimer(timeInterval: 15 * 60, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: false)
    }

    private func invalidateTimer() {
        refreshTimer?.invalidate()
    }
    
    @objc private func runTimedCode() {
        currentUserLoader.autoSigninUser { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.ordersLoader.loadOrders(completion: nil)
            case .failure:
                break
            }
        }
    }
    
    private func isNeedToStartListeners(orders: [Order]) -> Bool {
        return orders.contains(where: { $0.status != .completed && $0.status != .canceled })
    }
}
