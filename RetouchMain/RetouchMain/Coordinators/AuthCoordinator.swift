//
//  AuthCoordinator.swift
//  RetouchMain
//
//  Created by Vladyslav Panevnyk on 12.03.2021.
//

import UIKit
import RetouchAuth
import RetouchMore
import RetouchCommon

protocol AuthCoordinatorDelegate: AnyObject {
    func didLoginSuccessfully()
}

final class AuthCoordinator {
    // MARK: - Properties
    private let serviceFactory: ServiceFactoryProtocol
    private let navigationController: UINavigationController

    private weak var onFirstStartTutorialViewController: FastSigninViewController?
    private weak var loginViewController: LoginViewController?
    private weak var registrationViewController: RegistrationViewController?
    private weak var forgotPasswordViewController: ForgotPasswordViewController?
    private weak var resetPasswordViewController: ResetPasswordViewController?
    private weak var startingTutorialViewController: StartingTutorialViewController?

    // Delegate
    weak var delegate: AuthCoordinatorDelegate?

    // MARK: - Inits
    init(navigationController: UINavigationController,
         serviceFactory: ServiceFactoryProtocol) {
        self.navigationController = navigationController
        self.serviceFactory = serviceFactory
    }

    // MARK: - Starts
    func start(animated: Bool) {
        if StartingTutorialViewController.isShowen {
            startAuth(animated: animated)
        } else {
            startTutorialAuth(animated: animated)
        }
    }

    func startResetPasswordScreen(resetPasswordToken: String, animated: Bool) {
        let loginViewController = makeLoginViewController()
        let forgotPasswordViewController = makeForgotPasswordViewController()
        let resetPasswordViewController = makeResetPasswordViewController(resetPasswordToken: resetPasswordToken)
        navigationController.setViewControllers(
            [loginViewController, forgotPasswordViewController, resetPasswordViewController],
            animated: animated)
    }

    func startAuth(animated: Bool) {
        let fastSigninViewController = makeFastSigninViewController()
        navigationController.setViewControllers([fastSigninViewController], animated: animated)
    }

    func startTutorialAuth(animated: Bool) {
        let startingTutorialAssembly = StartingTutorialAssembly(serviceFactory: serviceFactory)
        startingTutorialAssembly.viewController.coordinatorDelegate = self
        self.startingTutorialViewController = startingTutorialAssembly.viewController

        let vc1 = makeImageViewController(imageString: "tutorialImage1",
                                          bgImageString: "tutorialBGImage1")
        let vc2 = makeImageViewController(imageString: "tutorialImage2",
                                          bgImageString: "tutorialBGImage2")
        let vc3 = makeImageViewController(imageString: "tutorialImage3",
                                          bgImageString: "tutorialBGImage3")

        startingTutorialAssembly.viewController.orderedViewControllers = [vc1, vc2, vc3]
        navigationController.setViewControllers([startingTutorialAssembly.viewController], animated: animated)
    }
}

// MARK: - StartingTutorialCoordinatorDelegate
extension AuthCoordinator: StartingTutorialCoordinatorDelegate {
    public func didSelectSignIn(from viewController: StartingTutorialViewController) {
        startAuth(animated: true)
    }
    
    public func didSelectUseApp(from viewController: StartingTutorialViewController) {
        didLoginSuccessfully()
    }
}

// MARK: - OnFirstStartTutorialCoordinatorDelegate
extension AuthCoordinator: FastSigninCoordinatorDelegate {
    public func didLoginSuccessfully() {
        delegate?.didLoginSuccessfully()
    }

    public func didSelectUseOtherSigninOptions() {
        didSelectLogin()
    }
}

// MARK: - BaseAuthCoordinatorDelegate
extension AuthCoordinator: BaseAuthCoordinatorDelegate {
    func didSelectLogin() {
        didSelectLogin(animated: true)
    }

    func didSelectLogin(animated: Bool) {
        let loginViewController = makeLoginViewController()
        navigationController.setViewControllers([loginViewController], animated: animated)
    }

    func didSelectSignUp() {
        let registrationViewController = makeRegistrationViewController()
        navigationController.setViewControllers([registrationViewController], animated: true)
    }
}

// MARK: - UseAgreementsDelegate
extension AuthCoordinator: UseAgreementsDelegate {
    func didSelectPrivacyPolicy() {
        AnalyticsService.logAction(.privacyPolicyAuth)
        let infoViewController = makePrivacyPolicyViewController()
        navigationController.pushViewController(infoViewController, animated: true)
    }
    
    func didSelectTermsOfUse() {
        AnalyticsService.logAction(.termsOfUseAuth)
        let infoViewController = makeTermsOfUseViewController()
        navigationController.pushViewController(infoViewController, animated: true)
    }
}

// MARK: - InfoCoordinatorDelegate
extension AuthCoordinator: InfoCoordinatorDelegate {
    public func didSelectBackAction() {
        navigationController.popViewController(animated: true)
    }
}

// MARK: - LoginViewControllerCoordinatorDelegate
extension AuthCoordinator: LoginViewControllerCoordinatorDelegate {
    func didSelectForgotPassword() {
        let forgotPasswordViewController = makeForgotPasswordViewController()
        navigationController.pushViewController(forgotPasswordViewController, animated: true)
    }
}

// MARK: - RegistrationViewControllerCoordinatorDelegate
extension AuthCoordinator: RegistrationViewControllerCoordinatorDelegate {
    func successRegistration() {
        didLoginSuccessfully()
    }
}

// MARK: - ForgotPasswordCoordinatorDelegate
extension AuthCoordinator: ForgotPasswordCoordinatorDelegate {
    func didSelectLoginWith(email: String) {
//        let loginViewController = LoginViewController.instantiate
//        loginViewController.loginViewControllerCoordinator = self
//        self.loginViewController = loginViewController
//
//        loginViewController.config(loginViewModel: LoginViewModel(defaultEmail: email))
//
//        navigationController?.setViewControllers([loginViewController], animated: true)
    }

    func dissmiss() {
        navigationController.popViewController(animated: true)
    }
}

// MARK: - ResetPasswordCoordinatorDelegate
extension AuthCoordinator: ResetPasswordCoordinatorDelegate {}

// MARK: - ViewController factories
private extension AuthCoordinator {
    func makeFastSigninViewController() -> FastSigninViewController {
        let fastSigninAssembly = FastSigninAssembly(serviceFactory: serviceFactory)
        self.onFirstStartTutorialViewController = fastSigninAssembly.viewController
        fastSigninAssembly.viewController.coordinatorDelegate = self
        return fastSigninAssembly.viewController
    }

    func makeImageViewController(imageString: String, bgImageString: String) -> ImageViewController {
        let imageAssembly = ImageAssembly(serviceFactory: serviceFactory)
        imageAssembly.viewController.imageString = imageString
        imageAssembly.viewController.bgImageString = bgImageString
        return imageAssembly.viewController
    }

    func makeForgotPasswordViewController() -> ForgotPasswordViewController {
        let forgotPasswordAssembly = ForgotPasswordAssembly(serviceFactory: serviceFactory)
        forgotPasswordAssembly.viewController.coordinatorDelegate = self
        self.forgotPasswordViewController = forgotPasswordAssembly.viewController
        return forgotPasswordAssembly.viewController
    }

    func makeResetPasswordViewController(resetPasswordToken: String) -> ResetPasswordViewController {
        let resetPasswordAssembly = ResetPasswordAssembly(serviceFactory: serviceFactory, resetPasswordToken: resetPasswordToken)
        resetPasswordAssembly.viewController.coordinatorDelegate = self
        self.resetPasswordViewController = resetPasswordAssembly.viewController
        return resetPasswordAssembly.viewController
    }

    func makeLoginViewController() -> LoginViewController {
        let loginAssembly = LoginAssembly(serviceFactory: serviceFactory)
        loginAssembly.viewController.coordinatorDelegate = self
        self.loginViewController = loginAssembly.viewController
        return loginAssembly.viewController
    }

    func makeRegistrationViewController() -> RegistrationViewController {
        let registrationAssembly = RegistrationAssembly(serviceFactory: serviceFactory)
        registrationAssembly.viewController.coordinatorDelegate = self
        self.registrationViewController = registrationAssembly.viewController
        return registrationAssembly.viewController
    }

    func makePrivacyPolicyViewController() -> InfoViewController {
        let infoAssembly = InfoAssembly(serviceFactory: serviceFactory, viewModel: PrivacyPolicyViewModel())
        infoAssembly.viewController.coordinatorDelegate = self
        return infoAssembly.viewController
    }
    
    func makeTermsOfUseViewController() -> InfoViewController {
        let infoAssembly = InfoAssembly(serviceFactory: serviceFactory, viewModel: TermsAndConditionsViewModel())
        infoAssembly.viewController.coordinatorDelegate = self
        return infoAssembly.viewController
    }
}
