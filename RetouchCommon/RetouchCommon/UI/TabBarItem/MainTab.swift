//
//  TabBarItem.swift
//  HotelionCommon
//
//  Created by Vladyslav Panevnyk on 25.11.2020.
//

import UIKit

public enum MainTab: Int {
    case home
    case examples
    case more

    public var image: UIImage? {
        switch self {
        case .home:
            return UIImage(named: "icHome", in: Bundle.common, compatibleWith: nil)?
                .withRenderingMode(.alwaysOriginal)
        case .examples:
            return UIImage(named: "icExamples", in: Bundle.common, compatibleWith: nil)?
                .withRenderingMode(.alwaysOriginal)
        case .more:
            return UIImage(named: "icInfo", in: Bundle.common, compatibleWith: nil)?
                .withRenderingMode(.alwaysOriginal)
        }
    }

    public var selectedImage: UIImage? {
        switch self {
        case .home:
            return UIImage(named: "icHomeSelected", in: Bundle.common, compatibleWith: nil)?
                .withRenderingMode(.alwaysOriginal)
        case .examples:
            return UIImage(named: "icExamplesSelected", in: Bundle.common, compatibleWith: nil)?
                .withRenderingMode(.alwaysOriginal)
        case .more:
            return UIImage(named: "icInfoSelected", in: Bundle.common, compatibleWith: nil)?
                .withRenderingMode(.alwaysOriginal)
        }
    }
}
