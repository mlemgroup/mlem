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
        UIFont.preferredFont(forTextStyle: .title2).lineHeight * 4 + 15
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
        if !(imageManager?.state.isDone ?? true) || link == .waiting { return false }
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
            await editPost()
        } else {
            await send()
        }
    }
    
    private func editPost() async {
        guard let post = postToEdit else { return }
        do {
            try await post.edit(
                title: titleTextView.text,
                content: contentTextView.text,
                linkUrl: imageManager?.image?.url ?? link.url ?? imageUrl,
                altText: post.altText,
                thumbnail: nil,
                nsfw: hasNsfwTag,
                languageId: post.languageId
            )
            HapticManager.main.play(haptic: .success, priority: .low)
            dismiss()
        } catch {
            handleError(error)
            sending = false
        }
    }
    
    private func send() async {
        let validTargets = targets.filter { $0.sendState != .sent }
        let posts = await withTaskGroup(
            of: (target: PostEditorTarget, post: Post2?).self,
            returning: [Post2].self
        ) { taskGroup in
            for target in validTargets {
                if let community = target.community as? any Community {
                    taskGroup.addTask {
                        let post: Post2?
                        do {
                            post = try await community.api.createPost(
                                communityId: community.id,
                                title: titleTextView.text,
                                content: contentTextView.text,
                                linkUrl: imageManager?.image?.url ?? link.url,
                                nsfw: hasNsfwTag
                            )
                        } catch {
                            post = nil
                        }
                        return (target, post)
                    }
                }
            }
            
            var posts = [Post2]()
            
            while let result = await taskGroup.next() {
                if let post = result.post {
                    posts.append(post)
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
            HapticManager.main.play(haptic: .success, priority: .low)
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
}
