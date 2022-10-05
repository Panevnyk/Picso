//
//  ImageSaver.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 11.03.2021.
//

import UIKit

public class ImageSaver: NSObject {
    private var completion: ((_ isSuccess: Bool) -> Void)?

    public func writeToPhotoAlbum(imageURLString: String, completion: ((_ isSuccess: Bool) -> Void)?) {
        guard let imageURL = URL(string: imageURLString) else {
            AlertHelper.show(title: "Fail to create URL", message: nil)
            completion?(false)
            return
        }
        writeToPhotoAlbum(imageURL: imageURL, completion: completion)
    }

    public func writeToPhotoAlbum(imageURL: URL, completion: ((_ isSuccess: Bool) -> Void)?) {
        downloadImage(from: imageURL) { [weak self] image in
            guard let self = self, let image = image else {
                AlertHelper.show(title: "Fail to download image", message: nil)
                completion?(false)
                return
            }
            self.writeToPhotoAlbum(image: image, completion: completion)
        }
    }

    public func writeToPhotoAlbum(image: UIImage, completion: ((_ isSuccess: Bool) -> Void)?) {
        self.completion = completion
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }

    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            AlertHelper.show(title: "ImageSaver saveError: \(String(describing: error))", message: nil)
        }
        completion?(error == nil)
        completion = nil
    }

    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    private func downloadImage(from url: URL, completion: ((_ image: UIImage?) -> ())?) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else {
                completion?(nil)
                return
            }
            DispatchQueue.main.async() {
                completion?(UIImage(data: data))
            }
        }
    }
}
