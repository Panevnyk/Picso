//
//  PageViewController.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk on 20.03.2021.
//

import UIKit

public protocol PageViewControllerDelegate: AnyObject {
    func didUpdatePageIndex(_ index: Int, from viewController: UIPageViewController)
}

public final class PageViewController: UIPageViewController {
    public var orderedViewControllers: [UIViewController] = []

    public weak var pageDelegate: PageViewControllerDelegate?

    public override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self

        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
}

// MARK: UIPageViewControllerDataSource
extension PageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else { return nil }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else { return nil }
        guard orderedViewControllers.count > previousIndex else { return nil }

        return orderedViewControllers[previousIndex]
    }

    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count

        guard orderedViewControllersCount != nextIndex else { return nil }
        guard orderedViewControllersCount > nextIndex else { return nil }

        return orderedViewControllers[nextIndex]
    }

    public func pageViewController(_ pageViewController: UIPageViewController,
                                   didFinishAnimating finished: Bool,
                                   previousViewControllers: [UIViewController],
                                   transitionCompleted completed: Bool) {
        if let firstViewController = viewControllers?.first,
           let index = orderedViewControllers.firstIndex(of: firstViewController) {
            pageDelegate?.didUpdatePageIndex(index, from: self)
        }
    }
}
