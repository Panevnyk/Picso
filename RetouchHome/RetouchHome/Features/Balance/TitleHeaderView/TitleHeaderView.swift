//
//  TitleHeaderView.swift
//  RetouchHome
//
//  Created by Panevnyk Vlad on 11.07.2022.
//

import UIKit

final class TitleHeaderView: UICollectionReusableView {
    // MARK: - Properties
    @IBOutlet private var titleLable: UILabel!
    
    // MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLable.font = UIFont.kSectionHeaderText
        titleLable.textColor = .black
    }
    
    // MARK: - setup
    func set(title: String) {
        titleLable.text = title
    }
}
