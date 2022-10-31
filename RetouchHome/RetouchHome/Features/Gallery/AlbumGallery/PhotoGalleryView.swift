//
//  PhotoGalleryView.swift
//  RetouchHome
//
//  Created by Vladyslav Panevnyk on 18.10.2022.
//

import SwiftUI
import RetouchCommon

public struct PhotoGalleryView: View {
    // MARK: - Properties
    @ObservedObject private var viewModel: PhotoGalleryViewModel

    // MARK: - Inits
    public init(viewModel: PhotoGalleryViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - UI
    public var body: some View {
        bodyView
            .onAppear(perform: viewModel.viewOnAppear)
    }

    var bodyView: some View {
        VStack(spacing: 0) {
            headerView

            ZStack(alignment: .bottomTrailing) {
                ScrollableImage(image: viewModel.scaledImage)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .animation(.default)

                OrderButton(action: {

                })
                    .offset(x: -16, y: -16)
                    .animation(.default)
            }

            GroupsAndTagsView(retouchGroups: viewModel.retouchGroups)
        }
        .background(Color.kBackground)
    }

    var headerView: some View {
        HStack(spacing: 16) {
            BackSwiftButton(action: viewModel.didSelectBack)

            HStack {
                Text("Retouch cost:")
                    .font(.kPlainText)

                PriceSwiftView(price: $viewModel.retouchCost)

                Spacer()

                BalanceSwiftView(action: viewModel.didSelectBalance)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 56)
        .frame(maxWidth: .infinity)
        .padding([.leading, .trailing], 16)
        .zIndex(100)
    }
}
