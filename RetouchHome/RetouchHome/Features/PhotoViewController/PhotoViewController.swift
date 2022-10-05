//
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 09.02.2021.
//

import UIKit
import RetouchCommon
import Photos
import PhotosUI
import RxSwift
import RxCocoa

public protocol PhotoCoordinatorDelegate: AnyObject {
    func didSelectOrder(_ order: Order, from viewController: PhotoViewController)
    func didSelectOrderNotEnoughGems(orderAmount: Int, from viewController: PhotoViewController)
}

public final class PhotoViewController: UIViewController {
    // MARK: - Properties
    // UI
    @IBOutlet private var imagePresentableView: ImagePresentableView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private var bottomContainerHolderView: UIView!
    @IBOutlet private var bottomContainerView: UIView!
    @IBOutlet private var retouchGroupView: RetouchGroupView!
    @IBOutlet private var retouchTagView: RetouchTagView!
    @IBOutlet private var descriptionHolderView: UIView!
    @IBOutlet private var descriptionView: DescriptionViewHolder!
    
    @IBOutlet private var retouchCostTitleLabel: UILabel!
    @IBOutlet private var priceView: PriceView!
    @IBOutlet private var orderButton: PurpleButton!

    @IBOutlet private var backButton: BackButton!
    
    private var blureBackgroundView: BlureBackgroundView?

    // ViewModel
    public var viewModel: PhotoViewModelProtocol!
    private let disposeBag = DisposeBag()

    // Delegate
    public weak var coordinatorDelegate: PhotoCoordinatorDelegate?

    // MARK: - Life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()

        setupData()
        setupUI()
        AnalyticsService.logScreen(.photo)
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
}

// MARK: - SetupData
private extension PhotoViewController {
    func setupData() {
        retouchGroupView.viewModel = viewModel.retouchGroupViewModel
        viewModel.retouchGroupViewModel.delegate = retouchGroupView
        retouchTagView.viewModel = viewModel.retouchTagViewModel
        viewModel.retouchTagViewModel.delegate = retouchTagView

        viewModel.retouchCostObservable
            .bind(to: priceView.priceLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.isOrderAvailableObservable
            .bind(to: orderButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}

// MARK: - SetupUI
private extension PhotoViewController {
    func setupUI() {
        view.backgroundColor = .white

        imagePresentableView.imageView.contentMode = .scaleAspectFit
        imagePresentableView.imageView.image = getImage()

        bottomContainerView.backgroundColor = .white
        bottomContainerView.layer.cornerRadius = 16
        bottomContainerView.layer.masksToBounds = true
        
        bottomContainerHolderView.backgroundColor = .white
        bottomContainerHolderView.layer.cornerRadius = 16
        bottomContainerHolderView.addContainerTopShadow()

        orderButton.setTitle("Order", for: .normal)

        retouchCostTitleLabel.font = .kPlainText
        retouchCostTitleLabel.textColor = .black
        retouchCostTitleLabel.text = "Retouch cost:"
        
        descriptionView.setPlaceholderText("Please, describe what you would like to change")
        descriptionView.delegate = self
        descriptionView.alpha = 0
        descriptionHolderView.isHidden = true
        
        updateNotificationViewModelState()
    }
    
    func getImage() -> UIImage? {
//        if UIDevice.current.userInterfaceIdiom == .pad {
            return viewModel.getImage()?
                .scalePreservingAspectRatio(targetSize: UIScreen.main.bounds.size)
//        } else {
//            return viewModel.getImage()
//        }
    }
}

// MARK: - BaseTapableViewDelegate
extension PhotoViewController: BaseTapableViewDelegate {
    public func didTapAction(inView view: BaseTapableView) {
        guard let data = viewModel.getOpenedRetouchData() else { return }
        let viewController = DetailTagAlertViewController(presentableRetouchData: data)
        viewController.delegate = self
        viewController.show()
        AnalyticsService.logAction(.detailTagAlert)
    }
}

// MARK: - DetailTagAlertViewControllerDelegate
extension PhotoViewController: DetailTagAlertViewControllerDelegate {
    public func didSelectAdd(value: String?, from viewController: DetailTagAlertViewController) {
        viewModel.didAddTagDescription(value)
        descriptionView.setText(viewModel.getCurrentTagDescription())
        AnalyticsService.logAction(.didAddDetailTag)
    }
}

// MARK: - PhotoViewModelDelegate
extension PhotoViewController: PhotoViewModelDelegate {
    public func didUpdateImage(_ image: UIImage?) {
        imagePresentableView.imageView.image = getImage()
    }
    
    public func didUpdateOpenTagIndex(_ openTagIndex: Int?, previousValue: Int?) {
        AnalyticsService.logAction(.didUpdateOpenTagIndex)
        
        if let openTagIndex = openTagIndex {
            if let previousValue = previousValue {
                descriptionView.move(to: openTagIndex > previousValue ? .toLeft : .toRight,
                                     text: viewModel.getCurrentTagDescription())
            } else {
                descriptionView.setText(viewModel.getCurrentTagDescription())
            }
        }
        
        if descriptionHolderView.isHidden != (openTagIndex == nil) {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
                self.descriptionHolderView.isHidden = openTagIndex == nil
                self.descriptionView.alpha = openTagIndex == nil ? 0 : 1
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    public func showActivityIndicator() {
        activityIndicator.startAnimating()
    }
    
    public func hideActivityIndicator() {
        activityIndicator.stopAnimating()
    }
    
    public func purchaseCompletion(isSuccessfully: Bool) {
        hideBlurPurchaseView()
        if isSuccessfully {
            createOrder()
        }
    }
    
    public func updateNotificationViewModelState() {
//        notificationView.isHidden = !viewModel.needToShowFreeGemCreditCountAlert()
//        if let notificationViewModel = viewModel.notificationViewModel() {
//            notificationView.setup(viewModel: notificationViewModel)
//        }
    }
}

// MARK: - Blur purchase View
private extension PhotoViewController {
    func showBlurPurchaseView() {
        let blureBackgroundView = BlureBackgroundView()
        let image = UIImage(named: "icPhotoRetouchingWaiting1",
                            in: Bundle.common,
                            compatibleWith: nil)
        blureBackgroundView.setImage(image)
        blureBackgroundView.setTitle("      Processing purchase ...")
        let bgView = tabBarController?.view
        bgView?.addSubviewUsingConstraints(view: blureBackgroundView)
        blureBackgroundView.showView()
        self.blureBackgroundView = blureBackgroundView
    }
    
    func hideBlurPurchaseView() {
        blureBackgroundView?.hideView(completition: { [weak self] in
            self?.blureBackgroundView?.removeFromSuperview()
            self?.blureBackgroundView = nil
        })
    }
}

// MARK: - Actions
extension PhotoViewController {
    @IBAction private func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction private func orderAction(_ sender: Any) {
        didSelectFreeOrStandartOrder()
    }

    func didSelectFreeOrStandartOrder() {
        if viewModel.isFirstOrderForFreeAvailabel() {
            didSelectFreeOrder()
        } else {
            didSelectOrder()
        }
    }
    
    func didSelectFreeOrder() {
        if viewModel.isFirstOrderForFreeOutOfFreeGemCount() {
            makeOutOfFreeOrderAlert(diamondsPrice: viewModel.getUserFreeGemCreditCount()) { [weak self] in
                AnalyticsService.logAction(.makeOutOfFreeFastOrder)
                self?.fastOrder()
            }
        } else {
            makeFreeOrderAlert(diamondsPrice: viewModel.getUserFreeGemCreditCount()) { [weak self] in
                AnalyticsService.logAction(.makeFreeOrder)
                self?.createOrder()
            }
        }
    }
    
    public func didSelectOrder() {
        if viewModel.isEnoughGemsForOrder {
            makeOrderAlert { [weak self] in
                AnalyticsService.logAction(.makeOrder)
                self?.createOrder()
            }
        } else {
            if let usdPrice = viewModel.getOrderPriceUSD() {
                if viewModel.isCountainOrderHistory {
                    makeNotEnoughGemsOrderAlert(
                        usdPrice: usdPrice,
                        fastOrder: { [weak self] in self?.fastOrder() },
                        goToBalance: { [weak self] in self?.goToBalance() })
                } else {
                    fastOrder()
                }
            } else {
                goToBalance()
            }
        }
    }
    
    private func fastOrder() {
        AnalyticsService.logAction(.makeFastOrder)
        showBlurPurchaseView()
        viewModel.makePurchase(from: self)
    }

    private func goToBalance() {
        AnalyticsService.logAction(.showBalanceFromOrder)
        coordinatorDelegate?.didSelectOrderNotEnoughGems(
            orderAmount: viewModel.getOrderAmount(), from: self)
    }
    
    private func createOrder() {
        ActivityIndicatorHelper.shared.show(onView: view)
        viewModel.createOrder { [weak self] (result) in
            guard let self = self else { return }

            ActivityIndicatorHelper.shared.hide()
            switch result {
            case .success(let order):
                self.coordinatorDelegate?.didSelectOrder(order, from: self)
            case .failure(let error):
                NotificationBannerHelper.showBanner(error)
            }
        }
    }
}

// MARK: - Alerts
private extension PhotoViewController {
    func makeFreeOrderAlert(diamondsPrice: String, freeOrder: (() -> Void)?) {
        AnalyticsService.logAction(.showFreeOrderAlert)
        let order = RTAlertAction(title: "Free order",
                                  style: .default,
                                  action: { freeOrder?() })
        let cancel = RTAlertAction(title: "Cancel",
                                   style: .cancel)
        let img = UIImage(named: "icFirstOrderForFree", in: Bundle.common, compatibleWith: nil)
        let alert = RTAlertController(title: "Make free order",
                                      message: "Your first order is available for free. Send the photo to our designer and enjoy the result.",
                                      image: img,
                                      actionPositionStyle: .horizontal)
        alert.addActions([cancel, order])
        alert.show()
    }
    
    func makeOutOfFreeOrderAlert(diamondsPrice: String, outOfFreeOrder: (() -> Void)?) {
        AnalyticsService.logAction(.showOutOfFreeOrderAlert)
        let order = RTAlertAction(title: "Order",
                                  style: .default,
                                  action: { outOfFreeOrder?() })
        let cancel = RTAlertAction(title: "Go back",
                                   style: .cancel)
        let img = UIImage(named: "icFirstOrderForFree", in: Bundle.common, compatibleWith: nil)
        let alert = RTAlertController(title: "Your order is out of free",
                                      message: "You chose tags for more than \(diamondsPrice) diamonds. It's out of our free bonuses. You can make an order and pay for extra diamonds. Or go back and choose less amount of tags.",
                                      image: img,
                                      actionPositionStyle: .horizontal)
        alert.addActions([cancel, order])
        alert.show()
    }
    
    func makeOrderAlert(success: (() -> Void)?) {
        AnalyticsService.logAction(.showOrderAlert)
        let cancel = RTAlertAction(title: "Cancel", style: .cancel)
        let order = RTAlertAction(title: "Order", style: .default, action: { success?() })
        let img = UIImage(named: "icDoYouWannaOrder", in: Bundle.common, compatibleWith: nil)
        let alert = RTAlertController(title: "Make order",
                                      message: "Our designers will do best to provide you awesome result",
                                      image: img)
        alert.addActions([cancel, order])
        alert.show()
    }
    
    func makeNotEnoughGemsOrderAlert(usdPrice: String, fastOrder: (() -> Void)?, goToBalance: (() -> Void)?) {
        AnalyticsService.logAction(.showFastOrderAlert)
        let order = RTAlertAction(title: "Order for \(usdPrice)",
                                  style: .default,
                                  action: { fastOrder?() })
        let goToBalance = RTAlertAction(title: "Buy more gems and get bonuses",
                                        style: .cancel,
                                        action: { goToBalance?() })
        let cancel = RTAlertAction(title: "Cancel",
                                   style: .cancel)
        let img = UIImage(named: "icDoYouWannaOrder", in: Bundle.common, compatibleWith: nil)
        let alert = RTAlertController(title: "Make order",
                                      message: "Our designers will do best to provide you awesome result",
                                      image: img,
                                      actionPositionStyle: .vertical)
        alert.addActions([order, goToBalance, cancel])
        alert.show()
    }
}
