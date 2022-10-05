//
//  Bundle+HotelionCommon.swift
//  HotelionCommon
//
//  Created by Vladyslav Panevnyk on 11.11.2020.
//

import Foundation

public extension Bundle {
    static var home: Bundle {
        guard let bundle = Bundle(identifier: "vp.RetouchHome") else {
            fatalError("!!! Problem with Bundle.home identifier !!!")
        }
        return bundle
    }

    static var examples: Bundle {
        guard let bundle = Bundle(identifier: "vp.RetouchExamples") else {
            fatalError("!!! Problem with Bundle.examples identifier !!!")
        }
        return bundle
    }

    static var more: Bundle {
        guard let bundle = Bundle(identifier: "vp.RetouchMore") else {
            fatalError("!!! Problem with Bundle.more identifier !!!")
        }
        return bundle
    }

    static var auth: Bundle {
        guard let bundle = Bundle(identifier: "vp.RetouchAuth") else {
            fatalError("!!! Problem with Bundle.auth identifier !!!")
        }
        return bundle
    }

    static var common: Bundle {
        guard let bundle = Bundle(identifier: "vp.RetouchCommon") else {
            fatalError("!!! Problem with Bundle.common identifier !!!")
        }
        return bundle
    }
}
