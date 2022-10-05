//
//  HomeHistoryViewModel.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 14.02.2021.
//

import RxSwift
import RxCocoa
import RetouchCommon

public protocol HomeHistoryViewModelDelegate: AnyObject {
    func reloadData()
}

public protocol HomeHistoryViewModelProtocol {
    var delegate: HomeHistoryViewModelDelegate? { get set }

    func bindData()
    func itemsCount(in section: Int) -> Int
    func itemViewModel(for item: Int) -> HomeHistoryItemViewModelProtocol
    func reloadList(completion: (() -> Void)?)
    
    func isNotificationsAvailable() -> Bool
    func getNotificationViewModel() -> NotificationViewModel

    func getOrder(for item: Int) -> Order
    func isOrderCompleted(by item: Int) -> Bool

    func makeOrderDetailViewModel(item: Int, feedbackService: FeedbackServiceProtocol) -> OrderDetailViewModelProtocol
}

public final class HomeHistoryViewModel: HomeHistoryViewModelProtocol {
    // MARK: - Properties
    // Boundaries
    private let dataLoader: DataLoaderProtocol
    private let ordersLoader: OrdersLoaderProtocol
    private let retouchGroupsLoader: RetouchGroupsLoaderProtocol
    private var savePhotoInfoService: SavePhotoInfoServiceProtocol

    // Data
    private var orders: [Order] = []
    private var retouchGroups: [RetouchGroup] = []
    private let disposeBag = DisposeBag()

    // Delegate
    public weak var delegate: HomeHistoryViewModelDelegate?

    // MARK: - Inits
    public init(dataLoader: DataLoaderProtocol,
                ordersLoader: OrdersLoaderProtocol,
                retouchGroupsLoader: RetouchGroupsLoaderProtocol,
                savePhotoInfoService: SavePhotoInfoServiceProtocol) {
        self.dataLoader = dataLoader
        self.ordersLoader = ordersLoader
        self.retouchGroupsLoader = retouchGroupsLoader
        self.savePhotoInfoService = savePhotoInfoService
    }
}

// MARK: - Bind
extension HomeHistoryViewModel {
    public func bindData() {
        ordersLoader.ordersPublisher
            .bind { (orders) in
                self.orders = orders
                self.delegate?.reloadData()
            }.disposed(by: disposeBag)

        retouchGroupsLoader.retouchGroupsPublisher
            .bind { (retouchGroups) in
                self.retouchGroups = retouchGroups
            }.disposed(by: disposeBag)
    }
}

// MARK: - Public methods
extension HomeHistoryViewModel {
    public func itemsCount(in section: Int) -> Int {
        return orders.count
    }

    public func itemViewModel(for item: Int) -> HomeHistoryItemViewModelProtocol {
        let order = getOrder(for: item)
        return HomeHistoryItemViewModel(
            beforeImage: order.beforeImage,
            afterImage: order.afterImage,
            isPayed: order.isPayed,
            isNew: order.isNewOrder,
            status: order.status)
    }

    public func reloadList(completion: (() -> Void)?) {
        dataLoader.loadData(completion: completion)
    }
    
    public func isNotificationsAvailable() -> Bool {
        return !savePhotoInfoService.isClosed
    }
    
    public func getNotificationViewModel() -> NotificationViewModel {
        return NotificationViewModel(notificationTitle: "Please, save your photos",
                                     notificationDescription: "A photo will be removed in 3 months after retouching from Picso storage.",
                                     indicatorImage: UIImage(named: "icInfoPurple", in: Bundle.common, compatibleWith: nil))
        { [weak self] in
            guard let self = self else { return }
            self.savePhotoInfoService.isClosed = true
            self.delegate?.reloadData()
        }
    }

    public func getOrder(for item: Int) -> Order {
        return orders[item]
    }

    public func isOrderCompleted(by item: Int) -> Bool {
        let order = getOrder(for: item)
        return order.status == .completed
    }

    public func makeOrderDetailViewModel(item: Int, feedbackService: FeedbackServiceProtocol) -> OrderDetailViewModelProtocol {
        return OrderDetailViewModel(ordersLoader: ordersLoader,
                                    feedbackService: feedbackService,
                                    retouchGroups: retouchGroups,
                                    order: getOrder(for: item))
    }
}
