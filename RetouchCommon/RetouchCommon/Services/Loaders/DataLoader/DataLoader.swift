//
//  DataLoader.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 20.03.2021.
//

public protocol DataLoaderProtocol: AnyObject {
    func loadData(completion: (() -> Void)?)
}

public class DataLoader: DataLoaderProtocol {
    // MARK: - Properties
    private let ordersLoader: OrdersLoaderProtocol
    private let silentOrdersLoader: SilentOrdersLoaderProtocol
    private let retouchGroupsLoader: RetouchGroupsLoaderProtocol
    private let currentUserLoader: CurrentUserLoaderProtocol

    private let downloadGroup = DispatchGroup()

    // MARK: - Inits
    public init(ordersLoader: OrdersLoaderProtocol,
                silentOrdersLoader: SilentOrdersLoaderProtocol,
                retouchGroupsLoader: RetouchGroupsLoaderProtocol,
                currentUserLoader: CurrentUserLoaderProtocol) {
        self.ordersLoader = ordersLoader
        self.silentOrdersLoader = silentOrdersLoader
        self.retouchGroupsLoader = retouchGroupsLoader
        self.currentUserLoader = currentUserLoader
    }

    // MARK: - Public methods
    public func loadData(completion: (() -> Void)?) {
        downloadGroup.enter()

#if DEBUG
        print("Load data will autoSigninUser")
#endif
        self.currentUserLoader.autoSigninUser { result in
            switch result {
            case .success:
#if DEBUG
            print("Load data will loadOrders")
#endif
                self.downloadGroup.enter()
                self.ordersLoader.loadOrders { _ in
                    self.downloadGroup.leave()
                    self.silentOrdersLoader.startListenersIfNeeded()
                }

#if DEBUG
                print("Load data will loadRetouchGroups")
#endif
                self.downloadGroup.enter()
                self.retouchGroupsLoader.loadRetouchGroups { _ in self.downloadGroup.leave() }
            case .failure:
                break
            }
            
            self.downloadGroup.leave()
        }

        downloadGroup.notify(queue: DispatchQueue.main) { completion?() }
    }
}
