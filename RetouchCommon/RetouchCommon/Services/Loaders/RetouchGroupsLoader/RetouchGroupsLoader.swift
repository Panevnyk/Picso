//
//  RetouchGroupsLoader.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 26.02.2021.
//

import RxSwift
import RxCocoa
import RestApiManager

public protocol RetouchGroupsLoaderProtocol {
    var retouchGroupsPublisher: BehaviorRelay<[RetouchGroup]> { get set }
    var isLoadingPublisher: BehaviorRelay<Bool> { get set }

    func loadRetouchGroups(completion: ((Result<[RetouchGroup]>) -> Void)?)
}

public final class RetouchGroupsLoader: RetouchGroupsLoaderProtocol {
    // MARK: - Properties
    // Boundaries
    private let restApiManager: RestApiManager

    // Data
    public var retouchGroupsPublisher = BehaviorRelay<[RetouchGroup]>(value: [])
    public var isLoadingPublisher = BehaviorRelay<Bool>(value: false)

    // MARK: - Inits
    public init(restApiManager: RestApiManager) {
        self.restApiManager = restApiManager
    }

    // MARK: - Load
    public func loadRetouchGroups(completion: ((Result<[RetouchGroup]>) -> Void)?) {
        isLoadingPublisher.accept(true)

        let method = RetouchGroupRestApiMethods.getList
        restApiManager.call(method: method, completion: { [weak self] (result: Result<[RetouchGroup]>) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoadingPublisher.accept(false)
                switch result {
                case .success(let retouchGroups):
                    self.retouchGroupsPublisher.accept(retouchGroups)
                case .failure:
                    self.retouchGroupsPublisher.accept([])
                }

                completion?(result)
            }
        })
    }
}
