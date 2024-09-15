//
//  MarkdownEditorToolbarView.swift
//  Mlem
//
//  Created by Sjmarf on 15/07/2024.
//

import MlemMiddleware
import SwiftUI

struct MarkdownEditorToolbarView: View {
    enum AvailableActions {
        case all, inlineOnly
    }
    
    @Environment(NavigationLayer.self) var navigation
    
    let actions: AvailableActions
    let textView: UITextView
    let imageUploadApi: ApiClient?
    let uploadHistory: ImageUploadHistoryManager
    
    @State var imageManager: ImageUploadManager = .init()
    
    init(
        showing actions: AvailableActions = .all,
        textView: UITextView,
        uploadHistory: ImageUploadHistoryManager = .init(),
        imageUploadApi: ApiClient?
    ) {
        self.actions = actions
        self.textView = textView
        self.uploadHistory = uploadHistory
        self.imageUploadApi = imageUploadApi
    }
    
    @ViewBuilder
    var body: some View {
        Group {
            switch imageManager.state {
            case let .uploading(progress):
                if progress == 1 {
                    HStack {
                        Text("Uploading...")
                        ProgressView()
                            .tint(Palette.main.secondary)
                    }
                } else {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .padding(.horizontal)
                }
            default:
                content
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 32, alignment: .bottom)
        .onChange(of: imageManager.state) {
            switch imageManager.state {
            case let .done(upload):
                if let range = textView.selectedTextRange {
                    textView.replace(range, withText: "![](\(upload.url.absoluteString))")
                    uploadHistory.add(upload)
                    imageManager.clear()
                }
            default:
                break
            }
        }
    }
    
    var content: some View {
        ScrollView(.horizontal) {
            Spacer()
            HStack(spacing: 16) {
                // iPad already shows these buttons
                if !UIDevice.isPad {
                    Button("Undo", systemImage: "arrow.uturn.backward") {
                        textView.undoManager?.undo()
                    }
                    Button("Redo", systemImage: "arrow.uturn.forward") {
                        textView.undoManager?.redo()
                    }
                    SwiftUI.Divider()
                }
                Button("Bold", systemImage: Icons.bold) {
                    textView.wrapSelectionWithDelimiters("**")
                }
                Button("Italic", systemImage: Icons.italic) {
                    textView.wrapSelectionWithDelimiters("_")
                }
                Button("Strikethrough", systemImage: Icons.strikethrough) {
                    textView.wrapSelectionWithDelimiters("~~")
                }
                Button("Superscript", systemImage: Icons.superscript) {
                    textView.wrapSelectionWithDelimiters("^")
                }
                Button("Subscript", systemImage: Icons.subscript) {
                    textView.wrapSelectionWithDelimiters("~")
                }
                Button("Code", systemImage: Icons.inlineCode) {
                    textView.wrapSelectionWithDelimiters("`")
                }
                if actions == .all {
                    SwiftUI.Divider()
                    Menu("Heading", systemImage: Icons.heading) {
                        ForEach(1 ..< 7) { level in
                            Button("Heading \(level)") {
                                textView.toggleHeadingAtCursor(level: level)
                            }
                        }
                    }
                    Button("Quote", systemImage: Icons.quote) {
                        textView.toggleQuoteAtCursor()
                    }
                    if let imageUploadApi {
                        Menu("Image", systemImage: Icons.uploadImage) {
                            Button("Photo Library", systemImage: Icons.photo) {
                                navigation.showPhotosPicker(for: imageManager, api: imageUploadApi)
                            }
                            Button("Choose File", systemImage: "folder") {
                                navigation.showFilePicker(for: imageManager, api: imageUploadApi)
                            }
                            Button("Paste", systemImage: Icons.paste) {
                                Task { try await imageManager.pasteFromClipboard(api: imageUploadApi) }
                            }
                        }
                        .disabled(imageManager.state != .idle)
                    }
                    Button("Spoiler", systemImage: Icons.spoiler) {
                        textView.wrapSelectionWithSpoiler()
                    }
                }
            }
            .imageScale(.large)
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .labelStyle(.iconOnly)
            .padding(.horizontal)
            .padding(.bottom, 2)
        }
        .scrollIndicators(.hidden)
    }
}
