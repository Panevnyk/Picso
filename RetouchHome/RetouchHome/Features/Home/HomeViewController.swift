//
//  HomeViewController.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 09.02.2021.
//

import UIKit
import RetouchCommon
import Photos

public protocol HomeCoordinatorDelegate: AnyObject {
    func setHomeHistory(from viewController: HomeViewController)
    func setGallery(from viewController: HomeViewController)
}

public final class HomeViewController: UIViewController {
    // MARK: - Properties
    // UI
    @IBOutlet private var containerView: UIView!
    private var placeholderView: PlaceholderView?
    private var childViewController: UIViewController?

    // ViewModel
    public var viewModel: HomeViewModelProtocol!

    // Delegate
    public weak var coordinatorDelegate: HomeCoordinatorDelegate?

    // MARK: - Life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }

    // MARK: - Public methods
    public func setupTabBar() {
        tabBarItem.image = MainTab.home.image
        tabBarItem.selectedImage = MainTab.home.selectedImage
        tabBarItem.title = "Home"
    }

    public func setChildController(_ viewController: UIViewController) {
        clearChildViewController()
        clearPlaceholderView()

        addChild(viewController, onView: containerView)
        childViewController = viewController
    }
}

// MARK: - SetupUI
private extension HomeViewController {
    func setupUI() {
        view.backgroundColor = .kBackground
        containerView.backgroundColor = .kBackground
    }

    func clearChildViewController() {
        childViewController?.removeFromParentViewController()
        childViewController = nil
    }

    func clearPlaceholderView() {
        placeholderView?.removeFromSuperview()
        placeholderView = nil
    }
}

// MARK: - HomeViewModelDelegate
extension HomeViewController: HomeViewModelDelegate {
    public func presentHomeHistory() {
        guard (childViewController as? HomeHistoryViewController) == nil else { return }
        coordinatorDelegate?.setHomeHistory(from: self)
    }

    public func presentGallery() {
        guard (childViewController as? HomeGalleryViewController) == nil else { return }

        viewModel.requestPhotosAuthorization { [weak self] (isAuthorized) in
            guard let self = self else { return }

            if isAuthorized {
                self.coordinatorDelegate?.setGallery(from: self)
            } else {
                self.presentNoAccessToGallery()
            }
        }
    }

    public func presentInternetConnectionError() {
        clearChildViewController()

        let placeholderView = PlaceholderView()
        placeholderView.setTitle("Ooops!")
        placeholderView.setSubtitle("It seems there is something wrong with your internet connection")
        placeholderView.setActionButtonIsHidden(true)
        placeholderView.setImage(
            UIImage(named: "icNoInternetConnection", in: Bundle.common, compatibleWith: nil))
        view.addSubviewUsingConstraints(view: placeholderView)
        self.placeholderView = placeholderView
        
        AnalyticsService.logScreen(.internetConnectionErrorAlert)
    }

    public func presentNoAccessToGallery() {
        clearChildViewController()

        let placeholderView = PlaceholderView()
        placeholderView.setTitle("No access to photo library")
        placeholderView.setSubtitle("To enable access please\ngo to your device setting")
        placeholderView.setActionButtonTitle("Open Settings")
        placeholderView.setImage(
            UIImage(named: "icNoAccessToPhotoLibrary", in: Bundle.common, compatibleWith: nil))
        placeholderView.delegate = self
        view.addSubviewUsingConstraints(view: placeholderView)
        self.placeholderView = placeholderView
        
        AnalyticsService.logScreen(.noAccessToGalleryAlert)
    }
    
    public func presentFirstRetouchingForFreeAlert(diamondsCount: String, closeAction: (() -> Void)?) {
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

// MARK: - PlaceholderViewDelegate
extension HomeViewController: PlaceholderViewDelegate {
    public func didTapActionButton(from view: PlaceholderView) {
        SettingsHelper.openSettings()
        AnalyticsService.logAction(.openSettings)
    }
}
