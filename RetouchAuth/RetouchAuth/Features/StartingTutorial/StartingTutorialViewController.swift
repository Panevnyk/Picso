//
//  StartingTutorialViewController.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk on 20.03.2021.
//

import UIKit
import RetouchCommon

public protocol StartingTutorialCoordinatorDelegate: UseAgreementsDelegate {
    func didSelectSignIn(from viewController: StartingTutorialViewController)
    func didSelectUseApp(from viewController: StartingTutorialViewController)
}

public final class StartingTutorialViewController: UIViewController {
    @IBOutlet private var screenTitleLabel: UILabel!
    @IBOutlet private var skipButton: ClearButton!
    @IBOutlet private var pageControl: UIPageControl!
    @IBOutlet private var nextButton: PurpleButton!
    @IBOutlet private var useAgreementsLabel: UseAgreementsLabel!
    private var pageViewController: PageViewController!
    
    public var orderedViewControllers: [UIViewController] = []
    
    private var isLastPage: Bool {
        pageControl.currentPage == pageControl.numberOfPages - 1
    }
    
    public weak var coordinatorDelegate: StartingTutorialCoordinatorDelegate?

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        StartingTutorialViewController.isShowen = true
        setupUI()
        addPageViewController()
        bringViewToFront()
        AnalyticsService.logScreen(.startingTutorial)
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private func setupUI() {
        useAgreementsLabel.useAgreementsDelegate = coordinatorDelegate
        
        view.backgroundColor = .kBlue
        screenTitleLabel.textColor = .white
        screenTitleLabel.font = .kBigTitleText
        skipButton.setTitle("SKIP", for: .normal)
        pageControl.numberOfPages = orderedViewControllers.count
        
        updateUIDependsOnPageControl()
    }
    
    private func bringViewToFront() {
        view.bringSubviewToFront(screenTitleLabel)
        view.bringSubviewToFront(skipButton)
        view.bringSubviewToFront(nextButton)
        view.bringSubviewToFront(pageControl)
        view.bringSubviewToFront(useAgreementsLabel)
    }
    
    private func updateUIDependsOnPageControl() {
        nextButton.setTitle(isLastPage ? /*"SIGN IN"*/"START" : "NEXT", for: .normal)
        
        let currentPage = pageControl.currentPage + 1
        let numberOfPages = pageControl.numberOfPages
        screenTitleLabel.text = "Tutorial \(currentPage)/\(numberOfPages)"
    }
    
    private func addPageViewController() {
        pageViewController = PageViewController(transitionStyle: .scroll,
                                                    navigationOrientation: .horizontal,
                                                    options: nil)
        pageViewController.orderedViewControllers = orderedViewControllers
        pageViewController.pageDelegate = self
        addChild(pageViewController, onView: view)
    }
}

// MARK: - Actions
extension StartingTutorialViewController {
    @IBAction func skipAction(_ sender: Any) {
//        coordinatorDelegate?.didSelectSignIn(from: self)
        coordinatorDelegate?.didSelectUseApp(from: self)
        AnalyticsService.logAction(.skipStartingTutorial)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        if isLastPage {
//            coordinatorDelegate?.didSelectSignIn(from: self)
            coordinatorDelegate?.didSelectUseApp(from: self)
            AnalyticsService.logAction(.signInStartingTutorial)
        } else {
            let nextIndex = pageControl.currentPage + 1
            pageControl.currentPage = nextIndex
            let vc = orderedViewControllers[nextIndex]
            pageViewController.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
            updateUIDependsOnPageControl()
            AnalyticsService.logAction(.skipStartingTutorial)
        }
    }
}

// MARK: - PageViewControllerDelegate
extension StartingTutorialViewController: PageViewControllerDelegate {
    public func didUpdatePageIndex(_ index: Int, from viewController: UIPageViewController) {
        pageControl.currentPage = index
        updateUIDependsOnPageControl()
    }
}

// MARK: - UserDefaults isShowen
extension StartingTutorialViewController {
    private static let userDefaultsIsShowenKey = "StartingTutorialUserDefaultsIsShowenKey"
    public static var isShowen: Bool {
        get {
            return UserDefaults.standard.bool(forKey: StartingTutorialViewController.userDefaultsIsShowenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: StartingTutorialViewController.userDefaultsIsShowenKey)
        }
    }
}
