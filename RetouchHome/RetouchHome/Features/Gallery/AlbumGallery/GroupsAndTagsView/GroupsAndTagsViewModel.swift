//
//  GroupsAndTagsViewModel.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 19.10.2022.
//

import Combine
import CoreGraphics

public class GroupsAndTagsViewModel: ObservableObject {
    let retouchGroups: [PresentableRetouchGroup]
    @Published var openGroupIndex: Int?
    @Published var openTagIndex: Int?

    private var openGroupIndexCancellable: AnyCancellable?

    init(retouchGroups: [PresentableRetouchGroup]) {
        self.retouchGroups = retouchGroups

        openGroupIndexCancellable = $openGroupIndex.sink { _ in
            self.openTagIndex = nil
        }
    }

    
}
