//
//  LoadableImage.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk  on 28.07.2023.
//

import SwiftUI
import UIKit

public struct LoadableImage: View {
    private let imageUrl: String?
    private let placeholder: (name: String, bundle: Bundle)?
    private let contentMode: ContentMode
    private let targetSize: CGSize?
    private var action: (() -> Void)?
    
    private var url: URL? {
        if let imageUrl = imageUrl {
            return URL(string: imageUrl)
        }
        
        return nil
    }
    
    public init(
        imageUrl: String?,
        placeholder: (name: String, bundle: Bundle)? = nil,
        contentMode: ContentMode = .fill,
        targetSize: CGSize? = nil,
        action: (() -> Void)? = nil
    ) {
        self.imageUrl = imageUrl
        self.placeholder = placeholder
        self.contentMode = contentMode
        self.targetSize = targetSize
        self.action = action
    }
    
    public var body: some View {
        if let action = action {
            Button(action: action) {
                asyncTargetedSizeImage
            }
        } else {
            asyncTargetedSizeImage
        }
    }
    
    private var asyncTargetedSizeImage: some View {
        ZStack {
            if let targetSize = targetSize {
                asyncImage
                    .frame(width: targetSize.width, height: targetSize.height)
            } else {
                asyncImage
            }
        }
    }
     
    private var asyncImage: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } placeholder: {
            if let placeholder = placeholder {
                Image(placeholder.name, bundle: placeholder.bundle)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            }
        }
    }
}

struct LoadableImage_Previews: PreviewProvider {
    static var previews: some View {
        LoadableImage(
            imageUrl: "Mock",
            placeholder: (name: "Placeholder", bundle: .common),
            action: nil
        )
    }
}
