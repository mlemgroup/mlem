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
    @Dependency(\.errorHandler) var errorHandler
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
    
    /// Re-initializes all fields to match the given MessageModel
    func reinit(from messageModel: MessageModel) {
        creator = messageModel.creator
        recipient = messageModel.recipient
        privateMessage = messageModel.privateMessage
    }
    
    func toggleRead() async {
        hapticManager.play(haptic: .gentleSuccess, priority: .low)
        
        // store original state
        let originalPrivateMessage = APIPrivateMessage(from: privateMessage)
        
        // state fake
        await MainActor.run {
            self.privateMessage = APIPrivateMessage(from: self.privateMessage, read: !self.privateMessage.read)
        }
        
        // call API
        do {
            let newMessage = try await inboxRepository.markMessageRead(id: privateMessage.id, isRead: privateMessage.read)
            await MainActor.run {
                self.reinit(from: newMessage)
            }
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
            await MainActor.run {
                self.privateMessage = originalPrivateMessage
            }
        }
    }
    
    func menuFunctions() -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        
        // mark read
        let (markReadText, markReadImg) = privateMessage.read ?
            ("Mark unread", "envelope.fill") :
            ("Mark read", "envelope.open")
        ret.append(MenuFunction.standardMenuFunction(
            text: markReadText,
            imageName: markReadImg,
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await self.toggleRead()
            }
        })
        
        return ret
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
