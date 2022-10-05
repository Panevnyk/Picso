//
//  User.swift
//  HotelionCommon
//
//  Created by Vladyslav Panevnyk on 12.11.2020.
//

import Foundation
import RxSwift
import RxCocoa
import Combine

public final class User: Decodable {
    // MARK: - Properties
    public var id: String
    public var deviceId: String?
    public var appleUserId: String?
    public var fullName: String?
    public var email: String?
    @Published public var gemCount: Int {
        didSet {
            gemCountRelay.accept(gemCount); saveDataToKeychainService()
        }
    }
    public var freeGemCreditCount: Int?
    public var fcmToken: String?
    
    public var isLoginedWithAppleOrEmail: Bool {
        isLoginedWithApple || isLoginedWithEmail
    }
    
    public var isLoginedWithApple: Bool {
        !(appleUserId?.isEmpty ?? true)
    }
    
    public var isLoginedWithEmail: Bool {
        !isLoginedWithApple && !(email?.isEmpty ?? true)
    }

    // Observers
    private lazy var gemCountRelay = BehaviorRelay<Int>(value: gemCount)
    public lazy var gemCountObservable = gemCountRelay.asObservable()

    // CodingKeys
    private enum CodingKeys: String, CodingKey {
        case id, deviceId, appleUserId, fullName, email, gemCount, freeGemCreditCount, fcmToken
    }

    // MARK: - Inits
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(String.self, forKey: .id)) ?? ""
        deviceId = try? container.decode(String?.self, forKey: .deviceId)
        appleUserId = try? container.decode(String?.self, forKey: .appleUserId)
        fullName = try? container.decode(String?.self, forKey: .fullName)
        email = try? container.decode(String?.self, forKey: .email)
        gemCount = (try? container.decode(Int.self, forKey: .gemCount)) ?? 0
        freeGemCreditCount = (try? container.decode(Int.self, forKey: .freeGemCreditCount)) ?? 0
        fcmToken = try? container.decode(String?.self, forKey: .fcmToken)
    }

    public init(id: String,
                deviceId: String?,
                appleUserId: String?,
                fullName: String?,
                email: String?,
                gemCount: Int,
                freeGemCreditCount: Int?,
                fcmToken: String?
    ) {
        self.id = id
        self.deviceId = deviceId
        self.appleUserId = appleUserId
        self.fullName = fullName
        self.email = email
        self.gemCount = gemCount
        self.freeGemCreditCount = freeGemCreditCount
        self.fcmToken = fcmToken
    }

    func update(by user: User) {
        self.id = user.id
        self.deviceId = user.deviceId
        self.appleUserId = user.appleUserId
        self.fullName = user.fullName
        self.email = user.email
        self.gemCount = user.gemCount
        self.freeGemCreditCount = user.freeGemCreditCount
        self.fcmToken = user.fcmToken
    }
}

// MARK: - Empty
public extension User {
    static var empty: User {
        return User(
            id: "",
            deviceId: nil,
            appleUserId: nil,
            fullName: nil,
            email: nil,
            gemCount: 0,
            freeGemCreditCount: nil,
            fcmToken: nil
        )
    }
}

// MARK: - KeychainService
extension User {
    func saveDataToKeychainService() {
        KeychainService.save(key: RestApiConstants.userId, value: id)
        KeychainService.save(key: RestApiConstants.deviceId, value: deviceId ?? "")
        KeychainService.save(key: RestApiConstants.appleUserId, value: appleUserId ?? "")
        KeychainService.save(key: RestApiConstants.fullName, value: fullName ?? "")
        KeychainService.save(key: RestApiConstants.email, value: email ?? "")
        KeychainService.save(key: RestApiConstants.gemCount, value: String(gemCount))
        KeychainService.save(key: RestApiConstants.freeGemCreditCount, value: String(freeGemCreditCount ?? 0))
        KeychainService.save(key: RestApiConstants.fcmToken, value: fcmToken ?? "")
    }

    func readDataFromKeychainService() {
        id = KeychainService.load(key: RestApiConstants.userId) ?? ""
        deviceId = KeychainService.load(key: RestApiConstants.deviceId) ?? ""
        appleUserId = KeychainService.load(key: RestApiConstants.appleUserId) ?? ""
        fullName = KeychainService.load(key: RestApiConstants.fullName) ?? ""
        email = KeychainService.load(key: RestApiConstants.email) ?? ""
        gemCount = Int(KeychainService.load(key: RestApiConstants.gemCount) ?? "0") ?? 0
        freeGemCreditCount = Int(KeychainService.load(key: RestApiConstants.freeGemCreditCount) ?? "0") ?? 0
        fcmToken = KeychainService.load(key: RestApiConstants.fcmToken) ?? ""
    }

    func removeDataFromKeychainService() {
        KeychainService.remove(key: RestApiConstants.userId)
        KeychainService.remove(key: RestApiConstants.deviceId)
        KeychainService.remove(key: RestApiConstants.appleUserId)
        KeychainService.remove(key: RestApiConstants.fullName)
        KeychainService.remove(key: RestApiConstants.email)
        KeychainService.remove(key: RestApiConstants.gemCount)
        KeychainService.remove(key: RestApiConstants.freeGemCreditCount)
        KeychainService.remove(key: RestApiConstants.fcmToken)
    }
}
