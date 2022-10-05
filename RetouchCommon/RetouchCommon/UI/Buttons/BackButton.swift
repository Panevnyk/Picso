//
//  BackButton.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 13.02.2021.
//

import UIKit

public final class BackButton: UIButton {
    // Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initCustomize()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCustomize()
    }

    // Customize
    private func initCustomize() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.masksToBounds = true
        setImage(UIImage(named: "icLeftArrowPurple", in: Bundle.common, compatibleWith: nil), for: .normal)
    }
}
