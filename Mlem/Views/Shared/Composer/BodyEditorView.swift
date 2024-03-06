//
//  BodyEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 04/03/2024.
//

import Foundation
import SwiftUI
import SwiftUIIntrospect

private class BodyEditorModel {
    var uiTextView: UITextView?
}

struct BodyEditorView: View {
    @Binding var text: String
    let prompt: String
    
    @StateObject var attachmentModel: LinkAttachmentModel = .init(url: "")
    private let model = BodyEditorModel()
    
    @State var attachedFiles: [PictrsFile] = .init()
    
    var body: some View {
        LinkAttachmentView(model: attachmentModel) {
            TextField(
                prompt,
                text: $text,
                axis: .vertical
            )
            .disabled(attachmentModel.imageModel?.state != nil)
            .introspect(.textField(axis: .vertical), on: .iOS(.v16, .v17)) { uiTextView in
                model.uiTextView = uiTextView
            }
            .onChange(of: attachmentModel.imageModel?.state) { newValue in
                switch newValue {
                case let .uploaded(file: file):
                    if let file {
                        let index = text.index(text.startIndex, offsetBy: cursorPosition)
                        text = String(text[..<index] + "![](\(attachmentModel.url))" + text[index...])
                        attachedFiles.append(file)
                        attachmentModel.url = ""
                        attachmentModel.imageModel = nil
                    }
                default:
                    break
                }
            }
            .toolbar {
                ToolbarItem {
                    LinkUploadOptionsView(model: attachmentModel) {
                        Label("Attach Image or Link", systemImage: Icons.attachment)
                    }
                }
            }
        }
    }
    
    var cursorPosition: Int {
        if let textView = model.uiTextView {
            if let range = textView.selectedTextRange {
                let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: range.start)
                return cursorPosition
            }
        }
        return text.count - 1
    }
}

extension View {
    // It has to be done this way because of an iOS 17 bug in which keyboard toolbars don't behave properly in a sheet when placed inside of a navigation stack - it has to be placed outside.
}
