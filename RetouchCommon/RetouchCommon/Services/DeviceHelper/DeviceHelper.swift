//
//  DeviceIdHelper.swift
//  RetouchCommon
//
//  Created by Panevnyk Vlad on 05.09.2021.
//

import UIKit

public final class DeviceHelper {
    private static let deviceIdAuthKey = "DeviceIdAuthKey"
    
    public static var deviceId: String {
        if let deviceId = KeychainService.load(key: deviceIdAuthKey, synchronizable: true) {
            return deviceId
        } else {
            let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
            KeychainService.save(key: deviceIdAuthKey, value: deviceId, synchronizable: true)
            return deviceId
        }
    }
}
