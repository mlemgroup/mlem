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
    func menuActions(
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
            
            // If no version has been fetched yet, assume they're on <0.19.4 for now.
            // Once 0.19.4 is widely adopted we could assume they're on >=0.19.4.
            // See also the identical check within `hideAction` itself.
            if (api.fetchedVersion ?? .zero) >= .v19_4 {
                hideAction(feedback: feedback)
            }

            if self.isOwnPost {
                editAction()
                deleteAction(feedback: feedback)
            } else {
                reportAction()
                blockAction(feedback: feedback)
            }
        }
    }
    
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
            postTag(active: communityContext != nil && pinnedCommunity, icon: Icons.pinFill, color: Palette.main.moderation) +
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
}
