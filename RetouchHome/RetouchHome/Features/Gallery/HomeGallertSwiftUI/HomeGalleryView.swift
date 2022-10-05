//
//  HomeGalleryView.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 16.09.2022.
//

import SwiftUI
import RetouchCommon

public struct HomeGalleryView: View {
    @ObservedObject private var viewModel: HomeGalleryViewModel

    public init(viewModel: HomeGalleryViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationView {
            bodyView
//                .onAppear(perform: intent.viewOnAppear)
                .navigationBarHidden(true)
                .edgesIgnoringSafeArea(.top)
        }
        .navigationViewStyle(.stack)
    }

    var bodyView: some View {
        VStack {
            HeaderSwiftView(title: "Home",
                            expandableTitle: viewModel.expandableTitle,
                            isBackButtonHidden: viewModel.isBackHidden)

            PhotoGalleryView(assets: viewModel.assets)

            Spacer()
        }
        .background(Color.kBackground)
    }
}

//struct HomeGalleryView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeGalleryView()
//    }
//}
