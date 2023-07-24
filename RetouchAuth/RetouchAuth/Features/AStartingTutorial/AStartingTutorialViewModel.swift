//
//  AStartingTutorialViewModel.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk  on 21.07.2023.
//

import SwiftUI
import Combine
import RetouchCommon

struct TutorialImages: Hashable {
    let imageView: String
    let bgImageView: String
}

public protocol AStartingTutorialViewCoordinatorDelegate: UseAgreementsDelegate {
    func didSelectUseApp()
}

public class AStartingTutorialViewModel: ObservableObject {
    // MARK: - Properties
    // Delegates
    private(set) var coordinatorDelegate: AStartingTutorialViewCoordinatorDelegate?
    
    // Data
    let tutorialImagesArray: [TutorialImages]
    
    // Combine
    @Published var headerText: String = "Tutorial"
    @Published var skipText: String = "SKIP"
    @Published var nextText: String = "NEXT"
    
    @Published var selectedItem: Int = 0
    
    private lazy var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Inits
    public init(
        coordinatorDelegate: AStartingTutorialViewCoordinatorDelegate?
    ) {
        self.coordinatorDelegate = coordinatorDelegate
        self.tutorialImagesArray = [
            TutorialImages(imageView: "tutorialImage1", bgImageView: "tutorialBGImage1"),
            TutorialImages(imageView: "tutorialImage2", bgImageView: "tutorialBGImage2"),
            TutorialImages(imageView: "tutorialImage3", bgImageView: "tutorialBGImage3")
        ]
        
        bindData()
    }
    
    // MARK: Bind
    func bindData() {
        $selectedItem
            .sink { value in
                self.headerText = "Tutorial \(value + 1)/\(self.tutorialImagesArray.count)"
                self.nextText = self.isLastItem(value) ? "START" : "NEXT"
            }
            .store(in: &subscriptions)
    }
    
    func isLastItem(_ item: Int) -> Bool {
        return item >= tutorialImagesArray.count - 1
    }

    // MARK: - Actions
    func onAppear() {
        AStartingTutorialView.isShowen = true
        AnalyticsService.logScreen(.startingTutorial)
    }
    
    func skipAction() {
        coordinatorDelegate?.didSelectUseApp()
        AnalyticsService.logAction(.skipStartingTutorial)
    }
    
    func nextAction() {
        if isLastItem(selectedItem) {
            coordinatorDelegate?.didSelectUseApp()
            AnalyticsService.logAction(.signInStartingTutorial)
        } else {
            selectedItem += 1
            AnalyticsService.logAction(.nextStartingTutorial)
        }
    }
}
