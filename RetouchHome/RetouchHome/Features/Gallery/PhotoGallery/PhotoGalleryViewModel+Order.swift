//
//  PhotoGalleryViewModel+Order.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 12.02.2023.
//

import UIKit
import RetouchCommon
import RestApiManager

// MARK: - Create order
extension PhotoGalleryViewModel {
    public func createOrderRequest(completion: ((_ result: Result<Order>) -> Void)?) {
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
}

// MARK: - Purchase
extension PhotoGalleryViewModel {
    func makePurchase() {
        guard let iapProductResponse = getMinIAPProductResponse(gemsCount: getOrderAmount()) else { return }
        iapService.purchase(productResponse: iapProductResponse) { [weak self] isSuccessfully in
            guard let self = self else { return }
            self.isPurchaseBlurViewHidden = true
            if isSuccessfully {
                self.createOrder()
            }
        }
    }
}

// MARK: - Order logic
extension PhotoGalleryViewModel {
    func didSelectFreeOrStandartOrder() {
        if isFirstOrderForFreeAvailabel() {
            didSelectFreeOrder()
        } else {
            didSelectOrder()
        }
    }
    
    func didSelectFreeOrder() {
        if isFirstOrderForFreeOutOfFreeGemCount() {
            makeOutOfFreeOrderAlert(diamondsPrice: getUserFreeGemCreditCount()) { [weak self] in
                AnalyticsService.logAction(.makeOutOfFreeFastOrder)
                self?.fastOrder()
            }
        } else {
            makeFreeOrderAlert(diamondsPrice: getUserFreeGemCreditCount()) { [weak self] in
                AnalyticsService.logAction(.makeFreeOrder)
                self?.createOrder()
            }
        }
    }
    
    public func didSelectOrder() {
        if isEnoughGemsForOrder {
            makeOrderAlert { [weak self] in
                AnalyticsService.logAction(.makeOrder)
                self?.createOrder()
            }
        } else {
            if let usdPrice = getOrderPriceUSD() {
                if isCountainOrderHistory {
                    makeNotEnoughGemsOrderAlert(
                        usdPrice: usdPrice,
                        fastOrder: { [weak self] in self?.fastOrder() },
                        goToBalance: { [weak self] in self?.goToBalance() })
                } else {
                    fastOrder()
                }
            } else {
                goToBalance()
            }
        }
    }
    
    fileprivate func fastOrder() {
        AnalyticsService.logAction(.makeFastOrder)
        isPurchaseBlurViewHidden = false
        makePurchase()
    }
    
    fileprivate func goToBalance() {
        AnalyticsService.logAction(.showBalanceFromOrder)
        coordinatorDelegate?.didSelectOrderNotEnoughGems(
            orderAmount: getOrderAmount()
        )
    }
    
    fileprivate func createOrder() {
        ActivityIndicatorHelper.shared.show()
        createOrderRequest { [weak self] (result) in
            guard let self = self else { return }
            
            ActivityIndicatorHelper.shared.hide()
            switch result {
            case .success(let order):
                self.coordinatorDelegate?.didSelectOrder(order)
            case .failure(let error):
                NotificationBannerHelper.showBanner(error)
            }
        }
    }
}

