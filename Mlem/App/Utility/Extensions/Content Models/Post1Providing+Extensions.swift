//
//  Post1Providing+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-24.
//

import Foundation
import MlemMiddleware
import SwiftUI

extension Post1Providing {
    private var self2: (any Post2Providing)? { self as? any Post2Providing }
    
    var isOwnPost: Bool { creatorId == api.myPerson?.id }

    var canModerate: Bool {
        api.myPerson?.moderates(communityId: communityId) ?? false || api.isAdmin
    }
    
    func showEditSheet() {
        if let self = self as? any Post2Providing {
            NavigationModel.main.openSheet(.editPost(self.post2))
        }
    }
    
    func toggleHidden(feedback: Set<FeedbackType>) {
        if let self2 {
            if feedback.contains(.haptic) {
                HapticManager.main.play(haptic: .lightSuccess, priority: .low)
            }
            if feedback.contains(.toast) {
                if self2.hidden {
                    ToastModel.main.add(.success("Shown"))
                } else {
                    ToastModel.main.add(
                        .undoable(
                            "Hidden",
                            systemImage: Icons.hideFill,
                            callback: {
                                self2.updateHidden(false)
                            }
                        )
                    )
                }
            }
            self2.toggleHidden()
        } else {
            print("DEBUG no self2 found in toggleHidden!")
        }
    }
    
    func toggleLocked(feedback: Set<FeedbackType>) {
        Task {
            await handleModerationActionCompletion(
                message: locked ? "Failed to unlock post" : "Failed to lock post",
                result: self.toggleLocked().result.get(),
                feedback: feedback
            )
        }
    }
    
    func togglePinnedCommunity(feedback: Set<FeedbackType>) {
        Task {
            await handleModerationActionCompletion(
                message: pinnedCommunity ? "Failed to unpin post" : "Failed to pin post",
                result: self.togglePinnedCommunity().result.get(),
                feedback: feedback
            )
        }
    }
    
    func togglePinnedInstance(feedback: Set<FeedbackType>) {
        Task {
            await handleModerationActionCompletion(
                message: pinnedInstance ? "Failed to unpin post" : "Failed to pin post",
                result: self.togglePinnedInstance().result.get(),
                feedback: feedback
            )
        }
    }
    
    private func handleModerationActionCompletion(
        message: LocalizedStringResource,
        result: StateUpdateResult,
        feedback: Set<FeedbackType>
    ) async {
        if feedback.contains(.haptic) {
            await HapticManager.main.play(haptic: .success, priority: .low)
        }
        switch result {
        case .failed:
            ToastModel.main.add(.failure(message))
        default:
            break
        }
    }
    
    func markRead() {
        self2?.updateRead(true)
    }
    
    func swipeActions(
        behavior: SwipeBehavior,
        commentTreeTracker: CommentTreeTracker? = nil
    ) -> SwipeConfiguration {
        .init(
            behavior: behavior,
            leadingActions: {
                if api.canInteract {
                    upvoteAction(feedback: [.haptic])
                    downvoteAction(feedback: [.haptic])
                }
            },
            trailingActions: {
                if api.canInteract {
                    saveAction(feedback: [.haptic])
                    replyAction(commentTreeTracker: commentTreeTracker)
                }
            }
        )
    }
    
    @ActionBuilder
    func allMenuActions(
        expanded: Bool = false,
        feedback: Set<FeedbackType> = [.haptic, .toast],
        commentTreeTracker: CommentTreeTracker? = nil
    ) -> [any Action] {
        basicMenuActions(feedback: feedback, commentTreeTracker: commentTreeTracker)
        if canModerate {
            ActionGroup(
                appearance: .init(label: "Moderation...", color: Palette.main.moderation, icon: Icons.moderation),
                displayMode: Settings.main.moderatorActionGrouping == .divider || expanded ? .section : .disclosure
            ) {
                moderatorMenuActions(feedback: feedback)
            }
        }
    }
    
    @ActionBuilder
    func basicMenuActions(
        feedback: Set<FeedbackType> = [.haptic, .toast],
        commentTreeTracker: CommentTreeTracker? = nil
    ) -> [any Action] {
        ActionGroup(displayMode: .compactSection) {
            upvoteAction(feedback: feedback)
            downvoteAction(feedback: feedback)
            saveAction(feedback: feedback)
            replyAction(commentTreeTracker: commentTreeTracker)
            selectTextAction()
            shareAction()

            if isOwnPost {
                editAction()
                deleteAction(feedback: feedback)
            } else {
                // If no version has been fetched yet, assume they're on <0.19.4 for now.
                // Once 0.19.4 is widely adopted we could assume they're on >=0.19.4.
                // See also the identical check within `hideAction` itself.
                if (api.fetchedVersion ?? .zero) >= .v19_4 {
                    hideAction(feedback: feedback)
                }
                if !canModerate {
                    reportAction()
                }
                blockAction(feedback: feedback)
            }
        }
    }
    
    @ActionBuilder
    func moderatorMenuActions(feedback: Set<FeedbackType> = [.haptic, .toast]) -> [any Action] {
        pinToCommunityAction(feedback: feedback, verboseTitle: api.isAdmin)
        if api.isAdmin {
            pinToInstanceAction(feedback: feedback)
        }
        lockAction(feedback: feedback)
        if let self2, !isOwnPost {
            self2.removeAction()
        }
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    func action(
        type: PostBarConfiguration.ActionType,
        feedback: Set<FeedbackType> = [.haptic, .toast],
        commentTreeTracker: CommentTreeTracker? = nil,
        communityContext: (any CommunityStubProviding)? = nil
    ) -> any Action {
        switch type {
        case .upvote: upvoteAction(feedback: feedback)
        case .downvote: downvoteAction(feedback: feedback)
        case .save: saveAction(feedback: feedback)
        case .reply: replyAction(commentTreeTracker: commentTreeTracker)
        case .share: shareAction()
        case .selectText: selectTextAction()
        case .hide: hideAction(feedback: feedback)
        case .block: blockAction(feedback: feedback)
        case .report: reportAction(communityContext: communityContext)
        case .lock: lockAction(feedback: feedback)
        // SwiftLint is erroneously warning here. This could be fixed by wrapping the expression
        // in parenthesis, but the pre-commit hook removed the paranthesis
        // swiftlint:disable:next void_function_in_ternary
        case .pin: api.isAdmin ? pinAction(feedback: feedback) : pinToCommunityAction(feedback: feedback)
        case .crossPost: crossPostAction()
        }
    }
    
    func counter(
        type: PostBarConfiguration.CounterType,
        commentTreeTracker: CommentTreeTracker? = nil
    ) -> Counter {
        switch type {
        case .score: scoreCounter
        case .upvote: upvoteCounter
        case .downvote: downvoteCounter
        case .reply: replyCounter(commentTreeTracker: commentTreeTracker)
        }
    }
    
    func readout(type: PostBarConfiguration.ReadoutType) -> Readout {
        switch type {
        case .created: createdReadout
        case .score: scoreReadout
        case .upvote: upvoteReadout
        case .downvote: downvoteReadout
        case .comment: commentReadout
        }
    }
    
    func taggedTitle(communityContext: (any Community1Providing)?) -> Text {
        let hasTags: Bool = removed
            || deleted
            || pinnedInstance
            || (communityContext != nil && pinnedCommunity)
            || locked
        
        return postTag(active: removed, icon: Icons.removeFill, color: Palette.main.negative) +
            postTag(active: deleted, icon: Icons.delete, color: Palette.main.negative) +
            postTag(active: pinnedInstance, icon: Icons.pinFill, color: Palette.main.administration) +
            postTag(active: pinnedCommunity && communityContext != nil, icon: Icons.pinFill, color: Palette.main.moderation) +
            postTag(active: locked, icon: Icons.lockFill, color: Palette.main.lockAccent) +
            Text(verbatim: "\(hasTags ? "  " : "")\(title)")
    }
    
    /// Host if this is a link post, otherwise nil.
    var linkHost: String? {
        if case let .link(link) = type {
            return link.host
        }
        return nil
    }
    
    var placeholderImageName: String {
        switch type {
        case .text: Icons.textPost
        case .image: Icons.photo
        case .link: Icons.websiteIcon
        case .titleOnly: Icons.titleOnlyPost
        }
    }
    
    func shouldShowLoadingSymbol(for barConfiguration: PostBarConfiguration? = nil) -> Bool {
        if !lockedManager.isInSync, !(barConfiguration?.all.contains(.action(.lock)) ?? false) {
            return true
        }
        if !pinnedCommunityManager.isInSync, !(barConfiguration?.all.contains(.action(.pin)) ?? false) {
            return true
        }
        if !pinnedInstanceManager.isInSync, !(barConfiguration?.all.contains(.action(.pin)) ?? false) {
            return true
        }
        return false
    }
    
    // MARK: Actions
    
    // Overrides the `ActorIdentifiable+Extensions` implementation
    func shareAction() -> ShareAction {
        .init(id: "share\(actorId)", url: actorId, actions: [crossPostAction()])
    }
    
    func crossPostAction() -> BasicAction {
        .init(
            id: "crosspost\(uid)",
            appearance: .crossPost(),
            callback: {
                var crossPostContent: String = .init(localized: "Crossposted from \(self.actorId.absoluteString)")
                if let content = self.content {
                    crossPostContent += "\n-----\n\(content)"
                }
                NavigationModel.main.openSheet(.createPost(
                    community: nil as AnyCommunity?,
                    title: self.title,
                    content: crossPostContent,
                    url: self.linkUrl,
                    nsfw: self.nsfw
                ))
            }
        )
    }
    
    func hideAction(feedback: Set<FeedbackType>) -> BasicAction {
        let hidden = hidden_ ?? false
        let available = (api.fetchedVersion ?? .zero) >= .v19_4 && api.canInteract
        return .init(
            id: "hide\(uid)",
            appearance: .hide(isOn: hidden),
            callback: available ? { self.self2?.toggleHidden(feedback: feedback) } : nil
        )
    }
    
    func blockAction(feedback: Set<FeedbackType>) -> ActionGroup {
        .init(
            appearance: .init(
                label: "Block...",
                isDestructive: true,
                color: Palette.main.negative,
                icon: Icons.block
            ),
            prompt: "Block community or user?",
            disabled: !api.canInteract,
            displayMode: .popup
        ) {
            blockCreatorAction(feedback: feedback, showConfirmation: false)
            blockCommunityAction(feedback: feedback, showConfirmation: false)
        }
    }
    
    func blockCommunityAction(feedback: Set<FeedbackType> = [], showConfirmation: Bool = true) -> BasicAction {
        .init(
            id: "blockCommunity\(actorId.absoluteString)",
            appearance: .init(
                label: "Block Community",
                isOn: false,
                isDestructive: true,
                color: Palette.main.negative,
                icon: Icons.block
            ),
            confirmationPrompt: showConfirmation ? "Really block this community?" : nil,
            callback: api.canInteract ? { self.self2?.community.toggleBlocked(feedback: feedback) } : nil
        )
    }
    
    func editAction() -> BasicAction {
        .init(
            id: "edit\(uid)",
            appearance: .edit(),
            callback: api.canInteract ? { self.showEditSheet() } : nil
        )
    }
    
    func lockAction(feedback: Set<FeedbackType> = []) -> BasicAction {
        .init(
            id: "lock\(uid)",
            appearance: .lock(isOn: locked, isInProgress: !lockedManager.isInSync),
            confirmationPrompt: locked ? "Really unlock this post?" : "Really lock this post?",
            callback: api.canInteract && canModerate ? { self.self2?.toggleLocked(feedback: feedback) } : nil
        )
    }
    
    func pinAction(feedback: Set<FeedbackType> = []) -> ActionGroup {
        .init(
            appearance: .pin(isOn: false, isInProgress: !(pinnedCommunityManager.isInSync && pinnedInstanceManager.isInSync)),
            prompt: "Pin to Community or Instance?",
            displayMode: .popup
        ) {
            pinToCommunityAction(feedback: feedback, showConfirmation: false)
            pinToInstanceAction(feedback: feedback, showConfirmation: false)
        }
    }
    
    func pinToCommunityAction(
        feedback: Set<FeedbackType> = [],
        verboseTitle: Bool = true,
        showConfirmation: Bool = true
    ) -> BasicAction {
        let isOn = self2?.pinnedCommunity ?? false
        let prompt: String?
        if showConfirmation {
            if let communityName = community_?.name {
                if isOn {
                    prompt = .init(localized: "Really unpin this post from \(communityName)?")
                } else {
                    prompt = .init(localized: "Really pin this post to \(communityName)?")
                }
            } else {
                if isOn {
                    prompt = .init(localized: "Really unpin this post from the community?")
                } else {
                    prompt = .init(localized: "Really pin this post to the community?")
                }
            }
        } else {
            prompt = nil
        }
        return .init(
            id: "pinToCommunity\(uid)",
            appearance: verboseTitle ? .pinToCommunity(
                isOn: isOn, isInProgress: !pinnedCommunityManager.isInSync
            ) : .pin(
                isOn: isOn, isInProgress: !pinnedCommunityManager.isInSync
            ),
            confirmationPrompt: prompt,
            callback: api.canInteract && canModerate ? { self.togglePinnedCommunity(feedback: feedback) } : nil
        )
    }
    
    func pinToInstanceAction(feedback: Set<FeedbackType> = [], showConfirmation: Bool = true) -> BasicAction {
        let isOn = self2?.pinnedInstance ?? false
        let prompt: String?
        if showConfirmation {
            if isOn {
                prompt = .init(localized: "Really unpin this post from \(host ?? "")?")
            } else {
                prompt = .init(localized: "Really pin this post to \(host ?? "")?")
            }
        } else {
            prompt = nil
        }
        return .init(
            id: "pinToInstance\(uid)",
            appearance: .pinToInstance(isOn: isOn, isInProgress: !pinnedInstanceManager.isInSync),
            confirmationPrompt: prompt,
            callback: api.canInteract && api.isAdmin ? { self.togglePinnedInstance(feedback: feedback) } : nil
        )
    }
    // swiftlint:disable:next file_length
}
