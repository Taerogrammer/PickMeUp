//
//  UserDefaultsManager.swift
//  PickMeUp
//
//  Created by 김태형 on 5/13/25.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    let storage: UserDefaults

    var wrappedValue: T {
        get { self.storage.object(forKey: self.key) as? T ?? self.defaultValue }
        set { self.storage.set(newValue, forKey: self.key) }
    }

    func removeObject() { storage.removeObject(forKey: key) }
}

final class UserDefaultsManager {
    enum Key: String {
        case isAutoLoginEnabled
    }

    @UserDefault(key: Key.isAutoLoginEnabled.rawValue, defaultValue: false, storage: .standard)
    static var isAutoLoginEnabled: Bool
}
