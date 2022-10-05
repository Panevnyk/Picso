//
//  HomeViewModel.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 09.02.2021.
//

import RetouchCommon
import RxSwift
import RxCocoa
import Photos

public protocol HomeViewModelDelegate: AnyObject {
    func presentHomeHistory()
    func presentGallery()
    func presentInternetConnectionError()
    func presentFirstRetouchingForFreeAlert(diamondsCount: String, closeAction: (() -> Void)?)
}

public protocol HomeViewModelProtocol {
    var delegate: HomeViewModelDelegate? { get set }

    func loadData()
    func getOrdersCount() -> Int
    func requestPhotosAuthorization(completion: ((_ isAuthorized: Bool) -> Void)?)

    func makeHomeHistoryViewModel() -> HomeHistoryViewModelProtocol
    func makePhotoViewModel(asset: PHAsset) -> PhotoViewModelProtocol
    func makePhotoViewModel(image: UIImage) -> PhotoViewModelProtocol
}

public final class HomeViewModel: HomeViewModelProtocol {
    // MARK: - Protocol
    // Boundaries
    private let dataLoader: DataLoaderProtocol
    private let ordersLoader: OrdersLoaderProtocol
    private let phImageLoader: PHImageLoaderProtocol
    private let retouchGroupsLoader: RetouchGroupsLoaderProtocol
    private let phPhotoLibraryPresenter: PHPhotoLibraryPresenterProtocol
    private let reachabilityService: ReachabilityServiceProtocol
    private var iapService: IAPServiceProtocol
    private var freeGemCreditCountService: FreeGemCreditCountServiceProtocol
    private let savePhotoInfoService: SavePhotoInfoServiceProtocol

    // Data
    private var isInitialDataLoaded = false
    private var orders: [Order] = []
    private var retouchGroups: [RetouchGroup] = []
    private var isNetworkConnected: Bool
    private var isDataNeedToReload: Bool = true
    private let disposeBag = DisposeBag()

    // Delegate
    public weak var delegate: HomeViewModelDelegate?

    // MARK: - Inits
    public init(dataLoader: DataLoaderProtocol,
                ordersLoader: OrdersLoaderProtocol,
                phImageLoader: PHImageLoaderProtocol,
                retouchGroupsLoader: RetouchGroupsLoaderProtocol,
                phPhotoLibraryPresenter: PHPhotoLibraryPresenterProtocol,
                reachabilityService: ReachabilityServiceProtocol,
                iapService: IAPServiceProtocol,
                freeGemCreditCountService: FreeGemCreditCountServiceProtocol,
                savePhotoInfoService: SavePhotoInfoServiceProtocol,
                delegate: HomeViewModelDelegate)
    {
        self.dataLoader = dataLoader
        self.ordersLoader = ordersLoader
        self.phImageLoader = phImageLoader
        self.retouchGroupsLoader = retouchGroupsLoader
        self.phPhotoLibraryPresenter = phPhotoLibraryPresenter
        self.reachabilityService = reachabilityService
        self.iapService = iapService
        self.freeGemCreditCountService = freeGemCreditCountService
        self.savePhotoInfoService = savePhotoInfoService
        self.delegate = delegate
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

    public func requestPhotosAuthorization(completion: ((_ isAuthorized: Bool) -> Void)?) {
        phPhotoLibraryPresenter.requestPhotosAuthorization(completion: completion)
    }
    
    func needToShowFreeGemCreditCountAlert() -> Bool {
        return (UserData.shared.user.freeGemCreditCount ?? 0) > 0
        && ordersLoader.ordersPublisher.value.count == 0
        && freeGemCreditCountService.needToShowFreeGemsCountAlert
    }
}

// MARK: - ViewModels factory
extension HomeViewModel {
    public func makeHomeHistoryViewModel() -> HomeHistoryViewModelProtocol {
        return HomeHistoryViewModel(dataLoader: dataLoader,
                                    ordersLoader: ordersLoader,
                                    retouchGroupsLoader: retouchGroupsLoader,
                                    savePhotoInfoService: savePhotoInfoService)
    }

    public func makePhotoViewModel(asset: PHAsset) -> PhotoViewModelProtocol {
        return PhotoViewModel(ordersLoader: ordersLoader,
                              phImageLoader: phImageLoader,
                              retouchGroups: retouchGroups,
                              iapService: iapService,
                              freeGemCreditCountService: freeGemCreditCountService,
                              asset: asset)
    }
    
    public func makePhotoViewModel(image: UIImage) -> PhotoViewModelProtocol {
        return PhotoViewModel(ordersLoader: ordersLoader,
                              phImageLoader: phImageLoader,
                              retouchGroups: retouchGroups,
                              iapService: iapService,
                              freeGemCreditCountService: freeGemCreditCountService,
                              image: image)
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
            self.delegate?.presentFirstRetouchingForFreeAlert(diamondsCount: diamondsCount) { [weak self] in
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
            delegate?.presentInternetConnectionError()
        } else if orders.isEmpty {
            delegate?.presentGallery()
        } else {
            delegate?.presentHomeHistory()
        }
    }
}
