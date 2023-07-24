//
//  AStartingTutorialView.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk  on 21.07.2023.
//

import SwiftUI
import RetouchCommon

public struct AStartingTutorialView: View {
    @ObservedObject
    private var viewModel: AStartingTutorialViewModel
    
    public init(viewModel: AStartingTutorialViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        bodyView
            .background(Color.kBlue)
            .onAppear(perform: viewModel.onAppear)
    }

    var bodyView: some View {
        ZStack(alignment: .top) {
            tabView
            
            header
            
            footer
        }
    }
    
    var header: some View {
        ZStack(alignment: .center) {
            Text(viewModel.headerText)
                .foregroundColor(.white)
                .font(.kBigTitleText)
            
            HStack {
                Spacer()
                
                AClearButton(
                    text: viewModel.skipText,
                    action: viewModel.skipAction
                )
                .padding(.trailing, 16)
            }
        }
        .frame(height: 64)
    }
    
    var footer: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                AMainSmallButton(
                    text: viewModel.nextText,
                    action: viewModel.nextAction
                )
                .padding(.trailing, 16)
            }
        }
    }
    
    var tabView: some View {
        TabView(selection: $viewModel.selectedItem) {
            ForEach(0 ..< viewModel.tutorialImagesArray.count) { index in
                ZStack {
                    Image(viewModel.tutorialImagesArray[index].bgImageView, bundle: .common)
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Image(viewModel.tutorialImagesArray[index].imageView, bundle: .common)
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page)
        .ignoresSafeArea()
    }
}

// MARK: - UserDefaults isShowen
extension AStartingTutorialView {
    private static let userDefaultsIsShowenKey = "StartingTutorialUserDefaultsIsShowenKey"
    public static var isShowen: Bool {
        get {
            UserDefaults.standard.bool(
                forKey: AStartingTutorialView.userDefaultsIsShowenKey
            )
        }
        set {
            UserDefaults.standard.set(
                newValue,
                forKey: AStartingTutorialView.userDefaultsIsShowenKey
            )
        }
    }
}
