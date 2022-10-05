//
//  IAPService.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 22.04.2021.
//

import StoreKit
import RxSwift
import RxCocoa
import RestApiManager

public protocol IAPServiceProtocol {
    func getProducts(completion: ((_ response: [IAPProductResponse]) -> Void)?)
    func purchase(productResponse: IAPProductResponse, successCompletion: ((_ isSuccessfully: Bool) -> Void)?)
}

public final class IAPService: NSObject, IAPServiceProtocol {
    // MARK: - Properties
    private let restApiManager: RestApiManager
    private var products: [SKProduct] = []
    private let paymentQueue = SKPaymentQueue.default()
    private var completion: ((_ response: [IAPProductResponse]) -> Void)?

    public var purchaseCompletion: ((_ isSuccessfully: Bool) -> Void)?

    // MARK: - Inits
    public init(restApiManager: RestApiManager) {
        self.restApiManager = restApiManager
        super.init()
    }

    // MARK: - Public methods
    public func getProducts(completion: ((_ response: [IAPProductResponse]) -> Void)?) {
        self.completion = completion

        let products = IAPProduct.allCases.map({ $0.rawValue })
        let request = SKProductsRequest(productIdentifiers: Set(products))
        request.delegate = self
        request.start()
        paymentQueue.add(self)
    }

    public func purchase(productResponse: IAPProductResponse, successCompletion purchaseCompletion: ((_ isSuccessfully: Bool) -> Void)?) {
        guard let productToPurchase = products.first(where: { $0.productIdentifier == productResponse.productIdentifier }) else { return }
        
        self.purchaseCompletion = purchaseCompletion
        
        let payment = SKPayment(product: productToPurchase)
        paymentQueue.add(payment)
    }

    public func restorePurchases() {
        paymentQueue.restoreCompletedTransactions()
    }
}

// MARK: - SKProductsRequestDelegate
extension IAPService: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
            .sorted(by: { Double(truncating: $0.price) < Double(truncating: $1.price) })

        let productsResponse = products.compactMap { (value) -> IAPProductResponse? in
            if let iapProduct = IAPProduct(rawValue: value.productIdentifier) {
                return IAPProductResponse(product: value, iapProduct: iapProduct)
            }
            return nil
        }
        completion?(productsResponse)
    }
}

// MARK: - SKPaymentTransactionObserver
extension IAPService: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            
            switch transaction.transactionState {
            case .purchasing:
                break
            case .deferred, .failed, .restored:
                paymentQueue.finishTransaction(transaction)
                purchaseCompletion?(false)
            case .purchased:
                if let product = IAPProduct(rawValue: transaction.payment.productIdentifier) {
                    refillUserGems(product: product) { [weak self] isSuccessfully in
                        guard let self = self else { return }
                        if isSuccessfully {
                            self.paymentQueue.finishTransaction(transaction)
                        }
                        self.purchaseCompletion?(isSuccessfully)
                    }
                } else {
                    purchaseCompletion?(false)
                }
            @unknown default:
                break
            }
        }
    }

    private func refillUserGems(product: IAPProduct, completion: ((_ isSuccessfully: Bool) -> Void)?) {
        ActivityIndicatorHelper.shared.show()
        let refillAmount = product.gemsCount
        let parameters = GemsParameters(refillAmount: String(refillAmount))
        let method = GemsRestApiMethods.refill(parameters)
        restApiManager.call(method: method) { (result) in
            DispatchQueue.main.async {
                ActivityIndicatorHelper.shared.hide()
                switch result {
                case .success:
                    UserData.shared.user.gemCount = UserData.shared.user.gemCount + refillAmount
                    completion?(true)
                case .failure(let error):
                    NotificationBannerHelper.showBanner(error)
                    completion?(false)
                }
            }
        }
    }
}

extension SKPaymentTransactionState {
    func status() -> String {
        switch self {
        case .deferred:
            return "deferred"
        case .failed:
            return "failed"
        case .purchased:
            return "purchased"
        case .purchasing:
            return "purchasing"
        case .restored:
            return "restored"
        @unknown default:
            return "@unknown default"
        }
    }
}
