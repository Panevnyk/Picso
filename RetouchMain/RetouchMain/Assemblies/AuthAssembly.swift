//
//  AuthAssembly.swift
//  RetouchMain
//
//  Created by Vladyslav Panevnyk on 12.03.2021.
//

import UIKit
import RetouchAuth
import SwiftUI

final class StartingTutorialAssembly {
    let viewController: UIViewController

    init(
        serviceFactory: ServiceFactoryProtocol,
        coordinatorDelegate: AStartingTutorialViewCoordinatorDelegate?
    ) {
        let viewModel = AStartingTutorialViewModel(
            coordinatorDelegate: coordinatorDelegate
        )
        let view = AStartingTutorialView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)

        self.viewController = viewController
    }
}

final class FastSigninAssembly {
    let viewController: UIViewController

    init(
        serviceFactory: ServiceFactoryProtocol,
        coordinatorDelegate: AFastSignInViewCoordinatorDelegate?
    ) {
        let viewModel = AFastSignInViewModel(
            restApiManager: serviceFactory.makeRestApiManager(),
            coordinatorDelegate: coordinatorDelegate
        )
        let view = AFastSignInView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)

        self.viewController = viewController
    }
}

final class LoginAssembly {
    let viewController: UIViewController

    init(
        serviceFactory: ServiceFactoryProtocol,
        defaultEmail: String?,
        coordinatorDelegate: ALoginViewCoordinatorDelegate?
    ) {
        let viewModel = ALoginViewModel(
            restApiManager: serviceFactory.makeRestApiManager(),
            defaultEmail: defaultEmail,
            coordinatorDelegate: coordinatorDelegate
        )
        let view = ALoginView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)

        self.viewController = viewController
    }
}

final class RegistrationAssembly {
    let viewController: UIViewController

    init(
        serviceFactory: ServiceFactoryProtocol,
        coordinatorDelegate: ARegistrationViewCoordinatorDelegate?
    ) {
        let viewModel = ARegisterationViewModel(
            restApiManager: serviceFactory.makeRestApiManager(),
            coordinatorDelegate: coordinatorDelegate
        )
        let view = ARegisterationView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)

        self.viewController = viewController
    }
}

final class ForgotPasswordAssembly {
    let viewController: UIViewController

    init(
        serviceFactory: ServiceFactoryProtocol,
        coordinatorDelegate: AForgotPasswordViewCoordinatorDelegate?
    ) {
        let viewModel = AForgotPasswordViewModel(
            restApiManager: serviceFactory.makeRestApiManager(),
            coordinatorDelegate: coordinatorDelegate
        )
        let view = AForgotPasswordView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)

        self.viewController = viewController
    }
}

final class ResetPasswordAssembly {
    let viewController: UIViewController
    
    init(
        resetPasswordToken: String,
        serviceFactory: ServiceFactoryProtocol,
        coordinatorDelegate: AResetPasswordViewCoordinatorDelegate?
    ) {
        let viewModel = AResetPasswordViewModel(
            resetPasswordToken: resetPasswordToken,
            restApiManager: serviceFactory.makeRestApiManager(),
            coordinatorDelegate: coordinatorDelegate
        )
        let view = AResetPasswordView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)
        
        self.viewController = viewController
    }
}
