//
//  BodyEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 04/03/2024.
//

import Dependencies
import Foundation
import SwiftUI
import SwiftUIIntrospect

class BodyEditorModel: ObservableObject {
    @Dependency(\.pictrsRepository) var pictrsRepository
    
    var uiTextView: UITextView?
    var attachedFiles: [PictrsFile] = .init()
    
    func deleteUnusedFiles(text: String) async {
        for file in attachedFiles where !text.contains(file.file) {
            await deleteFile(file: file)
        }
    }
    
    func deleteAllFiles() async {
        for file in attachedFiles {
            await deleteFile(file: file)
        }
    }
    
    private func deleteFile(file: PictrsFile) async {
        do {
            try await pictrsRepository.deleteImage(file: file)
            print("Deleted attachment \(file.file)")
        } catch {
            print("FAILED TO DELETE", error)
        }
    }
}

struct BodyEditorView: View {
    @Binding var text: String
    let prompt: String
    
    @ObservedObject var bodyEditorModel: BodyEditorModel
    @ObservedObject var attachmentModel: LinkAttachmentModel
    
    var body: some View {
        TextField(
            prompt,
            text: $text,
            axis: .vertical
        )
        .disabled(attachmentModel.imageModel?.state != nil)
        .opacity(attachmentModel.imageModel?.state == nil ? 1 : 0.5)
        .introspect(.textField(axis: .vertical), on: .iOS(.v16, .v17)) { uiTextView in
            bodyEditorModel.uiTextView = uiTextView
        }
        .onChange(of: attachmentModel.imageModel?.state) { newValue in
            switch newValue {
            case let .uploaded(file: file):
                if let file {
                    let cursorPosition = cursorPosition
                    let index = text.index(text.startIndex, offsetBy: cursorPosition)
                    text = String(text[..<index] + "![](\(attachmentModel.url))" + text[index...])
                    bodyEditorModel.attachedFiles.append(file)
                    attachmentModel.url = ""
                    attachmentModel.imageModel = nil
                }
            default:
                break
            }
        }
    }
    
    var cursorPosition: Int {
        if let textView = bodyEditorModel.uiTextView {
            if let range = textView.selectedTextRange {
                let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: range.start)
                return cursorPosition
            }
        }
        return text.count - 1
    }
}
