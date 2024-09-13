//
//  MarkdownTextEditor.swift
//  Mlem
//
//  Created by Sjmarf on 14/07/2024.
//

import SwiftUI

struct MarkdownTextEditor<Content: View>: UIViewRepresentable {
    let content: Content
    let prompt: String
    let textView: UITextView
    let placeholderLabel: UILabel = .init()
    let font: UIFont
    
    let onChange: (String) -> Void
    
    init(
        // A binding isn't used here because it creates a view update every time
        // the text changes. This created a noticable lag between pressing a key
        // and it appearing on the screen. Instead, parent views can access the
        // text directly from the `textView` and/or perform logic using the below
        // `onChange` callback.
        onChange: @escaping (String) -> Void,
        prompt: LocalizedStringResource,
        textView: UITextView,
        font: UIFont = .preferredFont(forTextStyle: .body),
        @ViewBuilder content: () -> Content
    ) {
        self.prompt = String(localized: prompt)
        self.textView = textView
        self.content = content()
        self.font = font
        self.onChange = onChange
    }
 
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
 
    func makeUIView(context: Context) -> UITextView {
        textView.font = font
        textView.textContainerInset = .init(
            top: Constants.main.halfSpacing,
            left: Constants.main.standardSpacing,
            bottom: Constants.main.standardSpacing,
            right: Constants.main.standardSpacing
        )
        textView.delegate = context.coordinator
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textView.sizeToFit()
        textView.becomeFirstResponder()
        
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
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        // Makes the text wrap instead of going off-screen
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        textView.isScrollEnabled = false
             
        return textView
    }
 
    func updateUIView(_ textView: UITextView, context: Context) {
        textView.sizeToFit()
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView textView: UITextView, context: Context) -> CGSize? {
        let dimensions = proposal.replacingUnspecifiedDimensions(
            by: .init(
                width: 0,
                height: CGFloat.greatestFiniteMagnitude
            )
        )
        textView.sizeToFit()

        // `textView.contentSize` varies slightly on one line depending on which characters are typed.
        // To avoid this we get the line height from the font and round `contentSize` to the nearest line.

        // "15" seems to be constant no matter the font size
        let lineHeight = font.lineHeight + font.leading
        let calculatedHeight = 15 + round((textView.contentSize.height - 15) / lineHeight) * lineHeight
          
        // The "+ 1" fixes a bug in which there wouldn't be enough room to render a second line when using
        // certain fonts (specifically, `.title2`). This would cause lines to sometimes not render. This
        // is probably a result of floating point error or something like that. This bug isn't a result
        // of the rounding logic above; it still happens when simply using `contentSize`.
        return .init(
            width: dimensions.width,
            height: calculatedHeight + 1
        )
    }
 
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: MarkdownTextEditor
 
        init(_ textView: MarkdownTextEditor) {
            self.parent = textView
        }
 
        func textViewDidChange(_ textView: UITextView) {
            parent.onChange(textView.text)
            parent.placeholderLabel.isHidden = !textView.text.isEmpty
            textView.sizeToFit()
        }
    }
}
