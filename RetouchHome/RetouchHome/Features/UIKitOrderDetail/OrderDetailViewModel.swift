//
//  OrderDetailViewModel.swift
//  RetouchHome
//
//  Created by Panevnyk Vlad on 05.07.2021.
//

import RestApiManager
import RetouchCommon
import RxSwift

public protocol OrderDetailViewModelProtocol {
    var title: String { get set }
    var description: String { get set }
    var price: String { get set }
    var isDownloadAndShareAvailable: Bool { get set }
    var isPayed: Bool { get set }
    var idRedoAvailable: Bool { get set }
    var rating: Int? { get set }
    var isNeedToShowRating: Bool { get set }

    var imageAfter: String { get set }
    var imageBefore: String { get set }

    func sendForRedo(redoDescription: String, completion: ((_ isSuccessfully: Bool) -> Void)?)
    func sendIsNotNewOrder(completion: ((_ isSuccessfully: Bool) -> Void)?)
    func removeOrder(completion: ((_ isSuccessfully: Bool) -> Void)?)
    func requestReview(force: Bool)
}

public extension OrderDetailViewModelProtocol {
    func makeImageInfoContainerViewModel() -> ImageInfoContainerViewModelProtocol {
        return ImageInfoContainerViewModel(
            title: title,
            description: description,
            price: price,
            isDownloadAndShareAvailable: isDownloadAndShareAvailable,
            isPayed: isPayed,
            idRedoAvailable: idRedoAvailable,
            rating: rating)
    }
}

public class OrderDetailViewModel: OrderDetailViewModelProtocol {
    private let ordersLoader: OrdersLoaderProtocol
    private let feedbackService: FeedbackServiceProtocol
    private let retouchGroupsLoader: RetouchGroupsLoaderProtocol
    private var order: Order {
        didSet { orderDidChange() }
    }
    
    private var retouchGroups: [RetouchGroup] = []

    public var title: String = ""
    public var description: String = ""
    public var price: String = ""
    public var isDownloadAndShareAvailable: Bool = false
    public var isPayed: Bool = false
    public var idRedoAvailable: Bool = false
    public var rating: Int? = nil
    public var isNeedToShowRating: Bool = false
    
    public var imageAfter: String = ""
    public var imageBefore: String = ""
    
    private let disposeBag = DisposeBag()
    
    public init(ordersLoader: OrdersLoaderProtocol,
                retouchGroupsLoader: RetouchGroupsLoaderProtocol,
                feedbackService: FeedbackServiceProtocol,
                order: Order) {
        self.ordersLoader = ordersLoader
        self.retouchGroupsLoader = retouchGroupsLoader
        self.feedbackService = feedbackService
        self.order = order
        
        bindData()
        orderDidChange()
    }
}

// MARK: - Bind
extension OrderDetailViewModel {
    public func bindData() {
        retouchGroupsLoader.retouchGroupsPublisher
            .bind { (retouchGroups) in
                self.retouchGroups = retouchGroups
            }.disposed(by: disposeBag)
    }
}
// MARK: - Private
extension OrderDetailViewModel {
    private func orderDidChange() {
        let presentableValue = order
            .makePresentableTitleAndDescription(retouchGroups: retouchGroups)
        self.title = presentableValue.title
        self.description = presentableValue.description
        self.price = String(order.price)
        self.isDownloadAndShareAvailable = order.isPayed
        self.isPayed = order.isPayed
        self.idRedoAvailable = !order.isRedo
        self.rating = order.rating
        self.isNeedToShowRating = order.rating == nil && order.isNewOrder

        self.imageAfter = order.afterImage ?? ""
        self.imageBefore = order.beforeImage ?? ""
    }

    public func sendForRedo(redoDescription: String, completion: ((_ isSuccessfully: Bool) -> Void)?) {
        let parameters = RedoOrderParameters(id: order.id, redoDescription: redoDescription)
        ordersLoader.redoOrder(parameters: parameters) { (result: Result<Order>) in
            switch result {
            case .success(let order):
                self.order = order
                completion?(true)
            case .failure(let error):
                NotificationBannerHelper.showBanner(error)
                completion?(false)
            }
        }
    }
    
    public func sendIsNotNewOrder(completion: ((_ isSuccessfully: Bool) -> Void)?) {
        let parameters = IsNewOrderParameters(id: order.id, isNewOrder: false)
        ordersLoader.sendIsNewOrder(parameters: parameters) { (result: Result<Order>) in
            switch result {
            case .success(let order):
                self.order = order
                completion?(true)
            case .failure(let error):
                NotificationBannerHelper.showBanner(error)
                completion?(false)
            }
        }
    }
    
    public func removeOrder(completion: ((_ isSuccessfully: Bool) -> Void)?) {
        ActivityIndicatorHelper.shared.show()
        
        let parameters = RemoveOrderParameters(id: order.id)
        ordersLoader.removeOrder(parameters: parameters) { (result: Result<String>) in
            ActivityIndicatorHelper.shared.hide()
            
            switch result {
            case .success:
                completion?(true)
            case .failure(let error):
                NotificationBannerHelper.showBanner(error)
                completion?(false)
            }
        }
    }
    
    public func requestReview(force: Bool) {
        feedbackService.requestReview(for: order, force: force) { [weak self] newOrder in
            guard let self = self else { return }
            guard let newOrder = newOrder else { return }
            self.order.rating = newOrder.rating
        }
    }
}

fileprivate extension Order {
    func makePresentableTitleAndDescription(retouchGroups: [RetouchGroup])
    -> (title: String, description: String) {
        var title = ""
        var description = ""

        selectedRetouchGroups.forEach { (selectedRetouchGroup) in
            if let retouchGroup = retouchGroups.first(
                where: { $0.id == selectedRetouchGroup.retouchGroupId }
            ) {
                if !title.isEmpty { title += ", " }
                title.append(retouchGroup.title)

                if !description.isEmpty { description += ", " }
                description.append(selectedRetouchGroup.descriptionForDesigner)
            }
        }

        return (title: title, description: description)
    }

}
