//
//  UIImageView+LoadByURL.swift
//  RetouchCommon
//
//  Created by Panevnyk Vlad on 23.01.2022.
//

import UIKit
import Kingfisher

extension UIImageView {
    public func setImage(with url: URL, activityIndicatorStyle: UIActivityIndicatorView.Style? = .medium) {
        if let activityIndicatorStyle = activityIndicatorStyle {
            let activityInd = UIActivityIndicatorView(style: activityIndicatorStyle)
            activityInd.center = CGPoint(x: frame.size.width / 2,
                                         y: frame.size.height / 2)
            addSubview(activityInd)
            activityInd.startAnimating()
            kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil) { _ in
                activityInd.stopAnimating()
            }
        } else {
            kf.setImage(with: url)
        }
    }
}
