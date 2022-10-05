//
//  OrdersLoader.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 14.02.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RestApiManager

public struct CreateOrderModel {
    public let beforeImage: UIImage
    public let selectedRetouchGroups: [SelectedRetouchGroupParameters]
    public let price: Int
    public let isFreeOrder: Bool

    public init(beforeImage: UIImage,
                selectedRetouchGroups: [SelectedRetouchGroupParameters],
                price: Int,
                isFreeOrder: Bool) {
        self.beforeImage = beforeImage
        self.selectedRetouchGroups = selectedRetouchGroups
        self.price = price
        self.isFreeOrder = isFreeOrder
    }
}

public protocol OrdersLoaderProtocol {
    var ordersPublisher: BehaviorRelay<[Order]> { get set }
    var isLoadingPublisher: BehaviorRelay<Bool> { get set }

    func loadOrders(completion: ((Result<[Order]>) -> Void)?)
    func redoOrder(parameters: RedoOrderParameters, completion: ((Result<Order>) -> Void)?)
    func createOrder(createOrderModel: CreateOrderModel, completion: ((Result<Order>) -> Void)?)
    func removeOrder(parameters: RemoveOrderParameters, completion: ((Result<String>) -> Void)?)
    func sendRating(orderRatingParameters: OrderRatingParameters, completion: ((Result<Order>) -> Void)?)
    func sendIsNewOrder(parameters: IsNewOrderParameters, completion: ((Result<Order>) -> Void)?)
    func didChangeStatus(by model: OrderStatusChangedNotificationModel)
}

public final class OrdersLoader: OrdersLoaderProtocol {
    // MARK: - Properties
    // Boundaries
    private let restApiManager: RestApiManager

    // Data
    public var ordersPublisher = BehaviorRelay<[Order]>(value: [])
    public var isLoadingPublisher = BehaviorRelay<Bool>(value: false)

    // MARK: - Inits
    public init(restApiManager: RestApiManager) {
        self.restApiManager = restApiManager
    }

    // MARK: - Load
    public func loadOrders(completion: ((Result<[Order]>) -> Void)? = nil) {
        isLoadingPublisher.accept(true)

        let method = OrderRestApiMethods.getList
        restApiManager.call(method: method, completion: { [weak self] (result: Result<[Order]>) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoadingPublisher.accept(false)
                switch result {
                case .success(let orders):
                    self.ordersPublisher.accept(orders)
                case .failure:
                    self.ordersPublisher.accept([])
                }
                completion?(result)
            }
        })
    }

    public func redoOrder(parameters: RedoOrderParameters,
                          completion: ((Result<Order>) -> Void)? = nil) {
        let method = OrderRestApiMethods.redoOrder(parameters)

        isLoadingPublisher.accept(true)
        restApiManager.call(method: method) { [weak self] (result: Result<Order>) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoadingPublisher.accept(false)
                completion?(result)

                switch result {
                case .success(let redoOrder):
                    var orders = self.ordersPublisher.value
                    if let index = orders.firstIndex(where: { $0.id == redoOrder.id }) {
                        orders[index] = redoOrder
                        self.ordersPublisher.accept(orders)
                    }

                case .failure:
                    break
                }
            }
        }
    }

    public func createOrder(createOrderModel: CreateOrderModel,
                            completion: ((Result<Order>) -> Void)? = nil) {
        isLoadingPublisher.accept(true)
        uploadBeforeImage(beforeImage: createOrderModel.beforeImage) { [weak self] (result: Result<BeforeImage>) in
            guard let self = self else { return }

            switch result {
            case .success(let beforeImage):
                let parameters = CreateOrderParameters(beforeImage: beforeImage.image,
                                                       selectedRetouchGroups: createOrderModel.selectedRetouchGroups,
                                                       price: createOrderModel.price,
                                                       isFreeOrder: createOrderModel.isFreeOrder)
                let method = OrderRestApiMethods.create(parameters)
                self.restApiManager.call(method: method) { [weak self] (result: Result<Order>) in
                    guard let self = self else { return }

                    DispatchQueue.main.async {
                        switch result {
                        case .success(let newOrder):
                            UserData.shared.user.gemCount = UserData.shared.user.gemCount - newOrder.price
                            var orders = self.ordersPublisher.value
                            orders.insert(newOrder, at: 0)
                            self.ordersPublisher.accept(orders)
                        case .failure:
                            break
                        }

                        self.isLoadingPublisher.accept(false)
                        completion?(result)
                    }
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoadingPublisher.accept(false)
                    completion?(.failure(error))
                }
            }
        }
    }
    
    public func removeOrder(parameters: RemoveOrderParameters,
                            completion: ((Result<String>) -> Void)? = nil) {
        isLoadingPublisher.accept(true)

        let method = OrderRestApiMethods.removeOrder(parameters)
        self.restApiManager.call(method: method) { [weak self] (result: Result<String>) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success:
                    var orders = self.ordersPublisher.value
                    orders.removeAll(where: { $0.id == parameters.id })
                    self.ordersPublisher.accept(orders)
                case .failure:
                    break
                }

                self.isLoadingPublisher.accept(false)
                completion?(result)
            }
        }
    }
    
    public func sendRating(orderRatingParameters: OrderRatingParameters, completion: ((Result<Order>) -> Void)?) {
        let method = OrderRestApiMethods.sendRating(orderRatingParameters)

        isLoadingPublisher.accept(true)
        restApiManager.call(method: method) { [weak self] (result: Result<Order>) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoadingPublisher.accept(false)
                completion?(result)

                switch result {
                case .success(let order):
                    var orders = self.ordersPublisher.value
                    if let index = orders.firstIndex(where: { $0.id == order.id }) {
                        orders[index] = order
                        self.ordersPublisher.accept(orders)
                    }

                case .failure:
                    break
                }
            }
        }
    }
    
    public func sendIsNewOrder(parameters: IsNewOrderParameters, completion: ((Result<Order>) -> Void)?) {
        let method = OrderRestApiMethods.isNewOrder(parameters)

        isLoadingPublisher.accept(true)
        restApiManager.call(method: method) { [weak self] (result: Result<Order>) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoadingPublisher.accept(false)
                completion?(result)

                switch result {
                case .success(let order):
                    var orders = self.ordersPublisher.value
                    if let index = orders.firstIndex(where: { $0.id == order.id }) {
                        orders[index] = order
                        self.ordersPublisher.accept(orders)
                    }

                case .failure:
                    break
                }
            }
        }
    }
    
    public func didChangeStatus(by model: OrderStatusChangedNotificationModel) {
        let orders = self.ordersPublisher.value
        
        if let index = orders.firstIndex(where: { $0.id == model.orderId }) {
            orders[index].status = model.orderStatus
            orders[index].statusDescription = model.orderStatusDescription
            self.ordersPublisher.accept(orders)
        }
        
        if let userGemCount = model.userGemCount {
            UserData.shared.user.gemCount = userGemCount
        }
    }

    private func uploadBeforeImage(beforeImage: UIImage,
                                   completion: ((Result<BeforeImage>) -> Void)? = nil) {
        guard let pngBeforeImage = beforeImage.pngData() else {
            fatalError("!!! Fail to create png before image from UIImage opbject!!!")
        }

        let multipartObject = MultipartObject(
            key: "beforeImage",
            data: pngBeforeImage,
            mimeType: "image/png",
            filename: generateImageName()
        )
        let multipartData = CreateOrderMultipartData(multipartObjects: [multipartObject])
        let method = OrderRestApiMethods.uploadBeforeImage

        restApiManager.call(multipartData: multipartData, method: method)
        { (result: Result<BeforeImage>) in
            completion?(result)
        }
    }

    private func generateImageName() -> String {
        let name = String(Int(Date().timeIntervalSince1970MiliSec))
        return name + ".png"
    }
}
