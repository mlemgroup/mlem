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

    func toggleHidden(feedback: Set<FeedbackType>) {
        if let self2 {
            if feedback.contains(.haptic) {
                HapticManager.main.play(haptic: .lightSuccess, priority: .low)
            }
            if feedback.contains(.toast) {
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
            self2.toggleHidden()
        } else {
            print("DEBUG no self2 found in toggleHidden!")
        }
    }
    
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
            
            // If no version has been fetched yet, assume they're on <0.19.4 for now.
            // Once 0.19.4 is widely adopted we could assume they're on >=0.19.4.
            if (api.fetchedVersion ?? .zero) >= .v19_4 {
                hideAction(feedback: feedback)
            }

            if self.isOwnPost {
                deleteAction(feedback: feedback)
            } else {
                blockAction(feedback: feedback)
            }
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
        case .hide:
            hideAction(feedback: feedback)
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
            || deleted
            || pinnedInstance
            || (communityContext != nil && pinnedCommunity)
            || locked
        
        return postTag(active: removed, icon: Icons.removeFill, color: Palette.main.negative) +
            postTag(active: deleted, icon: Icons.delete, color: Palette.main.negative) +
            postTag(active: pinnedInstance, icon: Icons.pinFill, color: Palette.main.administration) +
            postTag(active: communityContext != nil && pinnedCommunity, icon: Icons.pinFill, color: Palette.main.moderation) +
            postTag(active: locked, icon: Icons.lockFill, color: Palette.main.lockAccent) +
            Text(verbatim: "\(hasTags ? "  " : "")\(title)")
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
    
    func hideAction(feedback: Set<FeedbackType>) -> BasicAction {
        let hidden = hidden_ ?? false
        return .init(
            id: "hide\(uid)",
            isOn: hidden,
            label: hidden ? "Show" : "Hide",
            color: .gray,
            icon: hidden ? Icons.show : Icons.hide,
            callback: api.willSendToken ? { self.self2?.toggleHidden(feedback: feedback) } : nil
        )
    }
    
    func blockAction(feedback: Set<FeedbackType>) -> ActionGroup {
        .init(
            label: "Block...",
            prompt: "Block User or Community?",
            color: Palette.main.negative,
            isDestructive: true,
            icon: Icons.block,
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
            icon: Icons.block,
            callback: api.willSendToken ? { self.self2?.community.toggleBlocked(feedback: feedback) } : nil
        )
    }
}
