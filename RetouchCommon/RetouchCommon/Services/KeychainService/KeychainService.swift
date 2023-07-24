//
//  KeychainService.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 12.11.2020.
//

import UIKit
import Security

// Constant Identifiers
public let userAccount: NSString = "AuthenticatedUser"

public let kSecClassValue = NSString(format: kSecClass)
public let kSecAttrSynchronizableValue = NSString(format: kSecAttrSynchronizable)
public let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
public let kSecValueDataValue = NSString(format: kSecValueData)
public let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
public let kSecAttrServiceValue = NSString(format: kSecAttrService)
public let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
public let kSecReturnDataValue = NSString(format: kSecReturnData)
public let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)

public final class KeychainService {
    /// Remove value from Keychain by key is synchronizable
    /// - Parameters:
    ///   - key: key for value
    ///   - synchronizable: is value shared cross iTunes connected devices
    public class func remove(key: String, synchronizable: Bool = false) {
        guard let data = "".data(using: .utf8) else {
            return
        }

        let dataFromString = NSData(data: data)
        // Instantiate a new default keychain query
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue,
                                                                               key,
                                                                               userAccount,
                                                                               (synchronizable ? kCFBooleanTrue : kCFBooleanFalse) as Any,
                                                                               dataFromString],
                                                                     forKeys: [kSecClassValue,
                                                                               kSecAttrServiceValue,
                                                                               kSecAttrAccountValue,
                                                                               kSecAttrSynchronizableValue,
                                                                               kSecValueDataValue])

        // Delete any existing items
        SecItemDelete(keychainQuery as CFDictionary)
    }
    
    /// Save value to Keychain by key is synchronizable
    /// - Parameters:
    ///   - key: key for value
    ///   - value: String
    ///   - synchronizable: is value shared cross iTunes connected devices
    public class func save(key: String, value: String, synchronizable: Bool = false) {
        guard let data = value.data(using: .utf8) else {
            return
        }
        let dataFromString = NSData(data: data)

        // Instantiate a new default keychain query
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue,
                                                                               key,
                                                                               userAccount,
                                                                               (synchronizable ? kCFBooleanTrue : kCFBooleanFalse) as Any,
                                                                               dataFromString],
                                                                     forKeys: [kSecClassValue,
                                                                               kSecAttrServiceValue,
                                                                               kSecAttrAccountValue,
                                                                               kSecAttrSynchronizableValue,
                                                                               kSecValueDataValue])

        // Delete any existing items
        SecItemDelete(keychainQuery as CFDictionary)

        // Add the new keychain item
        SecItemAdd(keychainQuery as CFDictionary, nil)
    }
    
    /// Load value from Keychain by key is synchronizable
    /// - Parameters:
    ///   - key: key for object
    ///   - synchronizable: is value shared cross iTunes connected devices
    /// - Returns: value with type String?
    public class func load(key: String, synchronizable: Bool = false) -> String? {
        let key = NSString(string: key)
        // Instantiate a new default keychain query
        // Tell the query to return a result
        // Limit our results to one item
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue,
                                                                               key,
                                                                               userAccount,
                                                                               (synchronizable ? kCFBooleanTrue : kCFBooleanFalse) as Any,
                                                                               kCFBooleanTrue as Any,
                                                                               kSecMatchLimitOneValue],
                                                                     forKeys: [kSecClassValue,
                                                                               kSecAttrServiceValue,
                                                                               kSecAttrAccountValue,
                                                                               kSecAttrSynchronizableValue,
                                                                               kSecReturnDataValue,
                                                                               kSecMatchLimitValue])

        var dataTypeRef: AnyObject?

        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var contentsOfKeychain: String? = nil

        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? Data {
                contentsOfKeychain = NSString(data: retrievedData, encoding: String.Encoding.utf8.rawValue) as String?
            }
        } else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
        }

        return contentsOfKeychain
    }
}
