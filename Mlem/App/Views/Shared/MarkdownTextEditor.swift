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
    let prompt: String
    let textView: UITextView
    let placeholderLabel: UILabel = .init()
    
    init(
        text: Binding<String>,
        prompt: String,
        textView: UITextView,
        @ViewBuilder content: () -> Content
    ) {
        self._text = text
        self.prompt = prompt
        self.textView = textView
        self.content = content()
    }
 
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
 
    func makeUIView(context: Context) -> UITextView {
        textView.font = .preferredFont(forTextStyle: .body)
        textView.textContainerInset = .init(
            top: AppConstants.halfSpacing,
            left: AppConstants.standardSpacing,
            bottom: AppConstants.standardSpacing,
            right: AppConstants.standardSpacing
        )
        textView.delegate = context.coordinator
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textView.becomeFirstResponder()
        textView.text = text
        textView.sizeToFit()
        
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
    
        placeholderLabel.text = prompt
        placeholderLabel.font = textView.font
        placeholderLabel.sizeToFit()
        textView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 15, y: 6)
        placeholderLabel.textColor = UIColor(Palette.main.tertiary)
        placeholderLabel.isHidden = !text.isEmpty
        
        // Makes the text wrap instead of going off-screen
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        textView.isScrollEnabled = false
        
        return textView
    }
 
    func updateUIView(_ textView: UITextView, context: Context) {
        textView.sizeToFit()
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        let dimensions = proposal.replacingUnspecifiedDimensions(
            by: .init(
                width: 0,
                height: CGFloat.greatestFiniteMagnitude
            )
        )
                
        let calculatedHeight = uiView.contentSize.height
        
        return .init(
            width: dimensions.width,
            height: calculatedHeight
        )
    }
 
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: MarkdownTextEditor
 
        init(_ uiTextView: MarkdownTextEditor) {
            self.parent = uiTextView
        }
 
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.placeholderLabel.isHidden = !textView.text.isEmpty
        }
    }
}
