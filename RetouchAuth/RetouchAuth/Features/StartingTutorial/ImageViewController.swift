//
//  ImageViewController.swift
//  RetouchAuth
//
//  Created by Vladyslav Panevnyk on 20.03.2021.
//

import UIKit

public final class ImageViewController: UIViewController {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var bgImageView: UIImageView!

    public var imageString = ""
    public var bgImageString = ""

    public override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = UIImage(named: imageString, in: Bundle.common, compatibleWith: nil)
        bgImageView.image = UIImage(named: bgImageString, in: Bundle.common, compatibleWith: nil)
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
}
