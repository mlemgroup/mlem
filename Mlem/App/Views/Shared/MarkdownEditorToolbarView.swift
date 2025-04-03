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
    @ScaledMetric(relativeTo: .body) var toolbarHeight: CGFloat = 32
    
    @State var leftFade: Bool
    @State var rightFade: Bool
    
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
                Button("Bold", systemImage: Icons.bold) {
                    textView.wrapSelectionWithDelimiters("**")
                }
                .compatibilityOnScrollVisibilityChange { isVisible in
                    if UIDevice.isPad {
                        withAnimation {
                            leftFade = !isVisible
                        }
                    }
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
                Button("Link", systemImage: Icons.websiteAddress) {
                    textView.wrapSelectionWithLink()
                }
                if actions == .all {
                    SwiftUI.Divider()
                        .padding(.top, 2)
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
                        ImageUploadMenu(imageManager: imageManager, imageUploadApi: imageUploadApi) {
                            Label("Image", systemImage: Icons.uploadImage)
                        }
                    }
                    Button("Spoiler", systemImage: Icons.spoiler) {
                        textView.wrapSelectionWithSpoiler()
                    }
                    Button("Code Block", systemImage: Icons.codeBlock) {
                        textView.wrapSelectionWithCodeBlock()
                    }
                }
                SwiftUI.Divider()
                    .padding(.top, 2)
                Button("Community Link", systemImage: Icons.community) {
                    navigation.openSheet(.communityPicker { community in
                        textView.insertText(community.fullNameWithPrefix)
                    })
                }
                Button("User Link", systemImage: Icons.person) {
                    navigation.openSheet(.personPicker { person in
                        // lemmy-ui doesn't recognize the @user@example.com format, so we have to do this instead :(
                        // See this issue https://github.com/LemmyNet/lemmy-ui/issues/2579
                        textView.insertText("[\(person.fullNameWithPrefix)](\(person.actorId))")
                    })
                }
                Button("Instance Link", systemImage: Icons.instance) {
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
