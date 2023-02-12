//
//  GroupsAndTagsViewModel.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 19.10.2022.
//

import Combine
import SwiftUI
import RetouchCommon

public class GroupsAndTagsViewModel: ObservableObject {
    let retouchGroups: [PresentableRetouchGroup]
    @Binding var openGroupIndex: Int?
    @Binding var openTagIndex: Int?
    
    init(retouchGroups: [PresentableRetouchGroup],
         openGroupIndex: Binding<Int?>,
         openTagIndex: Binding<Int?>
    ) {
        self.retouchGroups = retouchGroups
        self._openGroupIndex = openGroupIndex
        self._openTagIndex = openTagIndex
    }
}

// MARK: - Tag description
extension GroupsAndTagsViewModel {
    func showTagDescription() {
        guard let data = getOpenedRetouchData() else { return }
        let viewController = DetailTagAlertViewController(presentableRetouchData: data)
        viewController.delegate = self
        viewController.show()
        AnalyticsService.logAction(.detailTagAlert)
    }
    
    func getCurrentTagDescription() -> String {
        return getOpenedRetouchData()?.tag.tagDescription ?? ""
    }
    
    func getOpenedRetouchData() -> PresentableRetouchData? {
        guard let openGroupIndex = openGroupIndex else { return nil }
        guard let openTagIndex = openTagIndex else { return nil }
        guard retouchGroups.count > openGroupIndex else { return nil }
        
        let retouchGroup = retouchGroups[openGroupIndex]
        guard retouchGroup.tags.count > openTagIndex else { return nil }
        
        let tag = retouchGroup.tags[openTagIndex]
        
        return (retouchGroup: retouchGroup, tag: tag)
    }

    func didAddTagDescription(_ tagDescription: String?) {
        guard let retouchData = getOpenedRetouchData() else { return }
        retouchData.tag.tagDescription = tagDescription
        
        objectWillChange.send()
    }
}

// MARK: - DetailTagAlertViewControllerDelegate
extension GroupsAndTagsViewModel: DetailTagAlertViewControllerDelegate {
    public func didSelectAdd(value: String?, from viewController: DetailTagAlertViewController) {
        didAddTagDescription(value)
        AnalyticsService.logAction(.didAddDetailTag)
    }
}
