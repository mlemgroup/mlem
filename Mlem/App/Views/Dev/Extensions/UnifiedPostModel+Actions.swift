//
//  UnifiedPostModel+Actions.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-01-03.
//

import MlemMiddleware
import Foundation
import os

// TODO: NOW be consistent about how feedback is passed in

extension UnifiedPostModel {
    var downvotesEnabled: Bool {
        api.voteFederationMode.postDownvote != .disable
    }
    
    var canModerate: Bool {
        api.myPerson?.moderates(communityId: communityId) ?? false || api.isAdmin
    }
    
    // MARK: - Actions
    
    func upvoteAction(appState: AppState, feedback: Set<FeedbackType> = []) -> BasicAction? {
        guard let toggleUpvoted, let votes = votes.value else { return nil }
        return .init(id: "upvote\(actorId)",
                     appearance: .upvote(isOn: votes.myVote == .upvote),
                     callback: { toggleUpvoted(feedback) }
        )
    }
    
    func downvoteAction(appState: AppState, feedback: Set<FeedbackType> = []) -> BasicAction? {
        guard api.canInteract(appState: appState) && downvotesEnabled,
              let toggleDownvoted, let votes = votes.value else { return nil }
        return .init(
            id: "downvote\(actorId)",
            appearance: .downvote(isOn: votes.myVote == .downvote),
            callback: { toggleDownvoted(feedback) }
        )
    }
    
    func saveAction(appState: AppState, feedback: Set<FeedbackType> = []) -> BasicAction? {
        guard api.canInteract(appState: appState),
              let toggleSaved, let saved = saved.value else { return nil }
        return .init(
            id: "save\(actorId)",
            appearance: .save(isOn: saved),
            callback: { toggleSaved(feedback) }
        )
    }
    
    func hideAction(appState: AppState, feedback: Set<FeedbackType>)  -> BasicAction? {
        guard api.supports(.hidePosts, defaultValue: true) && api.canInteract(appState: appState),
              let hidden = hidden.value, let toggleHidden = toggleHidden else { return nil }
        return .init(
            id: "hide\(uid)",
            appearance: .hide(isOn: hidden),
            callback: { toggleHidden(feedback) }
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
                    community: nil as AnyCommunity?,
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
    
    func viewVotesAction(navigation: NavigationLayer) -> BasicAction? {
        guard canModerate && api.supports(.viewVotes, defaultValue: true) else { return nil }
        return .init(
            id: "viewVotes\(uid)",
            appearance: .viewVotes(),
            callback: { @MainActor in navigation.push(.votesList(.post(self))) }
        )
    }
    
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
        case .downvote: downvoteAction(appState: appState, feedback: feedback)
        case .save: saveAction(appState: appState, feedback: feedback)
        case .reply: replyAction(appState: appState, commentTreeTracker: commentTreeTracker)
        case .share: shareAction(navigation: navigation)
        case .selectText: selectTextAction()
        case .hide: hideAction(appState: appState, feedback: feedback)
            //        case .block:
            //            <#code#>
            //        case .report:
            //            <#code#>
        case .crossPost: crossPostAction()
        case .lock: lockAction(appState: appState, feedback: feedback)
        case .pin: api.isAdmin ? pinAction(
                appState: appState,
                feedback: feedback
            ) : pinToCommunityAction(
                appState: appState,
                feedback: feedback
            )
            //        case .resolve:
            //            <#code#>
            //        case .remove:
            //            <#code#>
            //        case .ban:
            //            <#code#>
        default: nil
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
            // case .created: createdReadout
            // swiftlint:disable:next void_function_in_ternary
            // case .score: downvotesEnabled ? scoreReadout(showColor: showColor) : upvoteReadout(showColor: showColor)
        case .upvote: upvoteReadout(showColor: showColor)
        case .downvote: downvotesEnabled ? downvoteReadout(showColor: showColor) : nil
        default: nil
            // case .comment: commentReadout
            // case .saved: savedReadout(showColor: showColor)
        }
    }
    
    // MARK: - Counters
    
    func counter(
        appState: AppState,
        type: PostBarConfiguration.CounterType,
        commentTreeTracker: CommentTreeTracker? = nil
    ) -> Counter? {
        return nil
        //        switch type {
        //        case .score: scoreCounter(appState: appState, downvotesEnabled: downvotesEnabled)
        //        case .upvote: upvoteCounter(appState: appState)
        //        case .downvote: downvotesEnabled ? downvoteCounter(appState: appState, downvotesEnabled: downvotesEnabled) : nil
        //        case .reply: replyCounter(appState: appState, commentTreeTracker: commentTreeTracker)
        //        }
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
            if let replyAction = replyAction(appState: appState, commentTreeTracker: commentTreeTracker) { replyAction }
            if !deleted {
                selectTextAction()
            }
            shareAction(navigation: navigation)
            
            if expanded, let navigation {
                createImageAction(navigation: navigation)
            }
            
            if isOwnPost, let navigation, let editAction = editAction(appState: appState, navigation: navigation) {
                editAction
            }
            //                deleteAction(appState: appState, feedback: feedback)
            //            } else {
            //                if api.supports(.hidePosts, defaultValue: true) {
            //                    hideAction(appState: appState, feedback: feedback)
            //                }
            //                if !canModerate, !deleted {
            //                    reportAction(appState: appState)
            //                }
            //                blockAction(appState: appState, feedback: feedback)
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
            if let lockAction = lockAction(appState: appState, feedback: feedback) { lockAction }
//
//            if setNsfwIsAvailable(appState: appState) {
//                setNsfwAction(appState: appState)
//            }
//
            if let navigation,
               api.supports(.viewVotes, defaultValue: false),
               let viewVotesAction = viewVotesAction(navigation: navigation) {
                viewVotesAction
            }
//        }
//        if let self2, !isOwnPost {
//            self2.removeAction(appState: appState).disabled(!canModerate)
//            self2.creator.banActions(appState: appState, community: self2.community, withUserLabel: true)
//        }
//        if api.isAdmin, api.supports(.purgeContent, defaultValue: false) {
//            purgeAction(appState: appState)
//            if !isOwnPost {
//                purgeCreatorAction(appState: appState)
//            }
//        }
//        if let report {
//            ActionGroup {
//                report.menuActions(appState: appState)
//            }
        }
    }
}
