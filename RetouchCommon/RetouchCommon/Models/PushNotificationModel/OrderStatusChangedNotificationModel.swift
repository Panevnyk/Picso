//
//  OrderStatusChangedNotificationModel.swift
//  RetouchCommon
//
//  Created by Panevnyk Vlad on 07.05.2021.
//

public class OrderStatusChangedNotificationModel: PushNotificationModel {
    public var orderId: String = ""
    public var orderStatus: OrderStatus = .waiting
    public var userGemCount: Int?
    public var orderStatusDescription: String? = nil
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        orderId = (try? container.decode(String.self, forKey: .orderId)) ?? ""
        orderStatus = (try? container.decode(OrderStatus.self, forKey: .orderStatus)) ?? .waiting
        userGemCount = Int((try? container.decode(String?.self, forKey: .userGemCount)) ?? "")
        orderStatusDescription = try? container.decode(String?.self, forKey: .orderStatusDescription)
        
        try super.init(from: decoder)
     }
    
    enum CodingKeys: String, CodingKey {
        case orderId, orderStatus, userGemCount, orderStatusDescription
    }
}
