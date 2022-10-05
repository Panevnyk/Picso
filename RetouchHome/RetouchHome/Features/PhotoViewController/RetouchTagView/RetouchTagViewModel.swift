//
//  RetouchTagViewModel.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 11.02.2021.
//

import RetouchCommon
import RxSwift
import RxCocoa

public protocol RetouchTagViewModelDelegate: AnyObject {
    func reloadData()
    func scrollToStart()
}

public protocol RetouchTagViewModelProtocol {
    var delegate: RetouchTagViewModelDelegate? { get set }
    
    var openTagIndexObservable: Observable<Int?> { get }

    func itemsCount(in section: Int) -> Int
    func retouchTagItem(for item: Int) -> RetouchTagItemViewModelProtocol
    func isOpenedTag(for item: Int) -> Bool
    func getPreviousOpenedValue() -> Int?
    
    func didSelectItem(for item: Int)
    func setRetouchGroup(_ retouchGroup: PresentableRetouchGroup, openGroupIndex: Int)
}

public final class RetouchTagViewModel: RetouchTagViewModelProtocol {
    private var retouchGroup: PresentableRetouchGroup? {
        didSet { updateItemViewModel() }
    }
    private var itemViewModels: [RetouchTagItemViewModelProtocol] = []
    private var openGroupIndex: Int = 0 {
        didSet { if oldValue != openGroupIndex { delegate?.scrollToStart() } }
    }
    
    private var openTagIndexBehaviorRelay: BehaviorRelay<Int?> = BehaviorRelay(value: nil)
    public lazy var openTagIndexObservable = openTagIndexBehaviorRelay.asObservable()
    private var openTagIndex: Int? {
        get { openTagIndexBehaviorRelay.value }
        set { previousOpenTagIndex = openTagIndex; openTagIndexBehaviorRelay.accept(newValue) }
    }
    private var previousOpenTagIndex: Int?

    public weak var delegate: RetouchTagViewModelDelegate?
}

// MARK: - Public methods
extension RetouchTagViewModel {
    public func itemsCount(in section: Int) -> Int {
        return itemViewModels.count
    }

    public func retouchTagItem(for item: Int) -> RetouchTagItemViewModelProtocol {
        return itemViewModels[item]
    }
    
    public func isOpenedTag(for item: Int) -> Bool {
        return item == openTagIndex
    }
    
    public func getPreviousOpenedValue() -> Int? {
        return previousOpenTagIndex
    }
    
    public func didSelectItem(for item: Int) {
        guard let retouchGroup = retouchGroup else { return }
        guard retouchGroup.tags.count > item else { return }
        
        let openTagIndexTemp = openTagIndex == nil || openTagIndex != item ? item : nil
        retouchGroup.update(by: item, isOpened: openTagIndexTemp != nil)
        openTagIndex = openTagIndexTemp

        updateItemViewModel()
    }

    public func setRetouchGroup(_ retouchGroup: PresentableRetouchGroup, openGroupIndex: Int) {
        self.retouchGroup = retouchGroup
        self.openGroupIndex = openGroupIndex
        self.openTagIndex = nil
        
        delegate?.reloadData()
    }
}

// MARK: - Private methods
private extension RetouchTagViewModel {
    func updateItemViewModel() {
        guard let retouchGroup = retouchGroup else { return }
        self.itemViewModels = retouchGroup.tags.map {
            let isSelected = retouchGroup.selectedRetouchTags.map({ $0.id }).contains($0.id)
            return RetouchTagItemViewModel(title: $0.title, isSelected: isSelected)
        }
    }
}
