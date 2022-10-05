//
//  RetouchGroupViewModel.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 11.02.2021.
//

import RxSwift
import RxCocoa
import RetouchCommon

public protocol RetouchGroupViewModelDelegate: AnyObject {
    func reloadData()
}

public protocol RetouchGroupViewModelProtocol {
    var openGroupIndexObservable: Observable<Int> { get set }

    var delegate: RetouchGroupViewModelDelegate? { get set }

    func itemsCount(in section: Int) -> Int
    func retouchGroupItem(for item: Int) -> RetouchGroupItemViewModelProtocol
    func isOpenItem(for item: Int) -> Bool
    func getOpenGroupIndex() -> Int

    func setRetouchGroups(_ retouchGroups: [PresentableRetouchGroup])
    func didSelectItem(for item: Int)
}

public final class RetouchGroupViewModel: RetouchGroupViewModelProtocol {
    private var  retouchGroups: [PresentableRetouchGroup] = []
    private var itemViewModels: [RetouchGroupItemViewModelProtocol] = [] {
        didSet { delegate?.reloadData() }
    }
    private var openGroupIndex = BehaviorRelay(value: 0)
    public lazy var openGroupIndexObservable = openGroupIndex.asObservable()

    public weak var delegate: RetouchGroupViewModelDelegate?
}

// MARK: - Public methods
extension RetouchGroupViewModel {
    public func itemsCount(in section: Int) -> Int {
        return itemViewModels.count
    }

    public func retouchGroupItem(for item: Int) -> RetouchGroupItemViewModelProtocol {
        return itemViewModels[item]
    }

    public func isOpenItem(for item: Int) -> Bool {
        return openGroupIndex.value == item
    }

    public func getOpenGroupIndex() -> Int {
        return openGroupIndex.value
    }

    public func setRetouchGroups(_ retouchGroups: [PresentableRetouchGroup]) {
        self.retouchGroups = retouchGroups
        let itemViewModels: [RetouchGroupItemViewModel] = retouchGroups.map {
            return RetouchGroupItemViewModel(
                title: $0.title,
                image: $0.image,
                isSelected: $0.isSelected,
                descriptionForDesigner: $0.descriptionForDesigner
            )
        }
        self.itemViewModels = itemViewModels
    }

    public func didSelectItem(for item: Int) {
        openGroupIndex.accept(item)
        delegate?.reloadData()
    }
}
