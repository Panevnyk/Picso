//
//  PhotoViewModel.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 11.02.2021.
//

import RxSwift
import RxCocoa
import RetouchCommon
import RestApiManager
import Foundation
import Photos

public protocol PhotoViewModelDelegate: AnyObject {
    func didUpdateImage(_ image: UIImage?)
    func didUpdateOpenTagIndex(_ openTagIndex: Int?, previousValue: Int?)
    func purchaseCompletion(isSuccessfully: Bool)
    
    func showActivityIndicator()
    func hideActivityIndicator()
    
    func updateNotificationViewModelState()
}

public protocol PhotoViewModelProtocol {
    var delegate: PhotoViewModelDelegate? { get set }
    var isEnoughGemsForOrder: Bool { get }
    var isCountainOrderHistory: Bool { get }

    var retouchCostObservable: Observable<String> { get set }
    var isOrderAvailableObservable: Observable<Bool> { get set }
    var currrentTagDescriptionObservable: Observable<String> { get set }

    var retouchGroupViewModel: RetouchGroupViewModelProtocol { get set  }
    var retouchTagViewModel: RetouchTagViewModelProtocol { get set }

    func getImage() -> UIImage?
    func getOrderAmount() -> Int
    func getOrderPrice() -> String
    func getOrderPriceUSD() -> String?
    func getUserFreeGemCreditCount() -> String
    func getOpenedRetouchData() -> PresentableRetouchData?
    func getCurrentTagDescription() -> String

    func didAddTagDescription(_ tagDescription: String?)
    func createOrder(completion: ((_ result: Result<Order>) -> Void)?)
    
    func makePurchase(from viewController: UIViewController)
    
    func isFirstOrderForFreeAvailabel() -> Bool
    func isFirstOrderForFreeOutOfFreeGemCount() -> Bool
}

public final class PhotoViewModel: PhotoViewModelProtocol {
    // MARK: - Properties
    // Boundaries
    private let ordersLoader: OrdersLoaderProtocol
    private let phImageLoader: PHImageLoaderProtocol
    private var retouchGroups: [PresentableRetouchGroup] = []
    private var iapService: IAPServiceProtocol
    private var freeGemCreditCountService: FreeGemCreditCountServiceProtocol
    private let user: User
    
    private var image: UIImage? {
        didSet {
            delegate?.didUpdateImage(image)
        }
    }
    
    // ViewModels
    public var retouchGroupViewModel: RetouchGroupViewModelProtocol
    public var retouchTagViewModel: RetouchTagViewModelProtocol
    private let disposeBag = DisposeBag()

    // Data
    private var productsResponse: [IAPProductResponse] = [] 
    private var openGroupIndex = 0 {
        didSet { delegate?.didUpdateOpenTagIndex(openTagIndex, previousValue: previousOpenTagIndex) }
    }
    private var openTagIndex: Int? {
        willSet { previousOpenTagIndex = openTagIndex }
        didSet { delegate?.didUpdateOpenTagIndex(openTagIndex, previousValue: previousOpenTagIndex) }
    }
    private var previousOpenTagIndex: Int?

    private var retouchCost = BehaviorRelay(value: 0)
    public lazy var retouchCostObservable = retouchCost.map{ String($0) }.asObservable()
    public lazy var isOrderAvailableObservable = retouchCost.map{ $0 != Constants.minRetouchingCost }.asObservable()
    
    private var currrentTagDescription = BehaviorRelay(value: "")
    public lazy var currrentTagDescriptionObservable = currrentTagDescription.asObservable()

    // Delegate
    public weak var delegate: PhotoViewModelDelegate?

    public var isEnoughGemsForOrder: Bool {
        UserData.shared.user.gemCount >= getOrderAmount()
    }
    
    public private(set) var ordersCount = 0
    public var isCountainOrderHistory: Bool {
        ordersCount > 0
    }

    // MARK: - Inits
    public init(ordersLoader: OrdersLoaderProtocol,
                phImageLoader: PHImageLoaderProtocol,
                retouchGroups: [RetouchGroup],
                iapService: IAPServiceProtocol,
                freeGemCreditCountService: FreeGemCreditCountServiceProtocol,
                asset: PHAsset) {
        self.ordersLoader = ordersLoader
        self.phImageLoader = phImageLoader
        self.retouchGroups = retouchGroups
            .sorted(by: { $0.orderNumber < $1.orderNumber })
            .map { group in
                group.tags = group.tags.sorted(by: { $0.orderNumber < $1.orderNumber })
                return PresentableRetouchGroup(retouchGroup: group)
            }
        self.iapService = iapService
        self.freeGemCreditCountService = freeGemCreditCountService
        self.user = UserData.shared.user

        retouchGroupViewModel = RetouchGroupViewModel()
        retouchTagViewModel = RetouchTagViewModel()

        loadImage(asset: asset)
        bindData()
        loadData()
    }
    
    public init(ordersLoader: OrdersLoaderProtocol,
                phImageLoader: PHImageLoaderProtocol,
                retouchGroups: [RetouchGroup],
                iapService: IAPServiceProtocol,
                freeGemCreditCountService: FreeGemCreditCountServiceProtocol,
                image: UIImage) {
        self.ordersLoader = ordersLoader
        self.phImageLoader = phImageLoader
        self.retouchGroups = retouchGroups
            .sorted(by: { $0.orderNumber < $1.orderNumber })
            .map { group in
                group.tags = group.tags.sorted(by: { $0.orderNumber < $1.orderNumber })
                return PresentableRetouchGroup(retouchGroup: group)
            }
        self.iapService = iapService
        self.freeGemCreditCountService = freeGemCreditCountService
        self.image = image
        self.user = UserData.shared.user

        retouchGroupViewModel = RetouchGroupViewModel()
        retouchTagViewModel = RetouchTagViewModel()

        bindData()
        loadData()
    }
    
    func loadImage(asset: PHAsset) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        
        delegate?.showActivityIndicator()
        DispatchQueue(label: "Fetch image", qos: DispatchQoS.userInteractive).async {
            self.phImageLoader.fetchImage(asset,
                                          targetSize: PHImageManagerMaximumSize,
                                          contentMode: .aspectFill,
                                          options: options)
            { [weak self] (image, info) in
                DispatchQueue.main.async {
                    self?.delegate?.hideActivityIndicator()
                    self?.image = image
                }
            }
        }
    }
}

// MARK: - Public methods
extension PhotoViewModel {
    public func getImage() -> UIImage? {
        return image
    }

    public func getOrderAmount() -> Int {
        return retouchCost.value
    }

    public func getOrderPrice() -> String {
        return String(getOrderAmount())
    }
    
    public func getOrderPriceUSD() -> String? {
        guard let iapProductResponse = getMinIAPProductResponse(gemsCount: getOrderAmount()) else { return nil }
        return iapProductResponse.price.stringValue + " " + iapProductResponse.currencyCode
    }
    
    public func getUserFreeGemCreditCount() -> String {
        guard let freeGemCreditCount = user.freeGemCreditCount else { return "" }
        return String(freeGemCreditCount)
    }
    
    private func getMinIAPProductResponse(gemsCount: Int) -> IAPProductResponse? {
        let products = productsResponse.sorted(by: { $0.gemsCount < $1.gemsCount })
        return products.first(where: { $0.gemsCount >= gemsCount })
    }
    
    public func getOpenedRetouchData() -> PresentableRetouchData? {
        guard let openTagIndex = openTagIndex else { return nil }
        guard retouchGroups.count > openGroupIndex else { return nil }
        
        let retouchGroup = retouchGroups[openGroupIndex]
        guard retouchGroup.tags.count > openTagIndex else { return nil }
        
        let tag = retouchGroup.tags[openTagIndex]
        
        return (retouchGroup: retouchGroup, tag: tag)
    }
    
    public func getCurrentTagDescription() -> String {
        return getOpenedRetouchData()?.tag.tagDescription ?? ""
    }
    
    public func didAddTagDescription(_ tagDescription: String?) {
        guard let retouchData = getOpenedRetouchData() else { return }
        retouchData.tag.tagDescription = tagDescription
        updateCurrentTagDescription()
    }

    public func createOrder(completion: ((_ result: Result<Order>) -> Void)?) {
        guard let image = image else { return }
        
        let createOrderModel = CreateOrderModel(
            beforeImage: image,
            selectedRetouchGroups: self.retouchGroups
                .filter { $0.isSelected }
                .map {
                    SelectedRetouchGroupParameters(
                        retouchGroupId: $0.id,
                        selectedRetouchTags: $0.selectedRetouchTags.map {
                            SelectedRetouchTagParameters(retouchTagId: $0.id,
                                                         retouchTagTitle: $0.title,
                                                         retouchTagPrice: $0.price,
                                                         retouchTagDescription: $0.tagDescription)
                        },
                        retouchGroupTitle: $0.title,
                        descriptionForDesigner: $0.descriptionForDesigner
                    )
                },
            price: self.getOrderAmount(),
            isFreeOrder: isFirstOrderForFreeAvailabel() && !isFirstOrderForFreeOutOfFreeGemCount()
        )

        self.ordersLoader.createOrder(createOrderModel: createOrderModel) { (result) in
            DispatchQueue.main.async {
                completion?(result)
            }
        }
    }
    
    public func makePurchase(from viewController: UIViewController) {
        guard let iapProductResponse = getMinIAPProductResponse(gemsCount: getOrderAmount()) else { return }
        iapService.purchase(productResponse: iapProductResponse) { isSuccessfully in
            self.delegate?.purchaseCompletion(isSuccessfully: isSuccessfully)
        }
    }
    
    public func isFirstOrderForFreeAvailabel() -> Bool {
        return (user.freeGemCreditCount ?? 0) > 0
        && (user.freeGemCreditCount ?? 0) == user.gemCount
        && ordersLoader.ordersPublisher.value.count == 0
    }
    
    public func isFirstOrderForFreeOutOfFreeGemCount() -> Bool {
        return isFirstOrderForFreeAvailabel()
        && (user.freeGemCreditCount ?? 0) < retouchCost.value
    }
}

// MARK: - Load Data
private extension PhotoViewModel {
    func bindData() {
        iapService.getProducts { [weak self] (response) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.productsResponse = response
            }
        }
        
        retouchGroupViewModel.openGroupIndexObservable
            .bind { (value) in
                guard self.openGroupIndex != value else { return }
                self.openGroupIndex = value
                self.updateViewModels()
            }.disposed(by: disposeBag)
        
        retouchTagViewModel.openTagIndexObservable
            .bind { (value) in
                guard self.openTagIndex != value else { return }
                self.openTagIndex = value

                self.updateCurrentTagDescription()
                self.updateGroupViewModel()
                self.updateRetouchCost()
            }.disposed(by: disposeBag)
        
        ordersLoader.ordersPublisher
            .bind { orders in
                self.ordersCount = orders.count
            }.disposed(by: disposeBag)
    }
    
    func updateCurrentTagDescription() {
        self.currrentTagDescription.accept(getCurrentTagDescription())
    }

    func loadData() {
        updateViewModels()
    }

    func updateViewModels() {
        updateGroupViewModel()
        updateTagViewModel()
        updateRetouchCost()
        updateCurrentTagDescription()
    }

    func updateGroupViewModel() {
        retouchGroupViewModel.setRetouchGroups(retouchGroups)
    }

    func updateTagViewModel() {
        if let retouchGroup = getCurrentRetouchGroup() {
            retouchTagViewModel.setRetouchGroup(retouchGroup, openGroupIndex: openGroupIndex)
        }
    }

    func updateRetouchCost() {
        var cost = Constants.minRetouchingCost
        retouchGroups.forEach { retouchGroup in
            retouchGroup.selectedRetouchTags.forEach { selectedTag in
                cost += selectedTag.price
            }
        }

        retouchCost.accept(cost)
    }

    func getCurrentRetouchGroup() -> PresentableRetouchGroup? {
        guard openGroupIndex < retouchGroups.count else { return nil }
        return retouchGroups[openGroupIndex]
    }
}
