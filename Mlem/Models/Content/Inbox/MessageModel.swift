//
//  MessageModel.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-23.
//

import Dependencies
import Foundation

/**
 Internal model to represent a private message.
 
 Note: To make the transition to internal models smoother, this is currently identical to APIPrivateMessageView
 */
class MessageModel: ContentIdentifiable, ObservableObject {
    @Dependency(\.inboxRepository) var inboxRepository
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.notifier) var notifier
    @Dependency(\.hapticManager) var hapticManager
    
    @Published var creator: APIPerson
    @Published var recipient: APIPerson
    @Published var privateMessage: APIPrivateMessage

    var uid: ContentModelIdentifier { .init(contentType: .message, contentId: privateMessage.id) }

    /// Creates a MessageModel from the raw APIPrivateMessageView returned by the Lemmy API
    /// - Parameter from: APIPrivateMessageView returned by the Lemmy API
    init(from apiPrivateMessageView: APIPrivateMessageView) {
        self.creator = apiPrivateMessageView.creator
        self.recipient = apiPrivateMessageView.recipient
        self.privateMessage = apiPrivateMessageView.privateMessage
    }
    
    // MARK: Main actor actions
    
    /// Re-initializes all fields to match the given MessageModel
    @MainActor
    func reinit(from messageModel: MessageModel) {
        creator = messageModel.creator
        recipient = messageModel.recipient
        privateMessage = messageModel.privateMessage
    }
    
    @MainActor
    func setPrivateMessage(_ privateMessage: APIPrivateMessage) {
        self.privateMessage = privateMessage
    }
    
    func toggleRead(unreadTracker: UnreadTracker) async {
        hapticManager.play(haptic: .gentleSuccess, priority: .low)
        
        // store original state
        let originalPrivateMessage = APIPrivateMessage(from: privateMessage)
        
        // state fake
        await setPrivateMessage(APIPrivateMessage(from: privateMessage, read: !privateMessage.read))
        await unreadTracker.toggleMessageRead(originalState: originalPrivateMessage.read)
        
        // call API and either update with latest info or revert state fake on fail
        do {
            let newMessage = try await inboxRepository.markMessageRead(id: privateMessage.id, isRead: privateMessage.read)
            await reinit(from: newMessage)
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
            await setPrivateMessage(originalPrivateMessage)
            await unreadTracker.toggleMessageRead(originalState: !originalPrivateMessage.read)
        }
    }
    
    @MainActor
    func reply(editorTracker: EditorTracker, unreadTracker: UnreadTracker) {
        editorTracker.openEditor(with: ConcreteEditorModel(
            message: self,
            operation: InboxItemOperation.replyToInboxItem
        ))
        
        // replying to a message marks it as read, but the call doesn't return anything so we just state fake it here
        if !privateMessage.read {
            setPrivateMessage(APIPrivateMessage(from: privateMessage, read: true))
            unreadTracker.readMessage()
        }
    }
    
    @MainActor
    func report(editorTracker: EditorTracker) {
        editorTracker.openEditor(with: ConcreteEditorModel(
            message: self,
            operation: InboxItemOperation.reportInboxItem
        ))
    }
    
    func blockUser(userId: Int) async {
        do {
            let response = try await apiClient.blockPerson(id: userId, shouldBlock: true)
            
            if response.blocked {
                hapticManager.play(haptic: .violentSuccess, priority: .high)
                await notifier.add(.success("Blocked user"))
            }
        } catch {
            errorHandler.handle(
                .init(
                    message: "Unable to block user",
                    style: .toast,
                    underlyingError: error
                )
            )
        }
    }
    
    // MARK: - Menu functions and swipe actions
    
    func menuFunctions(
        unreadTracker: UnreadTracker,
        editorTracker: EditorTracker
    ) -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        
        // mark read
        ret.append(MenuFunction.standardMenuFunction(
            text: privateMessage.read ? "Mark unread" : "Mark read",
            imageName: privateMessage.read ? Icons.markUnread : Icons.markRead,
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await self.toggleRead(unreadTracker: unreadTracker)
            }
        })
        
        // reply
        ret.append(MenuFunction.standardMenuFunction(
            text: "Reply",
            imageName: Icons.reply,
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await self.reply(editorTracker: editorTracker, unreadTracker: unreadTracker)
            }
        })
        
        // report
        ret.append(MenuFunction.standardMenuFunction(
            text: "Report",
            imageName: Icons.moderationReport,
            destructiveActionPrompt: AppConstants.reportMessagePrompt,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await self.report(editorTracker: editorTracker)
            }
        })
        
        // block
        ret.append(MenuFunction.standardMenuFunction(
            text: "Block User",
            imageName: Icons.userBlock,
            destructiveActionPrompt: AppConstants.blockUserPrompt,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await self.blockUser(userId: self.creator.id)
            }
        })
        
        return ret
    }
    
    func swipeActions(
        unreadTracker: UnreadTracker,
        editorTracker: EditorTracker
    ) -> SwipeConfiguration {
        var trailingActions: [SwipeAction] = .init()
        
        trailingActions.append(SwipeAction(
            symbol: .init(
                emptyName: privateMessage.read ? Icons.markUnreadFill : Icons.markReadFill,
                fillName: privateMessage.read ? Icons.markRead : Icons.markUnread
            ),
            color: .purple
        ) {
            Task(priority: .userInitiated) {
                await self.toggleRead(unreadTracker: unreadTracker)
            }
        })
        
        trailingActions.append(SwipeAction(
            symbol: .init(emptyName: Icons.reply, fillName: Icons.replyFill),
            color: .blue
        ) {
            Task(priority: .userInitiated) {
                await self.reply(editorTracker: editorTracker, unreadTracker: unreadTracker)
            }
        })
        
        return SwipeConfiguration(leadingActions: .init(), trailingActions: trailingActions)
    }
}

extension MessageModel: Hashable {
    /// Hashes all fields for which state changes should trigger view updates.
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
        hasher.combine(privateMessage.read)
        hasher.combine(privateMessage.updated)
    }
}

extension MessageModel: Identifiable {
    var id: Int { hashValue }
}

extension MessageModel: Equatable {
    static func == (lhs: MessageModel, rhs: MessageModel) -> Bool {
        lhs.id == rhs.id
    }
}
