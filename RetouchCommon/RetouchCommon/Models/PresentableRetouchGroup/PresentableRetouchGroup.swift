//
//  PresentableRetouchGroup.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 27.02.2021.
//

import UIKit

public final class PresentableRetouchGroup {
    public var id: String = ""
    public var title: String = ""
    public var image: String = ""
    public var price: Int = 0
    public var orderNumber: Int = 0
    public var tags: [RetouchTag] = []

    public var selectedRetouchTags: [RetouchTag] = []
    public var descriptionForDesigner: String {
        makeDescriptionForDesigner()
    }

    public var isSelected: Bool { return descriptionForDesigner.count > 0 }

    public init(retouchGroup: RetouchGroup) {
        self.id = retouchGroup.id
        self.title = retouchGroup.title
        self.image = retouchGroup.image
        self.price = retouchGroup.price
        self.orderNumber = retouchGroup.orderNumber
        self.tags = retouchGroup.tags
    }
}

// MARK: - Public methods
extension PresentableRetouchGroup {
    public func update(by index: Int, isOpened: Bool) {
        let retouchTag = tags[index]
        if isOpened {
            if !selectedRetouchTags.contains(where: { $0.id == retouchTag.id }) {
                selectedRetouchTags.append(retouchTag)
                print(selectedRetouchTags)
            }
        } else {
            if let selectedIndex = selectedRetouchTags.firstIndex(where: { $0.id == retouchTag.id }) {
                selectedRetouchTags.remove(at: selectedIndex)
                print(selectedRetouchTags)
            }
        }
    }

    func makeDescriptionForDesigner() -> String {
        var descriptionForDesigner = ""
        
        for selectedRetouchTag in selectedRetouchTags {
            let separatorText = descriptionForDesigner.isEmpty ? "" : ", "
            descriptionForDesigner += separatorText + selectedRetouchTag.title
            
            if let tagDescription = selectedRetouchTag.tagDescription, tagDescription.count > 0 {
                descriptionForDesigner += " (\(tagDescription))"
            }
        }
        
        return descriptionForDesigner
    }
}
