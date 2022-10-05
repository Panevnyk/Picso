//
//  FeedbackService.swift
//  RetouchCommon
//
//  Created by Panevnyk Vlad on 05.07.2021.
//

public protocol FeedbackServiceProtocol {
    func requestReview(for order: Order, force: Bool, completion: ((_ newOrder: Order?) -> Void)?)
}

public class FeedbackService: FeedbackServiceProtocol {
    // MARK: - Properties
    private let storeKitService: StoreKitServiceProtocol
    private let localFeedbackService: LocalFeedbackServiceProtocol
    private let remoteConfigService: RemoteConfigServiceProtocol
    
    // MARK: - Inits
    public init(storeKitService: StoreKitServiceProtocol,
                localFeedbackService: LocalFeedbackServiceProtocol,
                remoteConfigService: RemoteConfigServiceProtocol) {
        self.storeKitService = storeKitService
        self.localFeedbackService = localFeedbackService
        self.remoteConfigService = remoteConfigService
    }
    
    // MARK: - Request review
    public func requestReview(for order: Order, force: Bool, completion: ((_ newOrder: Order?) -> Void)?) {
        if isAppStoreReviewAvailable {
            requestAppStoreReview()
            completion?(nil)
        } else if force || isLocalReviewAvailable(for: order) {
            requestLocalReview(for: order, completion: completion)
        } else {
            completion?(nil)
        }
    }
    
    // MARK: - AppStore review
    private var isAppStoreReviewAvailable: Bool {
        /*remoteConfigService.isAppStoreFeedbackEnabled && */storeKitService.shouldRequestReview
    }
    
    private func requestAppStoreReview() {
        storeKitService.requestReview()
    }
    
    // MARK: - Local review
    private func isLocalReviewAvailable(for order: Order) -> Bool {
        /*remoteConfigService.isLocalFeedbackEnabled && */order.rating == nil
    }
    
    private func requestLocalReview(for order: Order, completion: ((_ newOrder: Order?) -> Void)?) {
        localFeedbackService.requestLocalReview(for: order, completion: completion)
    }
}
