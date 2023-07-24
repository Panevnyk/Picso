//
//  SUTextField.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 11.11.2020.
//

import UIKit
import RxSwift
import RxCocoa

public enum AlertPosition {
    case left
    case right
}

public enum ShowStyleMode {
    case disable
    case validated
    case alert
}

public enum ATextFieldConfig {
    case name
    case email
    case password
    case number
    case phoneNumber
}

public class AUIKitTextField: UITextField {
    /// Insets for text in textField
    var padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let origin = super.editingRect(forBounds: bounds)

        return origin.inset(by: padding)
    }

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        let origin = super.textRect(forBounds: bounds)

        return origin.inset(by: padding)
    }
}

public class ASUTextField: ABaseCustomView {
    /// UI
    public let textField = AUIKitTextField()
    public let checkBoxView = ACheckBoxView(frame: .init(origin: CGPoint.zero, size: .init(width: 24, height: 24)))

    public var minRightDistance: CGFloat = 0
    public var maxRightDistance: CGFloat = 39

    private var backgroundView = UIView()

    private lazy var alertLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.kDeclinedStatusRed
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.alpha = 0.0

        return label
    }()

    // checkbox traling constraint
    private (set) var checkBoxTralingCnstr: NSLayoutConstraint?

    /// API
    public var placeholder: String? {
        set {
            if let newPlaceholder = newValue {
                let attrPlaceholder = NSAttributedString(string: newPlaceholder,
                                                         attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular),
                                                                      .foregroundColor: UIColor.kTextMiddleGray])
                textField.attributedPlaceholder = attrPlaceholder
            } else {
                textField.attributedPlaceholder = nil
            }
        }
        get {
            return textField.attributedPlaceholder?.string
        }
    }

    public var config: ATextFieldConfig = .email {
        didSet {
            changeTextFieldConfig(config)
        }
    }
    
    public var validator: ValidatorProtocol = EmailValidator()
    
    public var validationResult: Observable<ValidationResult> {
        return textField.rx.text
            .map { $0 ?? "" }
            .map { [unowned self] value in self.validator.validate(value) }
    }

    public var styleMode: ShowStyleMode = .disable {
        willSet {
            if newValue != styleMode {
                changeStyleTo(newValue)
            }
        }
    }

    @available(*, deprecated, message: "Use validationResult instead")
    public var validationResultObservable: BehaviorRelay<ValidationResult> =
        BehaviorRelay<ValidationResult>(value: .noResult)
    public let disposeBag = DisposeBag()

    public func validateBy(validationResult: ValidationResult) {
        switch validationResult {
        case .success:
            styleMode = .validated
            alertText = nil
        case .noResult:
            styleMode = .disable
            alertText = nil
        case .error(let errorText):
            styleMode = .alert
            alertText = errorText
        }
    }

    public var text: String? {
        get {
            return textField.text
        }
        set(newText) {
            textField.text = newText
        }
    }

    public var alertText: String? {
        didSet {
            if alertLabel.superview == nil {
                addSubview(alertLabel)
                self.addConstraintForBottomView(view: alertLabel, bottom: 0, leading: 0, traling: 0, height: 18)

                self.layoutIfNeeded()
            }

            self.alertLabel.text = alertText
        }
    }

    public func moveAlertTo(_ alertPos: AlertPosition) {
        switch alertPos {
        case .right:
            alertLabel.textAlignment = .right
        case .left:
            alertLabel.textAlignment = .left
        }
    }

    public func isEnable(_ isEnabled: Bool) {
        textField.isEnabled = isEnabled
        self.alpha = isEnabled ? 1.0 : 0.6
    }

    public var textFieldPadding: UIEdgeInsets {
        get {
            return textField.padding
        }
        set {
            textField.padding = newValue
        }
    }

    public var isSecureTextEntry: Bool {
        get {
            return textField.isSecureTextEntry
        }
        set {
            textField.isSecureTextEntry = newValue
        }
    }

    /// Initializations
    public override func initialize() {
        self.backgroundColor = .white
        self.layer.masksToBounds = false
        self.textField.tintColor = UIColor.kTextDarkGray

        /// background view
        backgroundView.backgroundColor = UIColor.kInputBackgroundGrey
        backgroundView.layer.cornerRadius = 6
        backgroundView.layer.masksToBounds = true
        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            backgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            backgroundView.heightAnchor.constraint(equalToConstant: 44)
        ])

        /// checkBoxView
        addSubview(checkBoxView)
        checkBoxView.translatesAutoresizingMaskIntoConstraints = false
        let checkBoxTralingCnstr = checkBoxView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -15)
        self.checkBoxTralingCnstr = checkBoxTralingCnstr

        NSLayoutConstraint.activate([
            checkBoxTralingCnstr,
            checkBoxView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 10),
            checkBoxView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -10),
            checkBoxView.heightAnchor.constraint(equalToConstant: 24),
            checkBoxView.widthAnchor.constraint(equalToConstant: 24)
        ])

        /// textfield
        addSubview(textField)
        textField.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textField.textColor = UIColor.kTextDarkGray

        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            textField.heightAnchor.constraint(equalToConstant: 44)
        ])

        /// add action for textfield
        self.textField.addTarget(self, action: #selector(beginEditing(_:)), for: .editingDidBegin)
        self.textField.addTarget(self, action: #selector(finishEditing(_:)), for: .editingDidEnd)
        self.textField.addTarget(self, action: #selector(changeEditing(_:)), for: .editingChanged)
        self.textField.addTarget(self, action: #selector(returnEditing(_:)), for: .editingDidEndOnExit)

        /// Validate result
        validationResult
            .subscribe(onNext: { [unowned self] (value) in
                self.validateBy(validationResult: value)
            })
            .disposed(by: disposeBag)
    }

    /// change alert mode
    private func changeStyleTo(_ styleMode: ShowStyleMode) {
        let alertTextColor: UIColor
        let tintColor: UIColor
        let alertAlpha: CGFloat
        let isChecked: Bool

        switch styleMode {
        case .alert:
            tintColor = UIColor.kDeclinedStatusRed
            alertTextColor = UIColor.kDeclinedStatusRed
            alertAlpha = 1.0
            isChecked = false
        case .disable:
            tintColor = UIColor.kTextDarkGray
            alertTextColor = UIColor.kTextDarkGray
            alertAlpha = 0.0
            isChecked = false
        case .validated:
            tintColor = UIColor.kPurple
            alertTextColor = UIColor.kPurple
            alertAlpha = 1.0
            isChecked = true
        }

        checkBoxView.setChecked(isChecked, animated: true)
        textField.padding.right = isChecked ? maxRightDistance : minRightDistance

        UIView.animate(withDuration: 0.15) {
            self.tintColor = tintColor
            self.textField.tintColor = tintColor
            self.alertLabel.textColor = alertTextColor
            self.alertLabel.alpha = alertAlpha
        }
    }
}

// MARK: - Target Actions
public extension ASUTextField {
    @objc func beginEditing(_ textField: UITextField) {

    }

    @objc func changeEditing(_ textField: UITextField) {

    }

    @objc func finishEditing(_ textField: UITextField) {

    }

    @objc func returnEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}

// MARK: - style
extension ASUTextField {
    func changeTextFieldConfig(_ config: ATextFieldConfig) {
        switch config {
        case .name:
            nameConfig()
        case .email:
            emailConfig()
        case .password:
            passwordConfig()
        case .number:
            numberConfig()
        case .phoneNumber:
            phoneNumberConfig()
        }
    }

    func nameConfig() {
        textField.keyboardType = .namePhonePad
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
    }

    func emailConfig() {
        turnOffAutoTextField()
        textField.keyboardType = .emailAddress
    }

    func passwordConfig() {
        turnOffAutoTextField()
        isSecureTextEntry = true
    }

    func numberConfig() {
        turnOffAutoTextField()
        textField.keyboardType = .numberPad
    }

    func phoneNumberConfig() {
        turnOffAutoTextField()
        textField.keyboardType = .phonePad
    }

    func turnOffAutoTextField() {
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
    }
}

