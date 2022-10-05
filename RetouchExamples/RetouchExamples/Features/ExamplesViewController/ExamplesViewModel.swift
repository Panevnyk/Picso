//
//  ExamplesViewModel.swift
//  RetouchExamples
//
//  Created by Vladyslav Panevnyk on 13.02.2021.
//

import RetouchCommon
import Kingfisher

public protocol ExamplesViewModelProtocol {
    func itemsCount(in section: Int) -> Int
    func examplesItem(for item: Int) -> ExampleItemViewModelProtocol
}

public final class ExamplesViewModel: ExamplesViewModelProtocol {
    // MARK: - Properties
    private var examplesItems: [ExampleItemViewModelProtocol] = []
    private let imageCasher = ImageCasher()

    // MARK: - Init
    public init() {
        makeExamplesItems()
        casheAllImages()
    }
}

// MARK: - Public methods
extension ExamplesViewModel {
    public func itemsCount(in section: Int) -> Int {
        return examplesItems.count
    }

    public func examplesItem(for item: Int) -> ExampleItemViewModelProtocol {
        return examplesItems[item]
    }
}

// MARK: - Factory methods
private extension ExamplesViewModel {
    func makeExamplesItems() {
        examplesItems = [
            ExampleItemViewModel(title: "Body", description: "Slimmer waist, hips size, remove stretch marks, remove cellulite, legs width", imageAfter: "example0After.png", imageBefore: "example0Before.png"),
            
            ExampleItemViewModel(title: "Body", description: "Breast size", imageAfter: "example1After.png", imageBefore: "example1Before.png"),
            
            ExampleItemViewModel(title: "Face", description: "Remove pimples, smooth the skin", imageAfter: "example2After.png", imageBefore: "example2Before.png"),
            
            ExampleItemViewModel(title: "Body", description: "Add abs (six-pack abs)", imageAfter: "example3After.png", imageBefore: "example3Before.png"),
            
            ExampleItemViewModel(title: "Photo", description: "Remove people-objects (change suitcase to umbrella), put woman in the center", imageAfter: "example4After.png", imageBefore: "example4Before.png"),
            
            ExampleItemViewModel(title: "Body", description: "Slimmer waist, hips size, remove fat folds, arms width, legs width", imageAfter: "example5After.png", imageBefore: "example5Before.png"),

            ExampleItemViewModel(title: "Photo", description: "Color corection, change sky, align the horizon, individual retouch", imageAfter: "example6After.png", imageBefore: "example6Before.png")
        ]
    }
    
    func casheAllImages() {
        examplesItems.forEach { item in
            self.imageCasher.casheImage(Constants.exampleBaseURL + item.imageAfter)
            self.imageCasher.casheImage(Constants.exampleBaseURL + item.imageBefore)
        }
    }
}

final class ImageCasher {
    func casheImage(_ string: String) {
        guard let url = URL(string: string) else { return }
        KingfisherManager.shared.retrieveImage(with: url, options: nil, completionHandler: nil)
    }
}
