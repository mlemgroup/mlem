//
//  UnifiedPostModel+Actions.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-01-03.
//

import MlemMiddleware

extension UnifiedPostModel {
    var downvotesEnabled: Bool {
        api.voteFederationMode.postDownvote != .disable
    }
    
    // MARK: - Actions
    
    func upvoteAction(appState: AppState, feedback: Set<FeedbackType> = []) -> BasicAction? {
        if let toggleUpvoted, let votes = votes.value {
            return .init(id: "upvote\(actorId)",
                         appearance: .upvote(isOn: votes.myVote == .upvote),
                         callback: { toggleUpvoted(feedback) }
            )
        }
        return nil
    }
    
    func downvoteAction(appState: AppState, feedback: Set<FeedbackType> = []) -> BasicAction? {
        if let toggleDownvoted, let votes = votes.value {
            let enabled = api.canInteract(appState: appState) && downvotesEnabled
            let callback = enabled ? { toggleDownvoted(feedback) } : nil
            return .init(
                id: "downvote\(actorId)",
                appearance: .downvote(isOn: votes.myVote == .downvote),
                callback: callback
            )
        }
        return nil
    }
    
    func saveAction(appState: AppState, feedback: Set<FeedbackType> = []) -> BasicAction? {
        if let toggleSaved, let saved = saved.value {
            let callback = api.canInteract(appState: appState) ? { toggleSaved(feedback) } : nil
            return .init(
                id: "save\(actorId)",
                appearance: .save(isOn: saved),
                callback: callback
            )
        }
        return nil
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
            //        case .reply:
            //            <#code#>
            //        case .share:
            //            <#code#>
            //        case .selectText:
            //            <#code#>
            //        case .hide:
            //            <#code#>
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
