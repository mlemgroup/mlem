//
//  UnifiedPostModel+Actions.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-01-03.
//

import MlemMiddleware
import Foundation

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
    
    // TODO: NOW make this generic in new Interactable
    func replyAction(appState: AppState, commentTreeTracker: CommentTreeTracker? = nil) -> BasicAction? {
        guard api.canInteract(appState: appState) else { return nil }
        return .init(
            id: "reply\(actorId)",
            appearance: .reply(),
            callback: { @MainActor in
                NavigationModel.main.openSheet(.createComment(.unifiedPost(self), commentTreeTracker: commentTreeTracker))
            }
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
            //        case .crossPost:
            //            <#code#>
            //        case .lock:
            //            <#code#>
            //        case .pin:
            //            <#code#>
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
}
