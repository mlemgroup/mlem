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
    func swipeActions(behavior: SwipeBehavior) -> SwipeConfiguration {
        let leadingActions: [BasicAction] = api.willSendToken ? [
            upvoteAction(feedback: [.haptic]),
            downvoteAction(feedback: [.haptic])
        ] : .init()
        let trailingActions: [BasicAction] = api.willSendToken ? [
            saveAction(feedback: [.haptic])
        ] : .init()
        
        return .init(leadingActions: leadingActions, trailingActions: trailingActions, behavior: behavior)
    }
    
    func menuActions(feedback: Set<FeedbackType> = []) -> ActionGroup {
        ActionGroup(
            children: [
                ActionGroup(
                    children: [upvoteAction(feedback: feedback), downvoteAction(feedback: feedback)]
                ),
                saveAction(feedback: feedback)
            ])
    }
    
    func action(type: PostActionType, feedback: Set<FeedbackType> = []) -> any Action {
        switch type {
        case .upvote:
            upvoteAction(feedback: feedback)
        case .downvote:
            downvoteAction(feedback: feedback)
        case .save:
            saveAction(feedback: feedback)
        }
    }
    
    func counter(type: PostCounterType) -> Counter {
        switch type {
        case .score:
            scoreCounter
        case .upvote:
            upvoteCounter
        case .downvote:
            downvoteCounter
        }
    }
    
    func readout(type: PostReadoutType) -> Readout {
        switch type {
        case .created:
            createdReadout
        case .score:
            scoreReadout
        case .upvote:
            upvoteReadout
        case .downvote:
            downvoteReadout
        case .comment:
            commentReadout
        }
    }
    
    func taggedTitle(communityContext: (any Community1Providing)?) -> Text {
        let hasTags: Bool = removed
            || pinnedInstance
            || (communityContext != nil && pinnedCommunity)
            || locked
        
        return postTag(active: removed, icon: Icons.removeFill, color: Palette.main.negative) +
            postTag(active: pinnedInstance, icon: Icons.pinFill, color: Palette.main.administration) +
            postTag(active: communityContext != nil && pinnedCommunity, icon: Icons.pinFill, color: Palette.main.moderation) +
            postTag(active: locked, icon: Icons.lockFill, color: Palette.main.secondaryAccent) +
            Text("\(hasTags ? "  " : "")\(title)")
    }
    
    var linkHost: String? {
        guard case .link = type else {
            return nil
        }
        
        if var host = linkUrl?.host() {
            host.trimPrefix("www.")
            return host
        }
        return "website"
    }
    
    var placeholderImageName: String {
        switch type {
        case .text:
            Icons.textPost
        case .image:
            Icons.photo
        case .link:
            Icons.websiteIcon
        case .titleOnly:
            Icons.titleOnlyPost
        }
    }
}
