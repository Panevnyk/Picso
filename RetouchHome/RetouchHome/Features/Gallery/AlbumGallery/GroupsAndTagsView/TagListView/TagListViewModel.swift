//
//  TagListViewModel.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 19.10.2022.
//

import SwiftUI

final class TagListViewModel: ObservableObject {
    let retouchGroup: PresentableRetouchGroup
    @Binding var openIndex: Int?

    init(retouchGroup: PresentableRetouchGroup,
         openIndex: Binding<Int?>) {
        self.retouchGroup = retouchGroup
        self._openIndex = openIndex
    }

    func didSelectTagItem(by index: Int) {
        openIndex = openIndex == index ? nil : index
        retouchGroup.update(by: index, isOpened: openIndex != nil)
    }
}
