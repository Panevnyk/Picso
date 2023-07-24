//
//  SUPasswordTextField.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 11.11.2020.
//

import UIKit

public protocol ASUPasswordTextFieldDelegate: AnyObject {
    func didTapSecureButton(isSecureTextEntry: Bool)
}

public class ASUPasswordTextField: ASUTextField {
    /// UI
    public let rightSecureButton = UIButton(type: .custom)

    /// Delegate
    public weak var delegate: ASUPasswordTextFieldDelegate?

    /// Initialize
    public override func initialize() {
        super.initialize()

        if #available(iOS 11.0, *) {
            textField.textContentType = UITextContentType.password
        }

        config = .password

        addRightArrow()
        minRightDistance = 39
        maxRightDistance = 78
    }

    private func addRightArrow() {
        /// change placeholder frame
        textFieldPadding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: minRightDistance)

        /// right arrow
        self.addSubview(rightSecureButton)
        self.addRightConstraint(view: rightSecureButton, top: 0, traling: -5, width: 44, height: 44)
        rightSecureButton.setImage(UIImage(named: "icEyeClosePurple", in: Bundle.common, compatibleWith: nil), for: .normal)
        rightSecureButton.addTarget(self, action: #selector(tapSecureButton), for: .touchUpInside)

        checkBoxTralingCnstr?.constant = -54
        layoutIfNeeded()
    }

    /// API
    public func setSecureTextEntry(_ isSecureTextEntry: Bool) {
        self.isSecureTextEntry = isSecureTextEntry
        let eyeImgString = isSecureTextEntry ? "icEyeClosePurple" : "icEyeOpenPurple"
        let eyeImg = UIImage(named: eyeImgString, in: Bundle.common, compatibleWith: nil)
        rightSecureButton.setImage(eyeImg, for: .normal)
    }

    public override var textInputContextIdentifier: String? {
        return "com.auth.passwordTextInputContextIdentifier"
    }
}

// MARK: - Actions
private extension ASUPasswordTextField {
    @objc func tapSecureButton() {
        setSecureTextEntry(!isSecureTextEntry)
        delegate?.didTapSecureButton(isSecureTextEntry: isSecureTextEntry)
    }
}
