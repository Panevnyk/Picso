//
//  KeychainBacked.swift
//  RetouchCommon
//
//  Created by Panevnyk Vlad on 11.07.2022.
//

@propertyWrapper struct KeychainBacked<Value> {
    var wrappedValue: Value {
        get {
            let value = KeychainService.load(key: key) as? Value
            return value ?? defaultValue
        }
        set {
            if let value = newValue as? String {
                KeychainService.save(key: key, value: value)
            } else {
                KeychainService.remove(key: key)
            }
        }
    }

    private let key: String
    private let defaultValue: Value

    init(wrappedValue defaultValue: Value,
         key: String) {
        self.defaultValue = defaultValue
        self.key = key
    }
}

extension KeychainBacked where Value: ExpressibleByNilLiteral {
    init(key: String) {
        self.init(wrappedValue: nil, key: key)
    }
}
