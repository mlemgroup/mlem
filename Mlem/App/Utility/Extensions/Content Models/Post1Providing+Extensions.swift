//
//  Post1Providing+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-24.
//

import Foundation
import Haptics
import MlemMiddleware
import SwiftUI

extension Post1Providing {
    private var self2: (any Post2Providing)? { self as? any Post2Providing }
    
    var isOwnPost: Bool { creatorId == api.myPerson?.id }
    
    var shouldHideInFeed: Bool {
        (creator_?.shouldHideInFeed ?? false) || (community_?.shouldHideInFeed ?? false) || (hidden_ ?? false) || purged
    }
    
    var canModerate: Bool {
        api.myPerson?.moderates(communityId: communityId) ?? false || api.isAdmin
    }
    
    @MainActor
    func showEditSheet() {
        if let self = self as? any Post2Providing {
            NavigationModel.main.openSheet(.editPost(self.post2))
        }
    }
    
    func toggleHidden(feedback: Set<FeedbackType>) {
        if let self2 {
            if feedback.contains(.haptic) {
                HapticManager.main.play(haptic: .lightSuccess, tier: .low)
            }
            if feedback.contains(.toast) {
                if self2.hidden {
                    ToastModel.main.add(.success("Shown"))
                } else {
                    ToastModel.main.add(
                        .undoable(
                            "Hidden",
                            icon: .general.hide,
                            callback: {
                                self2.updateHidden(false)
                            }
                        )
                    )
                }
            }
            self2.toggleHidden()
        } else {
            handleError(MlemError.modelError("No self2 found"), silent: true)
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
            HapticManager.main.play(haptic: .success, tier: .low)
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
        feedback: Set<FeedbackType> = [.haptic, .toast],
        navigation: NavigationLayer?,
        commentTreeTracker: CommentTreeTracker? = nil
    ) -> [any Action] {
        ActionGroup(displayMode: .compactSection) {
            upvoteAction(appState: appState, feedback: feedback)
            downvoteAction(appState: appState, feedback: feedback)
            saveAction(appState: appState, feedback: feedback)
            replyAction(appState: appState, commentTreeTracker: commentTreeTracker)
            if !deleted {
                selectTextAction()
            }
            shareAction(navigation: navigation)
            
            if isOwnPost {
                editAction(appState: appState)
                deleteAction(appState: appState, feedback: feedback)
            } else {
                if api.supportsOrNil(.hidePosts) ?? true {
                    hideAction(appState: appState, feedback: feedback)
                }
                if !canModerate, !deleted {
                    reportAction(appState: appState)
                }
                blockAction(appState: appState, feedback: feedback)
            }
        }
    }
    
    @ActionBuilder
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
            lockAction(appState: appState, feedback: feedback)
            if let navigation, api.isAdmin || (api.supportsOrNil(.moderatorsCanViewVotes) ?? true) {
                viewVotesAction(navigation: navigation)
            }
        }
        if let self2, !isOwnPost {
            self2.removeAction(appState: appState).disabled(!canModerate)
            self2.creator.banActions(appState: appState, community: self2.community, withUserLabel: true)
        }
        if api.isAdmin {
            purgeAction(appState: appState)
            if !isOwnPost {
                purgeCreatorAction(appState: appState)
            }
        }
        if let report {
            ActionGroup {
                report.menuActions(appState: appState)
            }
        }
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    func action(
        appState: AppState,
        navigation: NavigationLayer,
        type: PostBarConfiguration.ActionType,
        feedback: Set<FeedbackType> = [.haptic, .toast],
        commentTreeTracker: CommentTreeTracker? = nil,
        communityContext: (any CommunityStubProviding)? = nil,
        reportContext: Report? = nil
    ) -> (any Action)? {
        switch type {
        case .upvote: upvoteAction(appState: appState, feedback: feedback)
        case .downvote: api.downvotesEnabled ? downvoteAction(appState: appState, feedback: feedback) : nil
        case .save: saveAction(appState: appState, feedback: feedback)
        case .reply: replyAction(appState: appState, commentTreeTracker: commentTreeTracker)
        case .share: shareAction(navigation: navigation)
        case .selectText: selectTextAction()
        case .hide: hideAction(appState: appState, feedback: feedback)
        case .block: blockAction(appState: appState, feedback: feedback)
        case .report: reportAction(appState: appState, communityContext: communityContext)
        case .crossPost: crossPostAction()
        case .lock: lockAction(appState: appState, feedback: feedback)
        // SwiftLint is erroneously warning here. This could be fixed by wrapping the expression
        // in parenthesis, but the pre-commit hook removed the paranthesis
        // swiftlint:disable:next void_function_in_ternary
        case .pin: api.isAdmin ? pinAction(
                appState: appState,
                feedback: feedback
            ) : pinToCommunityAction(
                appState: appState,
                feedback: feedback
            )
        case .resolve: reportContext?.resolveAction(appState: appState, feedback: feedback)
        case .remove: removeAction(appState: appState, feedback: feedback).disabled(!canModerate)
        case .ban: reportContext?.contextualBanAction(appState: appState)
        }
    }
    
    func counter(
        appState: AppState,
        type: PostBarConfiguration.CounterType,
        commentTreeTracker: CommentTreeTracker? = nil
    ) -> Counter? {
        switch type {
        case .score: scoreCounter(appState: appState)
        case .upvote: upvoteCounter(appState: appState)
        case .downvote: api.downvotesEnabled ? downvoteCounter(appState: appState) : nil
        case .reply: replyCounter(appState: appState, commentTreeTracker: commentTreeTracker)
        }
    }
    
    func readout(type: PostBarConfiguration.ReadoutType, showColor: Bool) -> Readout? {
        switch type {
        case .created: createdReadout
        // swiftlint:disable:next void_function_in_ternary
        case .score: api.downvotesEnabled ? scoreReadout(showColor: showColor) : upvoteReadout(showColor: showColor)
        case .upvote: upvoteReadout(showColor: showColor)
        case .downvote: api.downvotesEnabled ? downvoteReadout(showColor: showColor) : nil
        case .comment: commentReadout
        case .saved: savedReadout(showColor: showColor)
        }
    }
    
    func taggedTitle(communityContext: (any Community1Providing)?) -> Text {
        let hasTags: Bool = removed
            || deleted
            || pinnedInstance
            || (communityContext != nil && pinnedCommunity)
            || locked
        
        return postTag(active: removed, icon: .lemmy.removed, color: .themedNegative) +
            postTag(active: deleted, icon: .general.delete, color: .themedNegative) +
            postTag(active: pinnedInstance, icon: .lemmy.pinned, color: .themedAdministration) +
            postTag(active: pinnedCommunity && communityContext != nil, icon: .lemmy.pinned, color: .themedModeration) +
            postTag(active: locked, icon: .lemmy.locked, color: .themedLockAccent) +
            Text(verbatim: "\(hasTags ? "  " : "")\(title)")
    }
    
    /// Host if this is a link post, otherwise nil.
    var linkHost: String? {
        if case let .link(link) = type {
            return link.host
        }
        return nil
    }
    
    var imageFallback: MediaView.Fallback {
        switch type {
        case .text: .text
        case let .media(url), let .embedded(url, _):
            url.proxyAwarePathExtension?.isMovieExtension ?? false ? .movie : .image
        case .link: .link
        case .titleOnly: .titleOnly
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
    
    func crossPostAction() -> BasicAction {
        .init(
            id: "crosspost\(uid)",
            appearance: .crossPost(),
            callback: {
                var crossPostContent: String = .init(localized: "Crossposted from \(self.actorId.description)")
                if let content = self.content {
                    crossPostContent += "\n-----\n\(content)"
                }
                NavigationModel.main.openSheet(.createPost(
                    community: nil as AnyCommunity?,
                    title: self.title,
                    content: crossPostContent,
                    url: self.linkUrl,
                    nsfw: self.nsfw,
                    feedLoader: .init(wrappedValue: nil)
                ))
            }
        )
    }
    
    func hideAction(appState: AppState, feedback: Set<FeedbackType>) -> BasicAction {
        let hidden = hidden_ ?? false
        let available = (api.supportsOrNil(.hidePosts) ?? true) && api.canInteract(appState: appState)
        return .init(
            id: "hide\(uid)",
            appearance: .hide(isOn: hidden),
            callback: available ? { @MainActor in self.self2?.toggleHidden(feedback: feedback) } : nil
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
            blockCreatorAction(appState: appState, feedback: feedback, showConfirmation: false)
            blockCommunityAction(appState: appState, feedback: feedback, showConfirmation: false)
        }
    }
    
    func blockCommunityAction(appState: AppState, feedback: Set<FeedbackType> = [], showConfirmation: Bool = true) -> BasicAction {
        .init(
            id: "blockCommunity\(actorId.description)",
            appearance: .init(
                label: "Block Community",
                isOn: false,
                isDestructive: true,
                color: .themedNegative,
                icon: Icons.block
            ),
            confirmationPrompt: showConfirmation ? "Really block this community?" : nil,
            callback: api.canInteract(appState: appState) ? { @MainActor in self.self2?.community.toggleBlocked(feedback: feedback) } : nil
        )
    }
    
    func editAction(appState: AppState) -> BasicAction {
        .init(
            id: "edit\(uid)",
            appearance: .edit(),
            callback: api.canInteract(appState: appState) ? showEditSheet : nil
        )
    }
    
    func lockAction(appState: AppState, feedback: Set<FeedbackType> = []) -> BasicAction {
        .init(
            id: "lock\(uid)",
            appearance: .lock(isOn: locked, isInProgress: !lockedManager.isInSync),
            confirmationPrompt: locked ? "Really unlock this post?" : "Really lock this post?",
            callback: api.canInteract(appState: appState) && canModerate ? { @MainActor in
                self.self2?.toggleLocked(feedback: feedback)
            } : nil
        )
    }
    
    func pinAction(appState: AppState, feedback: Set<FeedbackType> = []) -> ActionGroup {
        .init(
            appearance: .pin(isOn: false, isInProgress: !(pinnedCommunityManager.isInSync && pinnedInstanceManager.isInSync)),
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
        let isOn = self2?.pinnedCommunity ?? false
        let prompt: LocalizedStringResource?
        if showConfirmation {
            if let communityName = community_?.name {
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
                isOn: isOn, isInProgress: !pinnedCommunityManager.isInSync
            ) : .pin(
                isOn: isOn, isInProgress: !pinnedCommunityManager.isInSync
            ),
            confirmationPrompt: prompt,
            callback: api.canInteract(appState: appState) && canModerate ? { @MainActor in
                self.togglePinnedCommunity(feedback: feedback)
            } : nil
        )
    }
    
    func pinToInstanceAction(appState: AppState, feedback: Set<FeedbackType> = [], showConfirmation: Bool = true) -> BasicAction {
        let isOn = self2?.pinnedInstance ?? false
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
            appearance: .pinToInstance(isOn: isOn, isInProgress: !pinnedInstanceManager.isInSync),
            confirmationPrompt: prompt,
            callback: api.canInteract(appState: appState) && api.isAdmin ? { @MainActor in
                self.togglePinnedInstance(feedback: feedback)
            } : nil
        )
    }
    
    func viewVotesAction(navigation: NavigationLayer) -> BasicAction {
        let enabled = canModerate && (api.isAdmin || (api.supportsOrNil(.moderatorsCanViewVotes) ?? true))
        return .init(
            id: "viewVotes\(uid)",
            appearance: .viewVotes(),
            callback: enabled ? { @MainActor in navigation.push(.votesList(.post(self))) } : nil
        )
    }
    // swiftlint:disable:next file_length
}
