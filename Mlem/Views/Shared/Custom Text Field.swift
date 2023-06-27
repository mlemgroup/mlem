//
//  Custom Text Field.swift
//  Mlem
//
//  Created by David Bureš on 20.05.2023.
//

import SwiftUI

struct CustomTextField: UIViewRepresentable {

    @State var placeholder: String
    @Binding var text: String

    func makeUIView(context: Context) -> UITextField {
        let textField: UITextField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect

        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        textField.isUserInteractionEnabled = false

        textField.delegate = context.coordinator

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            self._text = text
        }
    }

    typealias UIViewType = UITextField
}
