//
//  PhotoGalleryViewModel.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 18.10.2022.
//

import UIKit
import RetouchCommon

public protocol PhotoGalleryViewCoordinatorDelegate: BaseBalanceCoordinatorDelegate, BaseCoordinatorDelegate {
}

public class PhotoGalleryViewModel: ObservableObject {
    // MARK: - Properties
    // Boundaries
    private let ordersLoader: OrdersLoaderProtocol
    let phImageLoader: PHImageLoaderProtocol
    var retouchGroups: [PresentableRetouchGroup] = []
    private let iapService: IAPServiceProtocol
    private let freeGemCreditCountService: FreeGemCreditCountServiceProtocol
    private let user: User

    var image: UIImage? {
        didSet { scaledImage = image?.scalePreservingAspectRatio() }
    }

    // Delegate
    public weak var coordinatorDelegate: PhotoGalleryViewCoordinatorDelegate?

    // Combine
    @Published var scaledImage: UIImage?
    @Published var retouchCost: String = "15"

    // MARK: - Init
    public init(ordersLoader: OrdersLoaderProtocol,
                phImageLoader: PHImageLoaderProtocol,
                retouchGroups: [RetouchGroup],
                iapService: IAPServiceProtocol,
                freeGemCreditCountService: FreeGemCreditCountServiceProtocol,
                image: UIImage?) {
        self.ordersLoader = ordersLoader
        self.phImageLoader = phImageLoader
        self.retouchGroups = retouchGroups
            .sorted(by: { $0.orderNumber < $1.orderNumber })
            .map { group in
                group.tags = group.tags.sorted(by: { $0.orderNumber < $1.orderNumber })
                return PresentableRetouchGroup(retouchGroup: group)
            }
        self.iapService = iapService
        self.freeGemCreditCountService = freeGemCreditCountService
        self.image = image
        self.user = UserData.shared.user
    }

    // MARK: - Public
    public func viewOnAppear() {

    }

    public func didSelectBalance() {
        coordinatorDelegate?.didSelectBalanceAction()
    }

    public func didSelectBack() {
        coordinatorDelegate?.didSelectBackAction()
    }
}
