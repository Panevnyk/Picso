//
//  HomeHistoryItemViewModel.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 16.02.2021.
//

import UIKit
import RetouchCommon

public protocol HomeHistoryItemViewModelProtocol {
    var beforeImage: String? { get set }
    var afterImage: String? { get set }
    var imageToShow: String? { get set }
    var isPayed: Bool { get set }
    var isNew: Bool { get set }
    var status: OrderStatus { get set }
}

public final class HomeHistoryItemViewModel: HomeHistoryItemViewModelProtocol {
    public var beforeImage: String?
    public var afterImage: String?
    public var imageToShow: String?
    public var isPayed: Bool
    public var isNew: Bool
    public var status: OrderStatus

    public init(beforeImage: String?,
                afterImage: String?,
                isPayed: Bool,
                isNew: Bool,
                status: OrderStatus) {
        self.beforeImage = beforeImage
        self.afterImage = afterImage
        self.imageToShow = status == .completed ? afterImage : beforeImage
        self.isPayed = isPayed
        self.isNew = isNew
        self.status = status
    }
}
