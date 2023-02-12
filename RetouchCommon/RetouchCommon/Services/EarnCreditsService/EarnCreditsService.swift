//
//  EarnCreditsService.swift
//  RetouchCommon
//
//  Created by Panevnyk Vlad on 11.07.2022.
//

import UIKit
import RestApiManager

public struct EarnCreditsModel {
    public let type: EarnCreditsType
    public let isAvailable: Bool
}

public enum EarnCreditsType: CaseIterable {
    case viewVideoAd
    case leaveRatingOnAppStore
    case leaveCommentByURLOnAppStore
    case followUsOnInstagram
    case followUsOnFacebook
}

public extension EarnCreditsType {
    var diamondPrice: Int {
        switch self {
        case .viewVideoAd: return 2
        case .leaveRatingOnAppStore: return 8
        case .leaveCommentByURLOnAppStore: return 8
        case .followUsOnInstagram: return 5
        case .followUsOnFacebook: return 5
        }
    }
    
    var description: String {
        switch self {
        case .viewVideoAd: return "View a video ad"
        case .leaveRatingOnAppStore: return "Leave a rating\non App Store"
        case .leaveCommentByURLOnAppStore: return "Leave a review\non App Store"
        case .followUsOnInstagram: return "Follow us on\nInstagram"
        case .followUsOnFacebook: return "Follow us on\nFacebook"
        }
    }
}

public protocol EarnCreditsServiceProtocol {
    func getEarnCreditsModels() -> [EarnCreditsModel]
    func earnCredits(by earnCreditsType: EarnCreditsType, completion: (() -> Void)?)
}

public class EarnCreditsService: EarnCreditsServiceProtocol {
    // MARK: - Properties
    private let storeKitService: StoreKitServiceProtocol
    private let reviewByURLService: ReviewByURLServiceProtocol
    private let rewardedAdsService: RewardedAdsServiceProtocol
    private let restApiManager: RestApiManager
    
    // MARK: - Inits
    public init(storeKitService: StoreKitServiceProtocol,
                reviewByURLService: ReviewByURLServiceProtocol,
                rewardedAdsService: RewardedAdsServiceProtocol,
                restApiManager: RestApiManager) {
        self.storeKitService = storeKitService
        self.reviewByURLService = reviewByURLService
        self.rewardedAdsService = rewardedAdsService
        self.restApiManager = restApiManager
    }
    
    // MARK: - Public
    public func getEarnCreditsModels() -> [EarnCreditsModel] {
        return [/*EarnCreditsModel(type: .viewVideoAd, isAvailable: true),*/
//                EarnCreditsModel(type: .leaveRatingOnAppStore, isAvailable: storeKitService.shouldRequestReview),
                EarnCreditsModel(type: .leaveCommentByURLOnAppStore, isAvailable: reviewByURLService.shouldRequestReview)/*,
                EarnCreditsModel(type: .followUsOnInstagram, isAvailable: true),
                EarnCreditsModel(type: .followUsOnFacebook, isAvailable: true)*/]
    }
    
    public func earnCredits(by earnCreditsType: EarnCreditsType, completion: (() -> Void)?) {
        switch earnCreditsType {
        case .viewVideoAd:
            rewardedAdsService.loadRewardedAd()
        case .leaveRatingOnAppStore:
            storeKitService.requestReview()
            refill(by: earnCreditsType, withDelay: true, completion: completion)
        case .leaveCommentByURLOnAppStore:
            reviewByURLService.requestReview()
            refill(by: earnCreditsType, withDelay: true, completion: completion)
        case .followUsOnInstagram:
            break
        case .followUsOnFacebook:
            break
        }
    }
}

// MARK: - API
private extension EarnCreditsService {
    func refill(by earnCreditsType: EarnCreditsType, withDelay: Bool, completion: (() -> Void)?) {
        let refillAmount = earnCreditsType.diamondPrice
        
        ActivityIndicatorHelper.shared.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + (withDelay ? 5.0 : 0.0)) {
            let parameters = GemsParameters(refillAmount: String(refillAmount))
            let method = GemsRestApiMethods.refill(parameters)
            self.restApiManager.call(method: method) { (result) in
                DispatchQueue.main.async {
                    ActivityIndicatorHelper.shared.hide()
                    switch result {
                    case .success:
                        UserData.shared.user.gemCount = UserData.shared.user.gemCount + refillAmount
                        AlertHelper.show(title: "You successfully earned \(refillAmount) gems", message: nil)
                    case .failure(let error):
                        NotificationBannerHelper.showBanner(error)
                    }
                    completion?()
                }
            }
        }
    }
}
