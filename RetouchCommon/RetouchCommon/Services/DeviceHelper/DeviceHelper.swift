//
//  DeviceIdHelper.swift
//  RetouchCommon
//
//  Created by Panevnyk Vlad on 05.09.2021.
//

import UIKit

public final class DeviceHelper {
    private static let deviceIdAuthKey = "DeviceIdAuthKey"
    private static let deviceFreeGemsAvailableKey = "DeviceFreeGemsAvailableKey"
    
    public static var deviceId: String {
        if let deviceId = KeychainService.load(key: deviceIdAuthKey, synchronizable: true) {
            return deviceId
        } else {
            let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
            KeychainService.save(key: deviceIdAuthKey, value: deviceId, synchronizable: true)
            return deviceId
        }
    }
    
    public static var freeGemsAvailable: Bool {
        get {
            if let value = KeychainService.load(key: deviceFreeGemsAvailableKey, synchronizable: true) {
#if DEBUG
                print("FreeGemsAvailable get: \(value), \(value == "1")")
#endif
                return value == "1"
            } else {
#if DEBUG
                print("FreeGemsAvailable get: \("true")")
#endif
                return true
            }
        }
        set {
            KeychainService.save(key: deviceFreeGemsAvailableKey, value: newValue ? "1" : "0", synchronizable: true)
#if DEBUG
                print("FreeGemsAvailable set: \(newValue)")
#endif
        }
    }
}
