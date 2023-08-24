//
//  HomeHistoryViewModel.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk  on 27.07.2023.
//

import Combine
import RetouchCommon
import UIKit
import RxSwift
import RxCocoa

public protocol HomeHistoryCoordinatorDelegate: BaseBalanceCoordinatorDelegate, BaseCoordinatorDelegate {
    func didTapGallery()
    func didTapCamera()
    func didSelectOrderDetail(_ order: Order)
}

public class HomeHistoryViewModel: ObservableObject {
    // MARK: - Properties
    // Boundaries
    private let dataLoader: DataLoaderProtocol
    private let ordersLoader: OrdersLoaderProtocol
    private let retouchGroupsLoader: RetouchGroupsLoaderProtocol
    private var savePhotoInfoService: SavePhotoInfoServiceProtocol

    // Data
    private var orders: [Order] = [] {
        didSet { updateItemViewModels() }
    }
    private var retouchGroups: [RetouchGroup] = []
    private let disposeBag = DisposeBag()
    
    private var isViewAppeared = false

    // Delegate
    public weak var delegate: HomeHistoryCoordinatorDelegate?
    private var coordinatorDelegate: HomeHistoryCoordinatorDelegate?
    
    // Presentable
    @Published var itemViewModels: [HomeHistoryItemViewModel] = []
    @Published var isNotificationsAvailable: Bool
    
    // MARK: - Inits
    public init(
        dataLoader: DataLoaderProtocol,
        ordersLoader: OrdersLoaderProtocol,
        retouchGroupsLoader: RetouchGroupsLoaderProtocol,
        savePhotoInfoService: SavePhotoInfoServiceProtocol,
        coordinatorDelegate: HomeHistoryCoordinatorDelegate?
    ) {
        self.dataLoader = dataLoader
        self.ordersLoader = ordersLoader
        self.retouchGroupsLoader = retouchGroupsLoader
        self.savePhotoInfoService = savePhotoInfoService
        self.coordinatorDelegate = coordinatorDelegate
        self.isNotificationsAvailable = !savePhotoInfoService.isClosed
        
        bindData()
    }
    
    // MARK: - Public
    public func viewOnAppear() {
        guard !isViewAppeared else { return }
        isViewAppeared = true

        AnalyticsService.logScreen(.homeHistory)
    }
    
    public func refreshData() async {
        AnalyticsService.logAction(.refreshHistory)
        await withCheckedContinuation { continuation in
            dataLoader.loadData {
                continuation.resume()
            }
        }
    }
    
    public func didSelectBalance() {
        coordinatorDelegate?.didSelectBalanceAction()
    }
    
    public func didSelectGallery() {
        coordinatorDelegate?.didTapGallery()
        AnalyticsService.logAction(.galleryFromHistory)
    }

    public func didSelectCamera() {
        coordinatorDelegate?.didTapCamera()
        AnalyticsService.logAction(.cameraFromHistory)
    }
    
    public func didSelectItem(_ item: Int) {
        coordinatorDelegate?.didSelectOrderDetail(getOrder(for: item))
    }
}

// MARK: - Bind
extension HomeHistoryViewModel {
    public func bindData() {
        ordersLoader.ordersPublisher
            .bind { (orders) in
                self.orders = orders
            }.disposed(by: disposeBag)

        retouchGroupsLoader.retouchGroupsPublisher
            .bind { (retouchGroups) in
                self.retouchGroups = retouchGroups
            }.disposed(by: disposeBag)
    }
}

// MARK: - Item ViewModels
private extension HomeHistoryViewModel {
    func updateItemViewModels() {
        itemViewModels = orders.map { makeHomeHistoryItemViewModel(from: $0) }
    }
    
    func makeHomeHistoryItemViewModel(from order: Order) -> HomeHistoryItemViewModel {
        HomeHistoryItemViewModel(
            beforeImage: order.beforeImage,
            afterImage: order.afterImage,
            isPayed: order.isPayed,
            isNew: order.isNewOrder,
            status: order.status
        )
    }
}

// MARK: - Public methods
extension HomeHistoryViewModel {
    public func getNotificationViewModel() -> NotificationBannerViewModel {
        return NotificationBannerViewModel(
            notificationTitle: "Please, save your photos",
            notificationDescription: "A photo will be removed in 3 months after retouching from Picso storage.",
            indicatorImage: UIImage(
                named: "icInfoPurple",
                in: Bundle.common,
                compatibleWith: nil
            )
        ) { [weak self] in
            guard let self = self else { return }
            self.savePhotoInfoService.isClosed = true
            self.isNotificationsAvailable = false
        }
    }

    private func getOrder(for item: Int) -> Order {
        return orders[item]
    }

    public func isOrderCompleted(by item: Int) -> Bool {
        let order = getOrder(for: item)
        return order.status == .completed
    }
}
