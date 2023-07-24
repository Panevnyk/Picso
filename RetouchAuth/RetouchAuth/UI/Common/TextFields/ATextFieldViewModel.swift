//
//  ATextFieldViewModel.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 14.07.2023.
//

import Combine

public class ATextFieldViewModel {
    @Published var text: String? = nil
    public var textPublisher: Published<String?>.Publisher?
    { $text }
    
    @Published var validationResult: ValidationResult = .noResult
    public var validationResultPublisher: Published<ValidationResult>.Publisher
    { $validationResult }
    
    let placeholder: String
    let config: ATextFieldConfig
    let validator: ValidatorProtocol
    
    public init(
        placeholder: String,
        config: ATextFieldConfig,
        validator: ValidatorProtocol
    ) {
        self.placeholder = placeholder
        self.config = config
        self.validator = validator
    }
}
