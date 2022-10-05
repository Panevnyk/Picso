//
//  PushNotificationModel.swift
//  RetouchCommon
//
//  Created by Panevnyk Vlad on 07.05.2021.
//

public enum PushNotificationType: String, Decodable {
    case none = ""
    case orderCompleted = "order_completed"
    case orderCanceled = "order_canceled"
}

public class PushNotificationModel: Decodable {
    public var code: PushNotificationType = .none
}
