//
//  BeforeImage.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 21.04.2021.
//

public final class BeforeImage: Decodable {
    public var image: String

    // MARK: - Init
    public init(image: String) {
        self.image = image
    }
}
