//
//  CommentEditorView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 20/08/2024.
//

import MlemMiddleware
import SwiftUI

extension CommentEditorView {
    @Sendable
    func resolveContext() async {
        guard let originalContext else { return }
        do {
            if originalContext.api === account.api {
                resolutionState = .success
                resolvedContext = originalContext
            } else {
                Task { @MainActor in
                    resolutionState = .resolving
                }
                switch originalContext {
                case let .post(post):
                    let post = try await account.api.getPost(actorId: post.actorId)
                    Task { @MainActor in
                        resolutionState = .success
                        resolvedContext = .post(post)
                    }
                case let .comment(comment):
                    let comment = try await account.api.getComment(actorId: comment.actorId)
                    Task { @MainActor in
                        resolutionState = .success
                        resolvedContext = .comment(comment)
                    }
                }
            }
            
        } catch ApiClientError.noEntityFound {
            print("No entity found!")
            Task { @MainActor in
                resolutionState = .notFound
            }
        } catch {
            Task { @MainActor in
                resolutionState = .error(.init(error: error))
            }
        }
    }
    
    @Sendable
    func inferContextFromCommentToEdit() async {
        guard originalContext == nil else { return }
        do {
            if let commentToEdit {
                if let parent = try await commentToEdit.getParent(cachedValueAcceptable: true) {
                    originalContext = .comment(parent)
                } else {
                    originalContext = .post(commentToEdit.post)
                }
            }
        } catch {
            handleError(error)
        }
    }
    
    func send() async {
        do {
            if let commentToEdit {
                try await commentToEdit.edit(content: textView.text, languageId: commentToEdit.languageId)
            } else if let resolvedContext {
                let result: Comment2
                let parent: (any Comment1Providing)?
                switch resolvedContext {
                case let .post(post):
                    result = try await post.reply(content: textView.text)
                    parent = nil
                case let .comment(comment):
                    result = try await comment.reply(content: textView.text)
                    parent = comment
                }
                commentTreeTracker?.insertCreatedComment(result, parent: parent)
            } else {
                return
            }
            Task { @MainActor in
                textView.resignFirstResponder()
                textView.isEditable = false
                HapticManager.main.play(haptic: .success, priority: .low)
                dismiss()
            }
        } catch {
            Task { @MainActor in
                sending = false
                textView.isEditable = true
                handleError(error)
            }
        }
    }
}
