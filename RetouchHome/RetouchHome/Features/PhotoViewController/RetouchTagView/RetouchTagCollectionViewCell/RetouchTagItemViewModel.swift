//
//  RetouchTagItemViewModel.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 11.02.2021.
//

import UIKit

public protocol RetouchTagItemViewModelProtocol {
    var title: String { get }
    var isSelected: Bool { get set }
}

public final class RetouchTagItemViewModel: RetouchTagItemViewModelProtocol {
    public let title: String
    public var isSelected: Bool

    public init(
        title: String,
        isSelected: Bool
    ) {
        self.title = title
        self.isSelected = isSelected
    }
}
