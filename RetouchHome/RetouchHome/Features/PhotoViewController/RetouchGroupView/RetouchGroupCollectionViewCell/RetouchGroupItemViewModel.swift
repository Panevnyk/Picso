//
//  RetouchGroupItemViewModel.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 11.02.2021.
//

import UIKit

public protocol RetouchGroupItemViewModelProtocol {
    var title: String { get }
    var image: String { get }

    var isSelected: Bool { get set }
    var descriptionForDesigner: String { get set }
}

public final class RetouchGroupItemViewModel: RetouchGroupItemViewModelProtocol {
    public let title: String
    public let image: String

    public var isSelected: Bool
    public var descriptionForDesigner: String

    public init(
        title: String,
        image: String,
        isSelected: Bool,
        descriptionForDesigner: String) {
        self.title = title
        self.image = image
        self.isSelected = isSelected
        self.descriptionForDesigner = descriptionForDesigner
    }
}
