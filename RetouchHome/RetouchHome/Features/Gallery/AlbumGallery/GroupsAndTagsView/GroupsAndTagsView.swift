//
//  GroupView.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 19.10.2022.
//

import SwiftUI

public struct GroupsAndTagsView: View {
    @ObservedObject private var viewModel: GroupsAndTagsViewModel
    
    public init(retouchGroups: [PresentableRetouchGroup]) {
        self.viewModel = GroupsAndTagsViewModel(retouchGroups: retouchGroups)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            GroupListView(retouchGroups: viewModel.retouchGroups,
                          openIndex: $viewModel.openGroupIndex)
            
            if let openGroupIndex = viewModel.openGroupIndex {
                TagListView(retouchGroup: viewModel.retouchGroups[openGroupIndex],
                            openIndex: $viewModel.openTagIndex)
                    .transition(.move(edge: .bottom))
            }
            
            if let openGroupIndex = viewModel.openGroupIndex,
               let openTagIndex = viewModel.openTagIndex {
                TagDescriptionItemView(title: viewModel
                                            .retouchGroups[openGroupIndex]
                                            .tags[openTagIndex]
                                            .tagDescription,
                                       action: tagDescriptionAction)
                    .transition(.move(edge: .bottom))
            }
        }
        .frame(maxWidth: .infinity)
        .padding([.top, .bottom], 12)
        .background(.white)
        .animation(.default, value: viewModel.openGroupIndex)
        .animation(.default, value: viewModel.openTagIndex)
    }

    func tagDescriptionAction() {
        guard let openGroupIndex = viewModel.openGroupIndex,
              let openTagIndex = viewModel.openTagIndex else { return }
    }
}

struct GroupsAndTagsView_Previews: PreviewProvider {
    static var previews: some View {
        GroupsAndTagsView(retouchGroups: [])
    }
}
