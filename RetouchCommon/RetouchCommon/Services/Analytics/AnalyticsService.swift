//
//  Analytics.swift
//  RetouchCommon
//
//  Created by Panevnyk Vlad on 29.06.2021.
//

import Firebase
import FirebaseAnalytics

public final class AnalyticsService {
    public static func setupUserID() {
        #if DEBUG
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        #endif
        Analytics.setUserID(DeviceIdService.deviceId)
    }
    
    public static func logScreen(_ screen: Constants.Analytics.EventScreen) {
        AnalyticsService.logEvent(name: screen.rawValue)
    }
    
    public static func logAction(_ action: Constants.Analytics.EventAction) {
        AnalyticsService.logEvent(name: action.rawValue)
    }
    
    private static func logEvent(name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }
}
