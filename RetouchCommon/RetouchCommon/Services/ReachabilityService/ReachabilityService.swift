//
//  MonitorNetworkConnectionService.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 20.03.2021.
//

import Network
import RxSwift
import RxCocoa

public protocol ReachabilityServiceProtocol {
    var isNetworkConnected: BehaviorRelay<Bool> { get set }
}

public final class ReachabilityService: ReachabilityServiceProtocol {
    private let monitirQueue = DispatchQueue(label: "Monitor")
    private let monitor = NWPathMonitor()

    public lazy var isNetworkConnected = BehaviorRelay(value: monitor.currentPath.status == .satisfied)

    public init() {
        startMonitorNetworkConnection()
    }

    private func startMonitorNetworkConnection() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                guard let self = self else { return }

                let isConnected = path.status == .satisfied
                if isConnected != self.isNetworkConnected.value {
                    self.isNetworkConnected.accept(isConnected)
                }
            }
        }

        monitor.start(queue: monitirQueue)
    }
}
