//
//  CommentEditorView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 20/08/2024.
//

import MlemMiddleware
import SwiftUI

extension CommentEditorView {
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
                    let post = try await account.api.getPost(url: post.actorId.url)
                    Task { @MainActor in
                        resolutionState = .success
                        resolvedContext = .post(post)
                    }
                case let .comment(comment):
                    let comment = try await account.api.getComment(url: comment.actorId.url)
                    Task { @MainActor in
                        resolutionState = .success
                        resolvedContext = .comment(comment)
                    }
                case let .unifiedPost(post):
                    let post = try await account.api.unifiedGetPost(url: post.actorId.url)
                    Task { @MainActor in
                        resolutionState = .success
                        resolvedContext = .unifiedPost(post)
                    }
                }
            }
            
        } catch ApiClientError.noEntityFound {
            handleError(ApiClientError.noEntityFound, silent: true)
            Task { @MainActor in
                resolutionState = .notFound
            }
        } catch {
            Task { @MainActor in
                resolutionState = .error(.init(error: error))
            }
        }
    }
    
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
    
    // TODO: UnifiedComment remove id shim, just pass in reply function
    func send(id: Int = -1) async {
        uploadHistory.deleteWhereNotPresent(in: textView.text)
        do {
            if let commentToEdit {
                try await commentToEdit.edit(content: textView.text, languageId: nil)
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
                case let .unifiedPost(post):
                    assert(id > 0, "Must provide id for unifiedPost")
                    result = try await post.api.replyToPost(id: id, content: textView.text)
                    parent = nil
                }
                commentTreeTracker?.insertCreatedComment(result, parent: parent)
            } else {
                assertionFailure()
                return
            }
            Task { @MainActor in
                textView.resignFirstResponder()
                textView.isEditable = false
                hapticManager.play(haptic: .success, tier: .low)
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
    
    func checkSlurFilter(text: String) {
        do {
            if let output = try slurRegex?.firstMatch(in: text.lowercased()) {
                slurMatch = String(text[output.range])
            } else {
                slurMatch = nil
            }
        } catch {
            handleError(error, silent: true)
        }
    }
}
