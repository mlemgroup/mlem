//
//  Post+Actions.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-01-03.
//

import MlemMiddleware
import Foundation
import os

// swiftlint:disable file_length

// Functions to support the old Action system

extension Post {
    func hideAction(appState: AppState, feedback: Set<FeedbackType>) -> BasicAction? {
        guard let hidden = hidden.value, let toggleHidden = toggleHidden else { return nil }
        return .init(
            id: "hide\(uid)",
            appearance: .hide(isOn: hidden),
            callback: api.supports(.hidePosts, defaultValue: true) && api.canInteract(appState: appState)
            ? { @MainActor in toggleHidden(feedback) }
            : nil
        )
    }
    
    func blockAction(appState: AppState, feedback: Set<FeedbackType>) -> ActionGroup {
        .init(
            appearance: .init(
                label: "Block...",
                isDestructive: true,
                color: .themedNegative,
                icon: Icons.block
            ),
            prompt: "Block community or user?",
            disabled: !api.canInteract(appState: appState),
            displayMode: .popup
        ) {
            if let blockCreatorAction = blockCreatorAction(appState: appState, feedback: feedback, showConfirmation: false) {
                blockCreatorAction
            }
            if let blockCommunityAction = blockCommunityAction(appState: appState, feedback: feedback, showConfirmation: false) {
                blockCommunityAction
            }
        }
    }
    
    func blockCommunityAction(appState: AppState, feedback: Set<FeedbackType> = [], showConfirmation: Bool = true) -> BasicAction? {
        guard let community = community.value,
              let toggleBlocked = community.toggleBlocked else { return nil }
        return .init(
            id: "blockCommunity\(actorId.description)",
            appearance: .init(
                label: "Block Community",
                isOn: false,
                isDestructive: true,
                color: .themedNegative,
                icon: Icons.block
            ),
            confirmationPrompt: showConfirmation ? "Really block this community?" : nil,
            callback: api.canInteract(appState: appState)
            ? { @MainActor in toggleBlocked(feedback, nil) }
            : nil
        )
    }
    
    func crossPostAction() -> BasicAction {
        .init(
            id: "crosspost\(uid)",
            appearance: .crossPost(),
            callback: {
                var crossPostContent: String
                let crossPostedLabel = String(localized: "Crossposted from \(self.actorId.description)")
                if let content = self.content, !content.isEmpty {
                    crossPostContent = "\(crossPostedLabel)\n-----\n\(content)"
                } else {
                    crossPostContent = crossPostedLabel
                }
                NavigationModel.main.openSheet(.createPost(
                    community: nil,
                    title: self.title,
                    content: crossPostContent,
                    type: self.type,
                    nsfw: self.nsfw,
                    feedLoader: .init(wrappedValue: nil)
                ))
            }
        )
    }
    
    func lockAction(appState: AppState, feedback: Set<FeedbackType> = []) -> BasicAction? {
        guard api.canInteract(appState: appState) && canModerate else { return nil }
        return .init(
            id: "lock\(uid)",
            appearance: .lock(isOn: locked, isInProgress: lockedPending),
            confirmationPrompt: locked ? "Really unlock this post?" : "Really lock this post?",
            callback: { self.toggleLocked(feedback) }
        )
    }
    
    func pinAction(appState: AppState, feedback: Set<FeedbackType> = []) -> ActionGroup {
        .init(
            appearance: .pin(isOn: false, isInProgress: pinnedCommunityPending || pinnedInstancePending),
            prompt: "Pin to Community or Instance?",
            displayMode: .popup
        ) {
            pinToCommunityAction(appState: appState, feedback: feedback, showConfirmation: false)
            pinToInstanceAction(appState: appState, feedback: feedback, showConfirmation: false)
        }
    }
    
    func pinToCommunityAction(
        appState: AppState,
        feedback: Set<FeedbackType> = [],
        verboseTitle: Bool = true,
        showConfirmation: Bool = true
    ) -> BasicAction {
        let isOn = pinnedCommunity
        let prompt: LocalizedStringResource?
        if showConfirmation {
            if let communityName = community.value?.name {
                if isOn {
                    prompt = "Really unpin this post from \(communityName)?"
                } else {
                    prompt = "Really pin this post to \(communityName)?"
                }
            } else {
                if isOn {
                    prompt = "Really unpin this post from the community?"
                } else {
                    prompt = "Really pin this post to the community?"
                }
            }
        } else {
            prompt = nil
        }
        return .init(
            id: "pinToCommunity\(uid)",
            appearance: verboseTitle ? .pinToCommunity(
                isOn: isOn, isInProgress: pinnedCommunityPending
            ) : .pin(
                isOn: isOn, isInProgress: pinnedCommunityPending
            ),
            confirmationPrompt: prompt,
            callback: api.canInteract(appState: appState) && canModerate ? { @MainActor in
                self.togglePinnedCommunity(feedback: feedback)
            } : nil
        )
    }
    
    func pinToInstanceAction(appState: AppState, feedback: Set<FeedbackType> = [], showConfirmation: Bool = true) -> BasicAction {
        let isOn = pinnedInstance
        let prompt: LocalizedStringResource?
        if showConfirmation {
            if isOn {
                prompt = "Really unpin this post from \(host)?"
            } else {
                prompt = "Really pin this post to \(host)?"
            }
        } else {
            prompt = nil
        }
        return .init(
            id: "pinToInstance\(uid)",
            appearance: .pinToInstance(isOn: isOn, isInProgress: pinnedInstancePending),
            confirmationPrompt: prompt,
            callback: api.canInteract(appState: appState) && api.isAdmin ? { @MainActor in
                self.togglePinnedInstance(feedback: feedback)
            } : nil
        )
    }
    
    func createImageAction(navigation: NavigationLayer) -> BasicAction {
        .init(
            id: "exportAsImage\(uid)",
            appearance: .createImage()) {
                navigation.openSheet(.exportPostImage(self))
            }
    }
    
    func editAction(appState: AppState, navigation: NavigationLayer) -> BasicAction? {
        guard api.canInteract(appState: appState) else { return nil }
        return .init(
            id: "edit\(uid)",
            appearance: .edit(),
            callback: { navigation.openSheet(.editPost(self)) }
        )
    }
    
    func setNsfwAction(appState: AppState) -> BasicAction? {
        guard setNsfwIsAvailable(appState: appState) else { return nil }
        return .init(
            id: "setNsfw\(uid)",
            appearance: .toggleNsfw(isOn: nsfw),
            callback: { @MainActor in
                self.toggleNsfw { status in
                    Task {
                        await self.handleModerationActionCompletion(
                            message: "Failed to set NSFW status",
                            result: status,
                            feedback: [.haptic]
                        )
                    }
                }
            }
        )
    }
    
    func setNsfwIsAvailable(appState: AppState) -> Bool {
        guard let community = community.value else { return false }
        guard community.apiIsLocal else { return false }
        guard canModerate else { return false }
        guard api.canInteract(appState: appState) else { return false }
        guard api.supports(.moderatorSetNsfw, defaultValue: false) else { return false }
        return true
    }
    
    func viewVotesAction(navigation: NavigationLayer) -> BasicAction? {
        guard canModerate && api.supports(.viewVotes, defaultValue: true) else { return nil }
        return .init(
            id: "viewVotes\(uid)",
            appearance: .viewVotes(),
            callback: { @MainActor in navigation.push(.votesList(.post(self))) }
        )
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    func action(
        appState: AppState,
        navigation: NavigationLayer,
        type: PostBarConfiguration.ActionType,
        feedback: Set<FeedbackType> = [.haptic, .toast],
        commentTreeTracker: CommentTreeTracker? = nil,
        communityContext: Community? = nil,
        reportContext: Report? = nil
    ) -> (any Action)? {
        switch type {
        case .upvote: return upvoteAction(appState: appState, feedback: feedback)
        case .downvote: return downvoteAction(appState: appState, feedback: feedback)
        case .save: return saveAction(appState: appState, feedback: feedback)
        case .reply: return replyAction(appState: appState, commentTreeTracker: commentTreeTracker)
        case .share: return shareAction(navigation: navigation)
        case .selectText: return selectTextAction()
        case .hide: return hideAction(appState: appState, feedback: feedback)
        case .block: return blockAction(appState: appState, feedback: feedback)
        case .report: return reportAction(appState: appState, communityContext: communityContext)
        case .crossPost: return crossPostAction()
        case .lock: return lockAction(appState: appState, feedback: feedback)
        case .pin: return api.isAdmin ? pinAction(
                appState: appState,
                feedback: feedback
            ) : pinToCommunityAction(
                appState: appState,
                feedback: feedback
            )
        case .resolve: return reportContext?.resolveAction(appState: appState, feedback: feedback)
        case .remove: return removeAction(appState: appState, feedback: feedback)
        case .ban: return reportContext?.contextualBanAction(appState: appState)
        }
    }
    
    // MARK: - Readouts
    
    func upvoteReadout(showColor: Bool) -> Readout? {
        if let votes = votes.value {
            let isOn = votes.myVote == .upvote
            return Readout(
                id: "upvote\(actorId)",
                label: votes.upvotes.description,
                icon: isOn ? Icons.upvoteSquareFill : Icons.upvoteSquare,
                color: isOn && showColor ? .themedUpvote : nil
            )
        }
        return nil
    }
    
    func downvoteReadout(showColor: Bool) -> Readout? {
        if let votes = votes.value {
            let isOn = votes.myVote == .downvote
            return Readout(
                id: "downvote\(actorId)",
                label: votes.downvotes.description,
                icon: isOn ? Icons.downvoteSquareFill : Icons.downvoteSquare,
                color: isOn && showColor ? .themedDownvote : nil
            )
        }
        return nil
    }
    
    func readout(type: PostBarConfiguration.ReadoutType, showColor: Bool) -> Readout? {
        switch type {
        case .created: createdReadout
        // swiftlint:disable:next void_function_in_ternary
        case .score: downvotesEnabled ? scoreReadout(showColor: showColor) : upvoteReadout(showColor: showColor)
        case .upvote: upvoteReadout(showColor: showColor)
        case .downvote: downvotesEnabled ? downvoteReadout(showColor: showColor) : nil
        case .comment: commentReadout
        case .saved: savedReadout(showColor: showColor)
        }
    }
    
    // MARK: - Counters
    
    func counter(
        appState: AppState,
        type: PostBarConfiguration.CounterType,
        commentTreeTracker: CommentTreeTracker? = nil
    ) -> Counter? {
        switch type {
        case .score: scoreCounter(appState: appState, downvotesEnabled: downvotesEnabled)
        case .upvote: upvoteCounter(appState: appState)
        case .downvote: downvotesEnabled ? downvoteCounter(appState: appState, downvotesEnabled: downvotesEnabled) : nil
        case .reply: replyCounter(appState: appState, commentTreeTracker: commentTreeTracker)
        }
    }
    
    // MARK: - Action Groups
    
    @ActionBuilder
    func allMenuActions(
        appState: AppState,
        expanded: Bool = false,
        feedback: Set<FeedbackType> = [.haptic, .toast],
        showAllActions: Bool = true,
        navigation: NavigationLayer?,
        report: Report? = nil,
        commentTreeTracker: CommentTreeTracker? = nil
    ) -> [any Action] {
        basicMenuActions(
            appState: appState,
            expanded: expanded,
            feedback: feedback,
            navigation: navigation,
            commentTreeTracker: commentTreeTracker
        )
        if canModerate {
            ActionGroup(
                appearance: .init(label: "Moderation...", color: .themedModeration, icon: Icons.moderation),
                displayMode: Settings.get(\.menus_modActionGrouping) == .divider || expanded ? .section : .disclosure
            ) {
                moderatorMenuActions(
                    appState: appState,
                    feedback: feedback,
                    showAllActions: showAllActions,
                    navigation: navigation,
                    report: report
                )
            }
        }
    }
    
    @ActionBuilder
    func basicMenuActions(
        appState: AppState,
        expanded: Bool,
        feedback: Set<FeedbackType> = [.haptic, .toast],
        navigation: NavigationLayer?,
        commentTreeTracker: CommentTreeTracker? = nil
    ) -> [any Action] {
        ActionGroup(displayMode: .compactSection) {
            if let upvoteAction = upvoteAction(appState: appState, feedback: feedback) { upvoteAction }
            if let downvoteAction = downvoteAction(appState: appState, feedback: feedback) { downvoteAction }
            if let saveAction = saveAction(appState: appState, feedback: feedback) { saveAction }
            replyAction(appState: appState, commentTreeTracker: commentTreeTracker)
            if !deleted {
                selectTextAction()
            }
            shareAction(navigation: navigation)
            
            if expanded, let navigation {
                createImageAction(navigation: navigation)
            }
            
            if isOwnPost, let navigation, let editAction = editAction(appState: appState, navigation: navigation) {
                editAction
                deleteAction(appState: appState, feedback: feedback)
            } else {
                if api.supports(.hidePosts, defaultValue: true),
                let hideAction = hideAction(appState: appState, feedback: feedback) {
                    hideAction
                }
                if !canModerate, !deleted {
                    reportAction(appState: appState)
                }
                blockAction(appState: appState, feedback: feedback)
            }
        }
    }
    
    @ActionBuilder
    // swiftlint:disable:next cyclomatic_complexity
    func moderatorMenuActions(
        appState: AppState,
        feedback: Set<FeedbackType> = [.haptic, .toast],
        showAllActions: Bool = true,
        navigation: NavigationLayer?,
        report: Report? = nil
    ) -> [any Action] {
        if showAllActions || Settings.get(\.menus_allModActions) {
            pinToCommunityAction(appState: appState, feedback: feedback, verboseTitle: api.isAdmin)
            if api.isAdmin {
                pinToInstanceAction(appState: appState, feedback: feedback)
            }
            if let lockAction = lockAction(appState: appState, feedback: feedback) { lockAction }
            
            if setNsfwIsAvailable(appState: appState),
               let setNsfwAction = setNsfwAction(appState: appState) {
                setNsfwAction
            }
            
            if let navigation,
               api.supports(.viewVotes, defaultValue: false),
               let viewVotesAction = viewVotesAction(navigation: navigation) {
                viewVotesAction
            }
        }
        if !isOwnPost {
            if canModerate { removeAction(appState: appState) }
            if let creator = creator.value, let community = community.value {
                creator.banActions(appState: appState, community: community, withUserLabel: true)
            }
        }
        if api.isAdmin, api.supports(.purgeContent, defaultValue: false) {
            purgeAction(appState: appState)
            if !isOwnPost, let purgeCreatorAction = purgeCreatorAction(appState: appState) {
                purgeCreatorAction
            }
        }
        if let report {
            ActionGroup {
                report.menuActions(appState: appState)
            }
        }
    }
}

// swiftlint:enable file_length
