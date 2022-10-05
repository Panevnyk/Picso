//
//  AuthAssembly.swift
//  RetouchMain
//
//  Created by Vladyslav Panevnyk on 12.03.2021.
//

import UIKit
import RetouchAuth

final class FastSigninAssembly {
    var viewController: FastSigninViewController
    var viewModel: FastSigninViewModelProtocol

    init(serviceFactory: ServiceFactoryProtocol) {
        let viewModel = FastSigninViewModel(
            restApiManager: serviceFactory.makeRestApiManager()
        )
        let storyboard = UIStoryboard(name: "Auth", bundle: Bundle.auth)
        let viewController = storyboard.instantiateViewController(withIdentifier: "FastSigninViewController") as! FastSigninViewController
        viewController.viewModel = viewModel

        self.viewController = viewController
        self.viewModel = viewModel
    }
}

final class LoginAssembly {
    let viewModel: LoginViewModelProtocol
    var viewController: LoginViewController

    init(serviceFactory: ServiceFactoryProtocol) {
        let viewModel = LoginViewModel(
            restApiManager: serviceFactory.makeRestApiManager()
        )
        let storyboard = UIStoryboard(name: "Auth", bundle: Bundle.auth)
        let viewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        viewController.viewModel = viewModel

        self.viewModel = viewModel
        self.viewController = viewController
    }
}

final class RegistrationAssembly {
    let viewModel: RegisterViewModelProtocol
    var viewController: RegistrationViewController

    init(serviceFactory: ServiceFactoryProtocol) {
        let viewModel = RegisterViewModel(
            restApiManager: serviceFactory.makeRestApiManager()
        )
        let storyboard = UIStoryboard(name: "Auth", bundle: Bundle.auth)
        let viewController = storyboard.instantiateViewController(withIdentifier: "RegistrationViewController") as! RegistrationViewController
        viewController.viewModel = viewModel

        self.viewModel = viewModel
        self.viewController = viewController
    }
}

final class ForgotPasswordAssembly {
    let viewModel: ForgotPasswordViewModelProtocol
    var viewController: ForgotPasswordViewController

    init(serviceFactory: ServiceFactoryProtocol) {
        let viewModel = ForgotPasswordViewModel(
            restApiManager: serviceFactory.makeRestApiManager()
        )
        let storyboard = UIStoryboard(name: "Auth", bundle: Bundle.auth)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        viewController.viewModel = viewModel

        self.viewModel = viewModel
        self.viewController = viewController
    }
}

final class ResetPasswordAssembly {
    let viewModel: ResetPasswordViewModelProtocol
    var viewController: ResetPasswordViewController

    init(serviceFactory: ServiceFactoryProtocol, resetPasswordToken: String) {
        let viewModel = ResetPasswordViewModel(resetPasswordToken: resetPasswordToken,
                                               restApiManager: serviceFactory.makeRestApiManager())
        let storyboard = UIStoryboard(name: "Auth", bundle: Bundle.auth)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ResetPasswordViewController") as! ResetPasswordViewController
        viewController.viewModel = viewModel

        self.viewModel = viewModel
        self.viewController = viewController
    }
}

final class StartingTutorialAssembly {
    var viewController: StartingTutorialViewController

    init(serviceFactory: ServiceFactoryProtocol) {
        let storyboard = UIStoryboard(name: "Auth", bundle: Bundle.auth)
        let viewController = storyboard.instantiateViewController(withIdentifier: "StartingTutorialViewController") as! StartingTutorialViewController

        self.viewController = viewController
    }
}

final class ImageAssembly {
    var viewController: ImageViewController

    init(serviceFactory: ServiceFactoryProtocol) {
        let storyboard = UIStoryboard(name: "Auth", bundle: Bundle.auth)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController

        self.viewController = viewController
    }
}
