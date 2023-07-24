//
//  ATextField.swift
//  RetouchCommon
//
//  Created by Vladyslav Panevnyk on 14.07.2023.
//

import SwiftUI
import RxSwift
import RxCocoa

public struct ATextField: UIViewRepresentable {
    public typealias UIViewType = ASUTextField
    
    private let viewModel: ATextFieldViewModel
    
    private let disposeBag = DisposeBag()
    
    public init(
        viewModel: ATextFieldViewModel
    ) {
        self.viewModel = viewModel
    }
  
    public func makeUIView(context: Context) -> ASUTextField {
        let view = ASUTextField()
        view.placeholder = viewModel.placeholder
        view.config = viewModel.config
        view.validator = viewModel.validator
        
        view.textField.rx.text
            .map { $0 ?? "" }
            .subscribe { value in
                self.viewModel.text = value
            }
            .disposed(by: disposeBag)
        
        view.validationResult
            .subscribe { value in
                self.viewModel.validationResult = value
            }
            .disposed(by: disposeBag)
        
        return view
    }
    
    public func updateUIView(_ uiView: ASUTextField, context: Context) {}
}

struct ATextField_Previews: PreviewProvider {
    static var previews: some View {
        ATextField(
            viewModel: ATextFieldViewModel(
                placeholder: "Email",
                config: .email,
                validator: EmailValidator()
            )
        )
    }
}
