//
//  MarkdownEditorToolbarView.swift
//  Mlem
//
//  Created by Sjmarf on 15/07/2024.
//

import MlemMiddleware
import SwiftUI

// These can't be passed directly to the constructor - SwiftUI doesn't pick up on
// view updates, because of the way this view is nested inside the keyboard using UIKit.
@Observable
class MarkdownEditorToolbarModel {
    var imageUploadApi: ApiClient?
}

struct MarkdownEditorToolbarView: View {
    enum AvailableActions {
        case all, inlineOnly
    }
    
    @Environment(NavigationLayer.self) var navigation
    
    let actions: AvailableActions
    let textView: UITextView
    
    let model: MarkdownEditorToolbarModel
    let uploadHistory: ImageUploadHistoryManager
    
    @State var imageManager: ImageUploadManager = .init()
    @ScaledMetric(relativeTo: .body) var toolbarHeight: CGFloat = 32
    
    @State var leftFade: Bool
    @State var rightFade: Bool
    
    init(
        showing actions: AvailableActions = .all,
        textView: UITextView,
        uploadHistory: ImageUploadHistoryManager = .init(),
        model: MarkdownEditorToolbarModel
    ) {
        self.actions = actions
        self.textView = textView
        self.uploadHistory = uploadHistory
        self.model = model
        
        self.leftFade = false
        if #available(iOS 18.0, *) {
            self.rightFade = true
        } else {
            self.rightFade = false
        }
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
                            .tint(.themedSecondary)
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
        .frame(height: toolbarHeight, alignment: .bottom)
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
                    .compatibilityOnScrollVisibilityChange { isVisible in
                        withAnimation {
                            leftFade = !isVisible
                        }
                    }
                    Button("Redo", systemImage: "arrow.uturn.forward") {
                        textView.undoManager?.redo()
                    }
                    SwiftUI.Divider()
                        .padding(.top, 2)
                }
                Button("Bold", icon: .markdown.bold) {
                    textView.wrapSelectionWithDelimiters("**")
                }
                .compatibilityOnScrollVisibilityChange { isVisible in
                    if UIDevice.isPad {
                        withAnimation {
                            leftFade = !isVisible
                        }
                    }
                }
                Button("Italic", icon: .markdown.italic) {
                    textView.wrapSelectionWithDelimiters("_")
                }
                Button("Strikethrough", icon: .markdown.strikethrough) {
                    textView.wrapSelectionWithDelimiters("~~")
                }
                Button("Superscript", icon: .markdown.superscript) {
                    textView.wrapSelectionWithDelimiters("^")
                }
                Button("Subscript", icon: .markdown.subscript) {
                    textView.wrapSelectionWithDelimiters("~")
                }
                Button("Code", icon: .markdown.inlineCode) {
                    textView.wrapSelectionWithDelimiters("`")
                }
                Button("Link", icon: .markdown.insertLink) {
                    textView.wrapSelectionWithLink()
                }
                if actions == .all {
                    SwiftUI.Divider()
                        .padding(.top, 2)
                    Menu("Heading", icon: .markdown.heading) {
                        ForEach(1 ..< 7) { level in
                            Button("Heading \(level)") {
                                textView.toggleHeadingAtCursor(level: level)
                            }
                        }
                    }
                    Button("Quote", icon: .markdown.quote) {
                        textView.toggleQuoteAtCursor()
                    }
                    if let imageUploadApi = model.imageUploadApi {
                        if imageUploadApi.supportsOrNil(.uploadImages) ?? true {
                            ImageUploadMenu(imageManager: imageManager, imageUploadApi: imageUploadApi) {
                                Label("Image", icon: .markdown.uploadImage)
                            }
                            .disabled(!imageUploadApi.contextIsFetched)
                        } else {
                            Button("Image", icon: .markdown.uploadImage) {
                                ToastModel.main.add(
                                    .basic("Unsupported", subtitle: "Uploading images on PieFed isn't supported yet.")
                                )
                            }
                        }
                    }
                    Button("Spoiler", icon: .markdown.spoiler) {
                        textView.wrapSelectionWithSpoiler()
                    }
                    Button("Code Block", icon: .markdown.codeBlock) {
                        textView.wrapSelectionWithCodeBlock()
                    }
                }
                SwiftUI.Divider()
                    .padding(.top, 2)
                Button("Community Link", icon: .lemmy.community) {
                    navigation.openSheet(.communityPicker { community in
                        textView.insertText(community.fullNameWithPrefix)
                    })
                }
                Button("User Link", icon: .lemmy.person) {
                    navigation.openSheet(.personPicker { person in
                        // lemmy-ui doesn't recognize the @user@example.com format, so we have to do this instead :(
                        // See this issue https://github.com/LemmyNet/lemmy-ui/issues/2579
                        textView.insertText("[\(person.fullNameWithPrefix)](\(person.actorId))")
                    })
                }
                Button("Instance Link", icon: .lemmy.instance) {
                    navigation.openSheet(.instancePicker { instance in
                        textView.insertText("[\(instance.host)](https://\(instance.host))")
                    })
                }
                .compatibilityOnScrollVisibilityChange { isVisible in
                    withAnimation {
                        rightFade = !isVisible
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
        .mask(
            HStack(spacing: 0) {
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(leftFade ? 0 : 1), Color.black]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 100)
                
                Rectangle().fill(Color.black)
                
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.black.opacity(rightFade ? 0 : 1)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 100)
            }
        )
        .task(id: model.imageUploadApi) {
            do {
                try await model.imageUploadApi?.ensureContextPresence()
            } catch {
                handleError(error)
            }
        }
    }
}

private extension View {
    /// If onScrollVisibilityChange is available, applies it to this view; otherwise has no effect.
    func compatibilityOnScrollVisibilityChange(_ action: @escaping (Bool) -> Void) -> some View {
        if #available(iOS 18.0, *) {
            return onScrollVisibilityChange(action)
        } else {
            return self
        }
    }
}
