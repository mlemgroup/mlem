//
//  Reply Editor.swift
//  Mlem
//
//  Created by David Bureš on 20.05.2023.
//

import SwiftUI

struct ReplyEditor: UIViewRepresentable
{
    
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextField
    {
        let textField: UITextField = UITextField()
        
        textField.becomeFirstResponder()
        
        textField.delegate = context.coordinator
        
        return textField
    }

    func updateUIView(_ textField: UITextField, context: Context)
    {
        textField.text = text
        
        if let selectedRange = textField.selectedTextRange
        {
            let cursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
            print("Cursor position: \(cursorPosition)")
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate
    {
        @Binding var text: String
        
        init(text: Binding<String>) {
            self._text = text
        }
    }

    typealias UIViewType = UITextField
}
