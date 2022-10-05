//
//  HomeAssembly.swift
//  RetouchMain
//
//  Created by Vladyslav Panevnyk on 09.02.2021.
//

import UIKit
import Photos
import RetouchHome
import RetouchCommon
import SwiftUI

final class HomeAssembly {
    let viewModel: HomeViewModelProtocol
    var viewController: HomeViewController

    init(serviceFactory: ServiceFactoryProtocol) {
        let storyboard = UIStoryboard(name: "Home", bundle: Bundle.home)
        let viewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController

        let viewModel = HomeViewModel(
            dataLoader: serviceFactory.makeDataLoader(),
            ordersLoader: serviceFactory.makeOrdersLoader(),
            phImageLoader: serviceFactory.makePHImageLoader(),
            retouchGroupsLoader: serviceFactory.makeRetouchGroupsLoader(),
            phPhotoLibraryPresenter: serviceFactory.makePHPhotoLibraryPresenter(),
            reachabilityService: serviceFactory.makeReachabilityService(),
            iapService: serviceFactory.makeIAPService(),
            freeGemCreditCountService: serviceFactory.makeFreeGemCreditCountService(),
            savePhotoInfoService: serviceFactory.makeSavePhotoInfoService(),
            delegate: viewController
        )
        viewController.viewModel = viewModel

        self.viewModel = viewModel
        self.viewController = viewController
    }
}

final class HomeHistoryAssembly {
    var viewController: HomeHistoryViewController
    var viewModel: HomeHistoryViewModelProtocol

    init(serviceFactory: ServiceFactoryProtocol,
         homeHistoryViewModel: HomeHistoryViewModelProtocol) {
        var viewModel = homeHistoryViewModel
        let storyboard = UIStoryboard(name: "Home", bundle: Bundle.home)
        let viewController = storyboard.instantiateViewController(withIdentifier: "HomeHistoryViewController") as! HomeHistoryViewController
        viewController.viewModel = viewModel
        viewModel.delegate = viewController

        self.viewController = viewController
        self.viewModel = viewModel
    }
}

final class HomeGalleryAssembly {
    var viewController: HomeGalleryViewHosting

    init(serviceFactory: ServiceFactoryProtocol) {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)

//        let storyboard = UIStoryboard(name: "Gallery", bundle: Bundle.home)
//        let viewController = storyboard.instantiateViewController(withIdentifier: "HomeGalleryViewController") as! HomeGalleryViewController
//        viewController.dataLoader = serviceFactory.makeDataLoader()
//        viewController.phImageLoader = serviceFactory.makePHImageLoader()
//        viewController.assets = allPhotos
//        viewController.expandableTitle = "All photos"

        let viewModel = HomeGalleryViewModel(dataLoader: serviceFactory.makeDataLoader(),
                                             phImageLoader: serviceFactory.makePHImageLoader(),
                                             assets: allPhotos,
                                             expandableTitle: "All photos",
                                             isBackHidden: true)
        let view = HomeGalleryView(viewModel: viewModel)
        let viewController = HomeGalleryViewHosting(rootView: view)

        self.viewController = viewController
    }
}

final class PhotoAssembly {
    var viewController: PhotoViewController

    init(serviceFactory: ServiceFactoryProtocol,
         photoViewModel: PhotoViewModelProtocol) {
        let storyboard = UIStoryboard(name: "Gallery", bundle: Bundle.home)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
        var viewModel = photoViewModel
        viewController.viewModel = viewModel
        viewModel.delegate = viewController

        self.viewController = viewController
    }
}

final class AlbumAssembly {
    var viewController: AlbumCollectionViewController

    init(serviceFactory: ServiceFactoryProtocol) {
        let storyboard = UIStoryboard(name: "Gallery", bundle: Bundle.home)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AlbumCollectionViewController") as! AlbumCollectionViewController

        self.viewController = viewController
    }
}

final class OrderDetailAssembly {
    var viewController: OrderDetailViewController
    var viewModel: OrderDetailViewModelProtocol

    init(serviceFactory: ServiceFactoryProtocol,
         viewModel: OrderDetailViewModelProtocol) {
        let storyboard = UIStoryboard(name: "Home", bundle: Bundle.home)
        let viewController = storyboard.instantiateViewController(withIdentifier: "OrderDetailViewController") as! OrderDetailViewController
        viewController.viewModel = viewModel

        self.viewController = viewController
        self.viewModel = viewModel
    }
}

final class RetouchingPhotoAssembly {
    var viewController: RetouchingPhotoViewController
    var viewModel: RetouchingPhotoViewModelProtocol

    init(serviceFactory: ServiceFactoryProtocol, order: Order) {
        let viewModel = RetouchingPhotoViewModel(order: order)
        let storyboard = UIStoryboard(name: "Home", bundle: Bundle.home)
        let viewController = storyboard.instantiateViewController(withIdentifier: "RetouchingPhotoViewController") as! RetouchingPhotoViewController
        viewController.viewModel = viewModel
        viewModel.delegate = viewController

        self.viewController = viewController
        self.viewModel = viewModel
    }
}

final class BalanceAssembly {
    var viewController: BalanceViewController
    var viewModel: BalanceViewModelProtocol

    init(serviceFactory: ServiceFactoryProtocol, orderAmount: Int? = nil) {
        let viewModel = BalanceViewModel(
            iapService: serviceFactory.makeIAPService(),
            earnCreditsService: serviceFactory.makeEarnCreditsService(),
            orderAmount: orderAmount
        )
        let storyboard = UIStoryboard(name: "Home", bundle: Bundle.home)
        let viewController = storyboard.instantiateViewController(withIdentifier: "BalanceViewController") as! BalanceViewController
        viewController.viewModel = viewModel
        viewModel.delegate = viewController

        self.viewController = viewController
        self.viewModel = viewModel
    }
}

final class CancelMessageAssembly {
    var viewController: MessageViewController

    init(order: Order) {
        let storyboard = UIStoryboard(name: "Home", bundle: Bundle.home)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
        viewController.imageString = "icPhotoRetouchingReady"
        viewController.screenTitle = "Photo is canceled\nby designer"
        let cancelText = order.statusDescription ?? ""
        viewController.message = "\"\(cancelText)\""

        self.viewController = viewController
    }
}
