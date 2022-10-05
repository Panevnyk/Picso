//
//  UseAgreementsLabel.swift
//  RetouchAuth
//
//  Created by Panevnyk Vlad on 15.06.2021.
//

import UIKit

public protocol UseAgreementsDelegate: AnyObject {
    func didSelectPrivacyPolicy()
    func didSelectTermsOfUse()
}

@IBDesignable
public final class UseAgreementsLabel: UITextView, UITextViewDelegate {
    private static let privacyPolicyURL = "http://www.google.com"
    private static let termsOfUseURL = "http://www.apple.com"
    
    @IBInspectable var isLightStyle: Bool {
        get { return false }
        set { updateText(isLightStyle: newValue) }
    }
    
    public weak var useAgreementsDelegate: UseAgreementsDelegate?
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        isSelectable = true
        isEditable = false
        text = nil
        backgroundColor = .clear
        textAlignment = .center
        delegate = self
    }
    
    private func updateText(isLightStyle: Bool) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let simpleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: isLightStyle ? UIColor.white : UIColor.kTextMiddleGray,
            .paragraphStyle: paragraphStyle,
            .font: UIFont.kDescriptionText]
        let privacyPolicyAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: isLightStyle ? UIColor.white : UIColor.kPurple,
            .font: UIFont.kDescriptionMediumText,
            .paragraphStyle: paragraphStyle,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .link: URL(string: UseAgreementsLabel.privacyPolicyURL)!]
        let termsOfUseAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: isLightStyle ? UIColor.white : UIColor.kPurple,
            .font: UIFont.kDescriptionMediumText,
            .paragraphStyle: paragraphStyle,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .link: URL(string: UseAgreementsLabel.termsOfUseURL)!]

        let firstString = NSMutableAttributedString(string: "By continuing to use RetouchYou App, you agree to our\n", attributes: simpleAttributes)
        let secondString = NSAttributedString(string: "Privacy Policy", attributes: privacyPolicyAttributes)
        let thirdString = NSAttributedString(string: " and ", attributes: simpleAttributes)
        let forthString = NSAttributedString(string: "Terms of Use", attributes: termsOfUseAttributes)

        firstString.append(secondString)
        firstString.append(thirdString)
        firstString.append(forthString)
        
        self.tintColor = isLightStyle ? UIColor.white : UIColor.kPurple
        self.attributedText = firstString
    }
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString == UseAgreementsLabel.privacyPolicyURL {
            useAgreementsDelegate?.didSelectPrivacyPolicy()
        }
        if URL.absoluteString == UseAgreementsLabel.termsOfUseURL {
            useAgreementsDelegate?.didSelectTermsOfUse()
        }
        return false
    }
}
