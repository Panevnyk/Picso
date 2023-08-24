//
//  HomeCoordinator.swift
//  RetouchMain
//
//  Created by Vladyslav Panevnyk on 09.02.2021.
//

import UIKit
import Photos
import RetouchHome
import RetouchCommon

final class HomeCoordinator {
    // MARK: - Properties
    private let serviceFactory: ServiceFactoryProtocol
    private let navigationController: UINavigationController

    private var phPhotoLibraryPresenter: PHPhotoLibraryPresenterProtocol?
    private var cameraPresenter: CameraPresenterProtocol?

    private weak var homeViewController: HomeViewController?
    private weak var homeHistoryViewController: HomeHistoryViewHosting?
    private weak var homeGalleryViewController: HomeGalleryViewHosting?
    private weak var photoViewController: PhotoGalleryViewHosting?
    private weak var retouchingPhotoViewController: RetouchingPhotoViewController?
    private weak var balanceViewController: BalanceViewController?
    private weak var orderDetailViewController: OrderDetailViewController?

    // MARK: - Inits
    init(navigationController: UINavigationController,
         serviceFactory: ServiceFactoryProtocol) {
        self.navigationController = navigationController
        self.serviceFactory = serviceFactory
    }

    // MARK: - Starts
    func start(animated: Bool) {
        startHome(animated: animated)
    }

    private func startHome(animated: Bool) {
        let homeAssembly = HomeAssembly(serviceFactory: serviceFactory)
        homeAssembly.viewController.setupTabBar()
        homeAssembly.viewController.coordinatorDelegate = self
        self.homeViewController = homeAssembly.viewController

        navigationController.setViewControllers([homeAssembly.viewController], animated: animated)
    }
}

// MARK: - HomeCoordinatorDelegate
extension HomeCoordinator: HomeCoordinatorDelegate {
    public func setHomeHistory(from viewController: HomeViewController) {
        let homeHistoryAssembly = HomeHistoryAssembly(
            serviceFactory: serviceFactory,
            coordinatorDelegate: self
        )

        setChildController(homeHistoryAssembly.viewController, to: viewController)
    }

    public func setGallery(from viewController: HomeViewController){
        let homeGalleryAssembly = HomeGalleryAssembly(serviceFactory: serviceFactory)
        homeGalleryAssembly.viewModel.coordinatorDelegate = self
        homeGalleryViewController = homeGalleryAssembly.viewController

        setChildController(homeGalleryAssembly.viewController, to: viewController)
    }

    private func setChildController(_ viewController: UIViewController, to parentViewController: HomeViewController) {
        parentViewController.setChildController(viewController)
    }
}

// MARK: - BalanceViewCoordinatorDelegate
extension HomeCoordinator: BaseBalanceCoordinatorDelegate {
    public func didSelectBalanceAction() {
        let balanceViewController = makeBalanceViewController()
        navigationController.pushViewController(balanceViewController, animated: true)
    }
}

// MARK: - BaseCoordinatorDelegate
extension HomeCoordinator: BaseCoordinatorDelegate {
    public func didSelectBackAction() {
        navigationController.popViewController(animated: true)
    }
}

// MARK: - HomeGalleryViewCoordinatorDelegate
extension HomeCoordinator: HomeGalleryViewCoordinatorDelegate {
    public func didSelectPhoto(asset: PHAsset) {
        let retouchGroups = homeViewController!.viewModel.getRetouchGroups()
        let photoAssembly = PhotoGalleryAssembly(
            serviceFactory: serviceFactory,
            retouchGroups: retouchGroups,
            asset: asset)
        photoAssembly.viewModel.coordinatorDelegate = self
        photoViewController = photoAssembly.viewController

        navigationController.pushViewController(photoAssembly.viewController, animated: true)
    }

    public func didSelectPhoto(image: UIImage, from viewController: UIViewController) {
        let retouchGroups = homeViewController!.viewModel.getRetouchGroups()
        let photoAssembly = PhotoGalleryAssembly(
            serviceFactory: serviceFactory,
            retouchGroups: retouchGroups,
            image: image)
        photoAssembly.viewModel.coordinatorDelegate = self
        photoViewController = photoAssembly.viewController

        navigationController.pushViewController(photoAssembly.viewController, animated: true)
    }

    public func didSelectCamera() {
        presentCamera(from: navigationController)
    }
}

// MARK: - PhotoGalleryViewCoordinatorDelegate
extension HomeCoordinator: PhotoGalleryViewCoordinatorDelegate {
    func didSelectOrder(_ order: Order) {
        presentRetouchingPhoto(by: order)
    }
    
    func didSelectOrderNotEnoughGems(orderAmount: Int) {
        let balanceViewController = makeBalanceViewController(orderAmount: orderAmount)
        balanceViewController.fromOrderCoordinatorDelegate = self
        navigationController.pushViewController(balanceViewController, animated: true)
    }
    
    func presentRetouchingPhoto(by order: Order) {
        let retouchingPhotoAssembly = RetouchingPhotoAssembly(serviceFactory: serviceFactory, order: order)

        retouchingPhotoViewController = retouchingPhotoAssembly.viewController

        navigationController.present(retouchingPhotoAssembly.viewController, animated: true)
        { [weak self] in
            self?.navigationController.popToRootViewController(animated: false)
        }
    }
}

// MARK: - HomeHistoryCoordinatorDelegate
extension HomeCoordinator: HomeHistoryCoordinatorDelegate {
    func didTapGallery() {
        phPhotoLibraryPresenter = serviceFactory.makePHPhotoLibraryPresenter()
        phPhotoLibraryPresenter?.requestPhotosAuthorization { [weak self] (isAuthorized) in
            guard let self = self else { return }
            if isAuthorized {
                let homeGalleryAssembly = HomeGalleryAssembly(serviceFactory: self.serviceFactory)
                homeGalleryAssembly.viewModel.coordinatorDelegate = self
                homeGalleryAssembly.viewModel.isBackHidden = false
                self.homeGalleryViewController = homeGalleryAssembly.viewController

                self.navigationController.pushViewController(homeGalleryAssembly.viewController, animated: true)
            } else {
                self.phPhotoLibraryPresenter?.presentNotAccessToPhotoLibraryAlert()
            }

            self.phPhotoLibraryPresenter = nil
        }
    }

    func didTapCamera() {
        presentCamera(from: navigationController)
    }

    func presentCamera(from viewController: UIViewController) {
        cameraPresenter = serviceFactory.makeCameraPresenter()
        cameraPresenter?.delegate = self
        cameraPresenter?.presentCamera(from: viewController)
    }

    func didSelectOrderDetail(_ order: Order) {
        switch order.status {
        case .completed:
            presentOrderDetail(order: order)
        case .canceled:
            presentCanceledPhoto(by: order)
        case .waiting, .confirmed, .waitingForReview, .inReview, .redoByLeadDesigner:
            presentRetouchingPhoto(by: order)
        }
    }

    func presentOrderDetail(order: Order) {
        let orderDetailAssembly = OrderDetailAssembly(
            serviceFactory: serviceFactory,
            order: order)
        self.orderDetailViewController = orderDetailAssembly.viewController

        navigationController.pushViewController(orderDetailAssembly.viewController, animated: true)
    }

    func presentCanceledPhoto(by order: Order) {
        let cancelMessageAssembly = CancelMessageAssembly(order: order)
        navigationController.present(cancelMessageAssembly.viewController, animated: true, completion: nil)
    }
}

// MARK: - BalanceCoordinatorDelegate, BalanceFromOrderCoordinatorDelegate
extension HomeCoordinator: BalanceCoordinatorDelegate, BalanceFromOrderCoordinatorDelegate {
    public func purchasedSuccessfullyWithRequiredOrder() {
        navigationController.popViewController(animated: true)
        if let photoViewController = photoViewController {
            photoViewController.didSelectOrder()
        }
    }
}

// MARK: - CameraPresenterDelegate
extension HomeCoordinator: CameraPresenterDelegate {
    func didSelectPhoto(image: UIImage) {
        didSelectPhoto(image: image, from: navigationController.viewControllers.last!)
    }

    func dismiss(picker: UIImagePickerController) {
        picker.dismiss(animated: true) { [weak self] in
            self?.cameraPresenter = nil
        }
    }
}

// MARK: - ViewControllers Factories
private extension HomeCoordinator {
    private func makeBalanceViewController(orderAmount: Int? = nil) -> BalanceViewController {
        let balanceAssembly = BalanceAssembly(serviceFactory: serviceFactory, orderAmount: orderAmount)
        balanceAssembly.viewController.coordinatorDelegate = self
        balanceViewController = balanceAssembly.viewController
        balanceViewController?.coordinatorDelegate = self

        return balanceAssembly.viewController
    }
}
