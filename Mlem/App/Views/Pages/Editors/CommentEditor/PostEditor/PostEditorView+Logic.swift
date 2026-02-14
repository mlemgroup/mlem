//
//  PostEditorView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 20/08/2024.
//

import MlemMiddleware
import SwiftUI

extension PostEditorView {
    var minTextEditorHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .body).lineHeight * 4 + 15
    }
    
    var minTitleEditorHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .title2).lineHeight + 15
    }
    
    var attachmentTransition: AnyTransition {
        .asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity)
    }
    
    var canDismiss: Bool {
        titleIsEmpty
            && contentIsEmpty
            && targets.count == 1
            && link == .none
            && imageManager == nil
    }
    
    var canSubmit: Bool {
        if !(imageManager?.state.isDone ?? true) ||
            link == .waiting ||
            !titleSlurMatches.isEmpty ||
            !bodySlurMatches.isEmpty { return false }
        if postToEdit != nil { return true }
        return !titleIsEmpty && targets.allSatisfy { $0.community != nil && $0.resolutionState == .success }
    }
    
    // ApiClient for uploading images etc
    var primaryApi: ApiClient {
        targets.first?.account.api ?? appState.firstApi
    }
    
    @MainActor
    func submit() async {
        uploadHistory.deleteWhereNotPresent(in: contentTextView.text)
        if postToEdit != nil {
            editPost()
        } else {
            await send()
        }
    }
    
    private func editPost() {
        guard let post = postToEdit else { return }
        do {
            try post.edit(
                title: titleTextView.text,
                content: contentTextView.text,
                linkUrl: imageManager?.image?.url ?? link.url ?? imageUrl,
                altText: post.altText,
                thumbnail: thumbnailManager.image?.url,
                nsfw: hasNsfwTag,
                languageId: nil
            )
            hapticManager.play(haptic: .success, tier: .low)
            dismiss()
        } catch {
            handleError(error)
            sending = false
        }
    }
    
    private func send() async {
        let validTargets = targets.filter { $0.sendState != .sent }
        let posts = await withTaskGroup(
            of: (target: PostEditorTarget, post: Post?).self,
            returning: [Post].self
        ) { taskGroup in
            for target in validTargets {
                if let community = target.community as? any DeprecatedCommunity {
                    taskGroup.addTask { @MainActor in
                        let post: Post?
                        do {
                            guard community.api === target.account.api else {
                                assertionFailure()
                                throw PostEditorViewError.mismatchingTargetApi
                            }
                            post = try await community.api.createPost(
                                communityId: community.id,
                                title: titleTextView.text,
                                content: contentTextView.text,
                                linkUrl: imageManager?.image?.url ?? link.url ?? imageUrl,
                                thumbnail: thumbnailManager.image?.url,
                                nsfw: hasNsfwTag
                            )
                        } catch {
                            handleError(error, silent: true)
                            post = nil
                        }
                        return (target, post)
                    }
                }
            }
            
            var posts = [Post]()
            
            while let result = await taskGroup.next() {
                if let post = result.post {
                    posts.append(post)
                    result.target.prepend(post: post, to: feedLoader)
                    if self.targets.count == 1 {
                        result.target.sendState = .sent
                    }
                } else {
                    result.target.sendState = .failed
                }
            }
            return posts
        }
        if posts.count == validTargets.count {
            hapticManager.play(haptic: .success, tier: .low)
            dismiss()
        } else {
            sending = false
        }
    }
    
    var animationHashValue: Int {
        var hasher = Hasher()
        hasher.combine(link)
        hasher.combine(imageManager)
        hasher.combine(hasNsfwTag)
        return hasher.finalize()
    }
    
    func restoreFocusState() {
        switch lastFocusedField {
        case .title:
            titleTextView.becomeFirstResponder()
        case .content:
            contentTextView.becomeFirstResponder()
        case nil:
            break
        }
    }
    
    func saveFocusState() {
        if contentTextView.isFirstResponder {
            lastFocusedField = .content
        } else if titleTextView.isFirstResponder {
            lastFocusedField = .title
        } else {
            lastFocusedField = nil
        }
    }
    
    func checkSlurFilter(text: String, slurMatches: Binding<[String: String]>) {
        Task {
            let matches = await findSlurFilterMatches(text: text)
            Task { @MainActor in
                slurMatches.wrappedValue = matches
            }
        }
    }
    
    func checkSlurFilters() {
        checkSlurFilter(text: contentTextView.text, slurMatches: $bodySlurMatches)
        checkSlurFilter(text: titleTextView.text, slurMatches: $titleSlurMatches)
    }
    
    /// Checks if the given text fails `slurRegex` and updates the given `String?` binding to the current
    /// validation state
    func findSlurFilterMatches(text: String) async -> [String: String] {
        var newSlurMatches: [String: String] = .init()
        
        for target in targets {
            let host = target.account.host
            guard newSlurMatches[host] == nil else { continue }
            
            do {
                if let output = try await target.slurRegex?.firstMatch(in: text.lowercased()) {
                    newSlurMatches[host] = String(text[output.range])
                }
            } catch {
                handleError(error, silent: true)
            }
        }
        
        return newSlurMatches
    }
}

private enum PostEditorViewError: Error {
    case mismatchingTargetApi
}
