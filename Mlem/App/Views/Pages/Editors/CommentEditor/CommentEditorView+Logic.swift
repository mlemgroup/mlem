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
            if let draft {
                try await draft.update(author: account, language: language, text: textView.text)
                try await draftsTracker.saveCommentsIndex()
            } else {
                draft = try await draftsTracker.createCommentDraft(
                    authorActorId: account.actorId,
                    targetActorId: originalContext.actorId,
                    language: language,
                    text: textView.text)
            }
            loadAvailableDrafts()
        } catch {
            handleError(error)
        }
    }
    
    func deleteDraft(_ draftId: UUID) async {
        do {
            try await draftsTracker.deleteCommentDraft(draftId)
            loadAvailableDrafts()
        } catch {
            handleError(error)
        }
    }
    
    func loadAvailableDrafts() {
        guard let originalContext else { return }
        availableDrafts = draftsTracker
            .getAvailableCommentDraftsForTarget(originalContext.actorId)
            .filter { draft in
                accountsTracker.userAccounts.contains { $0.actorId == draft.authorActorId }
            }
            .sorted { $0.touched > $1.touched }
        availableDrafts?.forEach { draft in
            if draft.resolved == .notStarted {
                Task {
                    do {
                        try await draft.resolve()
                    } catch {
                        handleError(error)
                    }
                }
            }
        }
    }
    
    func loadDraft(_ draft: CommentDraft) {
        guard let authorAccount = accountsTracker.userAccounts.first(where: { $0.actorId == draft.authorActorId }) else {
            assertionFailure()
            return
        }
        
        self.draft = draft
        account = authorAccount
        language = draft.language
        draftSaved = draft.touched
        textView.text = draft.text
        textView.delegate?.textViewDidChange?(textView) // required to clear prompt, assignment doesn't trigger didChange
    }
}
