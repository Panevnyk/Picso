//
//  MoreViewController.swift
//  RetouchMore
//
//  Created by Vladyslav Panevnyk on 08.03.2021.
//

import UIKit
import RetouchCommon
import MessageUI

public protocol MoreCoordinatorDelegate: BaseBalanceCoordinatorDelegate {
    func didSignout()
    func didSelectTermsAndConditions(from viewController: MoreViewController)
    func didSelectPrivacyPolicy(from viewController: MoreViewController)
    func didSelectSignIn(from viewController: MoreViewController)
}

public class MoreViewController: UIViewController {
    // MARK: - Properties
    // UI
    @IBOutlet private var headerView: HeaderView!

    @IBOutlet private var shareView: MoreActionButton!
    @IBOutlet private var writeToDevelopersView: MoreActionButton!
    @IBOutlet private var termsAndConditionsView: MoreActionButton!
    @IBOutlet private var privacyPolicyView: MoreActionButton!
    @IBOutlet private var pushNotificationsView: MoreActionButton!
    @IBOutlet private var removeAccountView: MoreActionButton!

    @IBOutlet private var signOut: ReversePurpleButton!
    @IBOutlet private var signInDescriptionLabel: UILabel!
    @IBOutlet private var userIdLabel: UILabel!

    // ViewModel
    public var viewModel: MoreViewModelProtocol!

    // Delegates
    public weak var coordinatorDelegate: MoreCoordinatorDelegate?

    // MARK: - Life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }

    // MARK: - Public methods
    public func setupTabBar() {
        tabBarItem.image = MainTab.more.image
        tabBarItem.selectedImage = MainTab.more.selectedImage
        tabBarItem.title = "More"
    }
}

// MARK: - SetupUI
private extension MoreViewController {
    func setupUI() {
        view.backgroundColor = .kBackground

        headerView.setTitle("More")
        headerView.hideExpandableView()
        headerView.setBackgroundColor(.kBackground)
        headerView.balanceDelegate = self

        shareView.setTitle("Share")
        shareView.setImage("isShare")
        shareView.delegate = self

        writeToDevelopersView.setTitle("Write ot developers")
        writeToDevelopersView.setImage("icMessage")
        writeToDevelopersView.delegate = self

        termsAndConditionsView.setTitle("Terms of Use")
        termsAndConditionsView.setImage("icTermsAndConditions")
        termsAndConditionsView.delegate = self

        privacyPolicyView.setTitle("Privacy Policy")
        privacyPolicyView.setImage("icPrivacyPolicy")
        privacyPolicyView.delegate = self

        pushNotificationsView.setTitle("Enable push notifications")
        pushNotificationsView.setImage("icNotifications")
        pushNotificationsView.delegate = self
        
        removeAccountView.setTitle("Remove account")
        removeAccountView.setImage("icTrash")
        removeAccountView.delegate = self
        
        signInDescriptionLabel.textColor = .kGrayText
        signInDescriptionLabel.font = UIFont.kDescriptionText

        userIdLabel.textColor = .kGrayText
        userIdLabel.font = .kDescriptionText
        
        updateUI()
    }
    
    func updateUI() {
        removeAccountView.isHidden = !viewModel.isRemoveAccountAvailable
        signOut.setTitle(viewModel.signInOutTitle, for: .normal)
        signInDescriptionLabel.text = viewModel.signInDescriptionTitle
        userIdLabel.text = viewModel.userIdTitle
    }
}

// MARK: - BaseTapableViewDelegate
extension MoreViewController: BaseTapableViewDelegate {
    public func didTapAction(inView view: BaseTapableView) {
        switch view {
        case shareView.xibView: share()
        case writeToDevelopersView.xibView: sendEmail()
        case termsAndConditionsView.xibView: termsOfUse()
        case privacyPolicyView.xibView: privacyPolicy()
        case pushNotificationsView.xibView: openPushNotificationSettings()
        case removeAccountView.xibView: removeAccount()
        default: break
        }
    }

    private func share() {
        AnalyticsService.logAction(.shareAppStoreLink)
        ShareHelper.share(Constants.retouchYouAppStoreLink, from: self)
    }

    private func sendEmail() {
        AnalyticsService.logAction(.writeToDevelopers)
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([Constants.retouchYouMail])
            mail.setSubject("From \(viewModel.userIdTitle))")

            self.present(mail, animated: true)
        } else {
            AlertHelper.show(title: "Fail to send mail", message: nil)
        }
    }
    
    private func termsOfUse() {
        AnalyticsService.logAction(.termsOfUseFromMore)
        coordinatorDelegate?.didSelectTermsAndConditions(from: self)
    }
    
    private func privacyPolicy() {
        AnalyticsService.logAction(.privacyPolicyFromMore)
        coordinatorDelegate?.didSelectPrivacyPolicy(from: self)
    }
    
    private func openPushNotificationSettings() {
        AnalyticsService.logAction(.openPushNotificationSettings)
        SettingsHelper.openSettings()
    }
    
    private func removeAccount() {
        if viewModel.isRemoveAccountAvailable {
            removeAccountAlert { [weak self] in
                guard let self = self else { return }
    
                AnalyticsService.logAction(.removeAccount)
                ActivityIndicatorHelper.shared.show()
                self.viewModel.removeAccount { [weak self] in
                    self?.updateUI()
                    ActivityIndicatorHelper.shared.hide()
                }
            }
        }
    }
    
    private func removeAccountAlert(removeCallback: (() -> Void)?) {
        AnalyticsService.logAction(.showOutOfFreeOrderAlert)
        let remove = RTAlertAction(title: "Remove account",
                                  style: .default,
                                  action: { removeCallback?() })
        let cancel = RTAlertAction(title: "Cancel",
                                   style: .cancel)
        let img = UIImage(named: "icDoYouWannaOrder", in: Bundle.common, compatibleWith: nil)
        let alert = RTAlertController(title: "Do you realy want to remove your account?",
                                      message: "All your Gems will be removed. You will not have access to your previous orders.",
                                      image: img,
                                      actionPositionStyle: .horizontal)
        alert.addActions([cancel, remove])
        alert.show()
    }
    
}

// MARK: - MFMailComposeViewControllerDelegate
extension MoreViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

// MARK: - BalanceViewDelegate
extension MoreViewController: BalanceViewDelegate {
    public func didTapAction(from view: BalanceView) {
        coordinatorDelegate?.didSelectBalanceAction()
    }
}

// MARK: - Actions
private extension MoreViewController {
    @IBAction func signOut(_ sender: Any) {
        if viewModel.isUserLoginedWithSecondaryLogin {
            AnalyticsService.logAction(.signOut)
            ActivityIndicatorHelper.shared.show()
            viewModel.signOut { [weak self] in
                self?.updateUI()
                ActivityIndicatorHelper.shared.hide()
            }
        } else {
            coordinatorDelegate?.didSelectSignIn(from: self)
        }
    }
}
