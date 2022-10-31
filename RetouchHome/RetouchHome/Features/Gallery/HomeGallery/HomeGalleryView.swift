//
//  HomeGalleryView.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 16.09.2022.
//

import SwiftUI
import Photos
import RetouchCommon

public struct HomeGalleryView: View {
    // MARK: - Properties
    @ObservedObject private var viewModel: HomeGalleryViewModel

    // MARK: - Inits
    public init(viewModel: HomeGalleryViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - UI
    public var body: some View {
        NavigationView {
            bodyView
                .onAppear(perform: viewModel.viewOnAppear)
                .navigationBarHidden(true)
                .padding(.bottom, -84)
        }
        .navigationViewStyle(.stack)
    }

    var bodyView: some View {
        VStack {
            HeaderSwiftView(title: "Home",
                            expandableTitle: viewModel.expandableTitle,
                            expandableShowDetail: $viewModel.expandableShowDetail,
                            isBackButtonHidden: viewModel.isBackHidden,
                            balanceAction: viewModel.didSelectBalance,
                            backAction: viewModel.didSelectBack)

            GalleryView(assets: viewModel.assets, action: viewModel.didSelectPhoto)
                .popup(show: $viewModel.expandableShowDetail,
                       insets: UIEdgeInsets(top: -4, left: 24, bottom: 24, right: 24),
                       content: albumGalleryView)

            Spacer()
        }
        .background(Color.kBackground)
    }

    func albumGalleryView() -> some View {
        AlbumGalleryView(viewModel: AlbumGalleryViewModel(),
                         coordinatorDelegate: self)
    }
}

// MARK: - Public
public extension HomeGalleryView {
    func setIsBackHidden(_ isBackHidden: Bool) {
        viewModel.isBackHidden = isBackHidden
    }
}

// MARK: - AlbumGalleryCoordinatorDelegate
extension HomeGalleryView: AlbumGalleryCoordinatorDelegate {
    public func didSelectAlbum(assets: PHFetchResult<PHAsset>, title: String) {
        viewModel.didSelectAlbum(assets: assets, title: title)
    }
}
