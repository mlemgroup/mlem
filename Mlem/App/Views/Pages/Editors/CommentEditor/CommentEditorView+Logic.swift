//
//  CommentEditorView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 20/08/2024.
//

import MlemMiddleware
import SwiftUI

import os

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
                } else if let post = commentToEdit.post.value_ {
                    originalContext = .post(post)
                }
            }
        } catch {
            handleError(error)
        }
    }
    
    func send() async {
        uploadHistory.deleteWhereNotPresent(in: textView.text)
        do {
            if let commentToEdit {
                try await commentToEdit.edit(content: textView.text, language: language)
            } else if let resolvedContext {
                let result: Comment
                let parent: Comment?
                switch resolvedContext {
                case let .post(post):
                    result = try await post.reply(content: textView.text, language: language)
                    parent = nil
                case let .comment(comment):
                    result = try await comment.reply(content: textView.text, language: language)
                    parent = comment
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
        slurTask?.cancel()
        slurTask = Task {
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
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
    
    func saveDraft() async {
        guard let originalContext, !textView.text.isEmpty else {
            return
        }
        do {
            draftSaved = try await draftsTracker.saveCommentDraft(.init(
                id: draftId,
                author: appState.firstAccount.actorId,
                target: originalContext.actorId,
                language: language,
                text: textView.text)).touched
        } catch {
            handleError(error)
        }
    }
    
    func deleteDraft(_ id: UUID) async {
        do {
            try await draftsTracker.deleteCommentDraft(id)
            loadAvailableDrafts()
        } catch {
            handleError(error)
        }
    }
    
    func loadAvailableDrafts() {
        guard let originalContext else { return }
        availableDrafts = draftsTracker.getAvailableCommentDraftsForTarget(originalContext.actorId)
    }
    
    func loadDraft(_ draftMetadata: DraftMetadata) {
        guard let draftContents = draftsTracker.getCommentDraft(draftMetadata.id) else {
            assertionFailure()
            return
        }
        
        draftId = draftContents.id
        language = draftContents.language
        draftSaved = draftMetadata.touched
        textView.text = draftContents.text
        textView.delegate?.textViewDidChange?(textView) // required to clear prompt, assignment doesn't trigger didChange
    }
}
