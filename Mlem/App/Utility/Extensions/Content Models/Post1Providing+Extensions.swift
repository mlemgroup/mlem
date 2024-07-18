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
    
    func swipeActions(behavior: SwipeBehavior) -> SwipeConfiguration {
        .init(
            behavior: behavior,
            leadingActions: {
                if api.willSendToken {
                    upvoteAction(feedback: [.haptic])
                    downvoteAction(feedback: [.haptic])
                }
            },
            trailingActions: {
                if api.willSendToken {
                    saveAction(feedback: [.haptic])
                    replyAction()
                }
            }
        )
    }
    
    @ActionBuilder
    func menuActions(feedback: Set<FeedbackType> = [.haptic, .toast]) -> [any Action] {
        ActionGroup(displayMode: .compactSection) {
            upvoteAction(feedback: feedback)
            downvoteAction(feedback: feedback)
            saveAction(feedback: feedback)
            replyAction()
            selectTextAction()
            shareAction()
            blockAction(feedback: feedback)
        }
    }
    
    func action(type: PostActionType, feedback: Set<FeedbackType> = []) -> any Action {
        switch type {
        case .upvote:
            upvoteAction(feedback: feedback)
        case .downvote:
            downvoteAction(feedback: feedback)
        case .save:
            saveAction(feedback: feedback)
        case .reply:
            replyAction()
        case .share:
            shareAction()
        case .selectText:
            selectTextAction()
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
    
    // MARK: Actions
    
    func blockAction(feedback: Set<FeedbackType>) -> ActionGroup {
        .init(
            label: "Block...",
            prompt: "Block User or Community?",
            color: Palette.main.negative,
            isDestructive: true,
            icon: Icons.hide,
            disabled: !api.willSendToken,
            displayMode: .popup
        ) {
            blockCreatorAction(feedback: feedback, showConfirmation: false)
            blockCommunityAction(feedback: feedback, showConfirmation: false)
        }
    }
    
    func blockCommunityAction(feedback: Set<FeedbackType> = [], showConfirmation: Bool = true) -> BasicAction {
        .init(
            id: "blockCommunity\(actorId.absoluteString)",
            isOn: false,
            label: "Block Community",
            color: Palette.main.negative,
            isDestructive: true,
            confirmationPrompt: showConfirmation ? "Really block this community?" : nil,
            icon: Icons.hide,
            callback: api.willSendToken ? { self.self2?.community.toggleBlocked(feedback: feedback) } : nil
        )
    }
}
