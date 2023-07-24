//
//  UIApplication+TargetForPresentation.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 11.11.2020.
//

import UIKit

extension UIApplication {
    class var presentationViewController: UIViewController? {
        var targetForPresent = UIApplication.keyWindow?.rootViewController

        while targetForPresent?.presentedViewController != nil {
            targetForPresent = targetForPresent?.presentedViewController
        }

        return targetForPresent
    }
}
