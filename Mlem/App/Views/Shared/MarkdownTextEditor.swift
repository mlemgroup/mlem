//
//  MarkdownTextEditor.swift
//  Mlem
//
//  Created by Sjmarf on 14/07/2024.
//

import SwiftUI

struct MarkdownTextEditor<Content: View>: UIViewRepresentable {
    @Binding var text: String
    let content: Content
    let proxy: MarkdownTextEditorProxy
    
    init(text: Binding<String>, proxy: MarkdownTextEditorProxy, @ViewBuilder content: () -> Content) {
        self._text = text
        self.proxy = proxy
        self.content = content()
    }
 
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
 
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = .preferredFont(forTextStyle: .body)
        textView.textContainerInset = .init(top: 0, left: 10, bottom: 10, right: 10)
        textView.delegate = context.coordinator
        textView.setContentHuggingPriority(.defaultLow, for: .vertical)
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let contentController = UIHostingController(rootView: content)
        let contentView = contentController.view!
        
        let inputView = UIInputView(frame: CGRect(x: 0, y: 0, width: 0, height: 36), inputViewStyle: .keyboard)
        inputView.addSubview(contentController.view)
        inputView.inputViewController?.addChild(contentController)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor.clear
        contentView.rightAnchor.constraint(equalTo: inputView.rightAnchor).isActive = true
        contentView.leftAnchor.constraint(equalTo: inputView.leftAnchor).isActive = true
        textView.inputAccessoryView = inputView
        inputView.sizeToFit()
        contentController.view.sizeToFit()
        
        // Makes the text wrap instead of going off-screen
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        if #available(iOS 17.4, *) {
            textView.transfersVerticalScrollingToParent = true
            textView.transfersHorizontalScrollingToParent = true
        } else {
            // Fallback on earlier versions
        }
        textView.isScrollEnabled = false
        
        proxy.undoManager = textView.undoManager
    
        return textView
    }
 
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
 
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: MarkdownTextEditor
 
        init(_ uiTextView: MarkdownTextEditor) {
            self.parent = uiTextView
        }
 
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}

class MarkdownTextEditorProxy {
    fileprivate var undoManager: UndoManager?
    
    func undo() {
        undoManager?.undo()
    }
    
    func redo() {
        undoManager?.redo()
    }
}
