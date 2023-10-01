//
//  HomeViewModel.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 09.02.2021.
//

import Combine
import RetouchCommon
import RxSwift
import RxCocoa
import Photos

enum HomeViewState {
    case gallery
    case history
    case noInternetConnection
    case noAccessToGallery
    case loading
}

public final class HomeViewModel: ObservableObject {
    // MARK: - Protocol
    // Boundaries
    private let dataLoader: DataLoaderProtocol
    private let ordersLoader: OrdersLoaderProtocol
    private let retouchGroupsLoader: RetouchGroupsLoaderProtocol
    private let phPhotoLibraryPresenter: PHPhotoLibraryPresenterProtocol
    private let reachabilityService: ReachabilityServiceProtocol
    private var freeGemCreditCountService: FreeGemCreditCountServiceProtocol

    // Data
    private var isInitialDataLoaded = false
    private var orders: [Order] = []
    private var retouchGroups: [RetouchGroup] = []
    private var isNetworkConnected: Bool
    private var isDataNeedToReload: Bool = true
    private let disposeBag = DisposeBag()
    
    @Published var state: HomeViewState = .loading
    
    lazy var noInternetConnectionViewModel: PlaceholderViewModel = {
        PlaceholderViewModel(
            image: UIImage(named: "icNoInternetConnection", in: Bundle.common, compatibleWith: nil),
            title: "Ooops!",
            subtitle: "It seems there is something wrong with your internet connection"
        )
    }()
    
    lazy var noAccessToGalleryViewModel: PlaceholderViewModel = {
        PlaceholderViewModel(
            image: UIImage(named: "icNoAccessToPhotoLibrary", in: Bundle.common, compatibleWith: nil),
            title: "No access to photo library",
            subtitle: "To enable access please\ngo to your device setting",
            actionTitle: "Open Settings",
            action: openSettings
        )
    }()
    
    // MARK: - Inits
    public init(
        dataLoader: DataLoaderProtocol,
        ordersLoader: OrdersLoaderProtocol,
        retouchGroupsLoader: RetouchGroupsLoaderProtocol,
        phPhotoLibraryPresenter: PHPhotoLibraryPresenterProtocol,
        reachabilityService: ReachabilityServiceProtocol,
        freeGemCreditCountService: FreeGemCreditCountServiceProtocol
    ) {
        self.dataLoader = dataLoader
        self.ordersLoader = ordersLoader
        self.retouchGroupsLoader = retouchGroupsLoader
        self.phPhotoLibraryPresenter = phPhotoLibraryPresenter
        self.reachabilityService = reachabilityService
        self.freeGemCreditCountService = freeGemCreditCountService
        self.isNetworkConnected = reachabilityService.isNetworkConnected.value

        subscribeOnChanges()
    }

    public func loadData() {
        dataLoader.loadData { [weak self] in
            guard let self = self else { return }
            self.isInitialDataLoaded = true
            self.reloadUIIfNeeded()
        }
    }

    public func getOrdersCount() -> Int {
        return orders.count 
    }

    public func getRetouchGroups() -> [RetouchGroup] {
        return retouchGroups
    }

    public func requestPhotosAuthorization(completion: ((_ isAuthorized: Bool) -> Void)?) {
        phPhotoLibraryPresenter.requestPhotosAuthorization(completion: completion)
    }
    
    func needToShowFreeGemCreditCountAlert() -> Bool {
        return (UserData.shared.user.freeGemCreditCount ?? 0) > 0
        && ordersLoader.ordersPublisher.value.count == 0
        && freeGemCreditCountService.needToShowFreeGemsCountAlert
    }
    
    private func openSettings() {
        SettingsHelper.openSettings()
        AnalyticsService.logAction(.openSettings)
    }
}

// MARK: - bind
private extension HomeViewModel {
    func subscribeOnChanges() {
        ordersLoader.ordersPublisher
            .subscribe(onNext: { (orders) in
                self.orders = orders
                self.reloadUIIfNeeded()
            }).disposed(by: disposeBag)

        retouchGroupsLoader.retouchGroupsPublisher
            .subscribe(onNext: { (retouchGroups) in
                self.retouchGroups = retouchGroups
            }).disposed(by: disposeBag)

        reachabilityService.isNetworkConnected
            .subscribe(onNext: { (isNetworkConnected) in
                self.isNetworkConnected = isNetworkConnected
                if isNetworkConnected {
                    if self.isDataNeedToReload {
                        self.isDataNeedToReload = false
                        self.loadData()
                    } else {
                        self.presentChildViewControllers()
                    }
                } else {
                    self.reloadUIIfNeeded()
                }
            }).disposed(by: disposeBag)
    }

    func reloadUIIfNeeded() {
        guard isInitialDataLoaded else { return }
        
        if needToShowFreeGemCreditCountAlert() {
            let diamondsCount = String(UserData.shared.user.freeGemCreditCount ?? 0)
            self.presentFirstRetouchingForFreeAlert(diamondsCount: diamondsCount) { [weak self] in
                guard let self = self else { return }
                self.freeGemCreditCountService.needToShowFreeGemsCountAlert = false
                self.presentChildViewControllers()
            }
        } else {
            presentChildViewControllers()
        }
    }
    
    func presentChildViewControllers() {
        if !isNetworkConnected {
            state = .noInternetConnection
            AnalyticsService.logScreen(.internetConnectionErrorAlert)
        } else if orders.isEmpty {
            state = .loading
        
            requestPhotosAuthorization { [weak self] (isAuthorized) in
                guard let self = self else { return }

                if isAuthorized {
                    self.state = .gallery
                } else {
                    self.state = .noAccessToGallery
                    AnalyticsService.logScreen(.noAccessToGalleryAlert)
                }
            }
        } else {
            state = .history
        }
    }
}

// MARK: - Alerts
private extension HomeViewModel {
    func presentFirstRetouchingForFreeAlert(diamondsCount: String, closeAction: (() -> Void)?) {
        AnalyticsService.logScreen(.firstRetouchingForFreeAlert)
        let gotIt = RTAlertAction(title: "Got it",
                                  style: .default,
                                  action: { closeAction?() })
        let img = UIImage(named: "icFirstOrderForFree", in: Bundle.common, compatibleWith: nil)
        let alert = RTAlertController(title: "First retouching\nfor free",
                                      message: "Send your photo to our\ndesigners. You have \(diamondsCount) free\ndiamons for your first order.",
                                      image: img,
                                      actionPositionStyle: .horizontal)
        alert.addActions([gotIt])
        alert.show()
    }
}
