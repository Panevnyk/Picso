//
//  RatingView.swift
//  RetouchCommon
//
//  Created by Panevnyk Vlad on 29.04.2021.
//

import UIKit

public final class RatingView: BaseCustomView {
    @IBOutlet private var starButtons: [StarButton]!
    
    public var selectedRating = 1 {
        didSet { didSelectRating?(selectedRating) }
    }
    public var didSelectRating: ((_ value: Int) -> Void)?
    
    public override func initialize() {
        addSelfNibUsingConstraints(bundle: Bundle.common)
    }
    
    @IBAction private func starAction(_ sender: Any) {
        guard let sender = sender as? StarButton else { return }
        starButtons.enumerated().forEach { value in
            if value.element == sender {
                selectStars(by: value.offset)
            }
        }
    }
    
    public func setRating(_ rating: Int) {
        selectStars(by: rating - 1)
    }
    
    private func selectStars(by index: Int) {
        selectedRating = index + 1
        
        for i in 0 ..< starButtons.count {
            starButtons[i].isSelected = i <= index
        }
    }
}
