//
//  HostingViewControllerWithoutNavBar.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 11.10.2022.
//

import SwiftUI
import UIKit

open class HostingViewControllerWithoutNavBar<Content>: UIHostingController<AnyView> where Content: View {
    // MARK: - Properties

    private var hidesBottomBarOnPush: Bool

    // MARK: - Inits
    public init(rootView: Content, hidesBottomBarOnPush: Bool = true) {
        self.hidesBottomBarOnPush = hidesBottomBarOnPush
        super.init(rootView: AnyView(rootView.navigationBarHidden(true)))
    }

    @objc required dynamic public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hidesBottomBarWhenPushed = hidesBottomBarOnPush
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hidesBottomBarWhenPushed = !hidesBottomBarOnPush
    }
}
