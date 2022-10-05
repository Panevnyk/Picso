//
//  ReviewByURLService.swift
//  RetouchCommon
//
//  Created by Panevnyk Vlad on 20.08.2022.
//

import UIKit

public protocol ReviewByURLServiceProtocol {
    var shouldRequestReview: Bool { get }
    func requestReview()
}

public class ReviewByURLService: ReviewByURLServiceProtocol {
    private static let isReviewRequested = "ReviewByURLServiceIsReviewRequested"
    
    @KeychainBacked(key: ReviewByURLService.isReviewRequested)
    var isReviewRequested = "false"
    
    public init() {}
    
    public var shouldRequestReview: Bool {
        return isReviewRequested == "false"
    }
    
    public func requestReview() {
        let urlStr = Constants.retouchYouWriteReviewAppStoreLink
        guard let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        isReviewRequested = "true"
    }
}
