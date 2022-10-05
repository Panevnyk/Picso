//
//  PHPhotoLibraryPresenter.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 17.02.2021.
//

import UIKit
import Photos

public protocol PHPhotoLibraryPresenterDelegate: AnyObject {
    func didSelectPhoto(image: UIImage)
    func dismiss(picker: UIImagePickerController)
}

public protocol PHPhotoLibraryPresenterProtocol {
    func requestPhotosAuthorization(completion: ((_ isAuthorized: Bool) -> Void)?)
    func presentNotAccessToPhotoLibraryAlert()
}

public final class PHPhotoLibraryPresenter: NSObject, PHPhotoLibraryPresenterProtocol {
    public override init() {}

    public weak var delegate: PHPhotoLibraryPresenterDelegate?

    public func requestPhotosAuthorization(completion: ((_ isAuthorized: Bool) -> Void)?) {
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                DispatchQueue.main.async {
                    completion?(status == .authorized)
                }
            })
        } else if photos == .authorized {
            DispatchQueue.main.async {
                completion?(true)
            }
        } else {
            DispatchQueue.main.async {
                completion?(false)
            }
        }
    }

    public func presentNotAccessToPhotoLibraryAlert() {
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil)
        let goToSettingsAction = UIAlertAction(
            title: "Open Settings",
            style: .default,
            handler: { _ in
                SettingsHelper.openSettings()
            })
        AlertHelper.show(title: "No access to photo library",
                         message: "To enable access please go to your device setting",
                         alertActions: [cancelAction, goToSettingsAction])
    }
}

