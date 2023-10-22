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
struct MessageModel: ContentIdentifiable {
    @Dependency(\.inboxRepository) var inboxRepository
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.hapticManager) var hapticManager
    
    var creator: APIPerson
    var recipient: APIPerson
    var privateMessage: APIPrivateMessage

    var uid: ContentModelIdentifier { .init(contentType: .message, contentId: privateMessage.id) }

    /// Creates a MessageModel from the raw APIPrivateMessageView returned by the Lemmy API
    /// - Parameter from: APIPrivateMessageView returned by the Lemmy API
    init(from apiPrivateMessageView: APIPrivateMessageView) {
        self.creator = apiPrivateMessageView.creator
        self.recipient = apiPrivateMessageView.recipient
        self.privateMessage = apiPrivateMessageView.privateMessage
    }
    
    mutating func toggleRead(_ updateTracker: @escaping (_ item: Self) -> Void = { _ in }) async {
        hapticManager.play(haptic: .gentleSuccess, priority: .low)
        
        // store original state
        let originalPrivateMessage = APIPrivateMessage(from: privateMessage)
        
        // state fake
        privateMessage = APIPrivateMessage(from: privateMessage, read: !privateMessage.read)
        RunLoop.main.perform { [self] in
            updateTracker(self)
        }
        
        // call API
        do {
            // if call succeeds, udpate tracker with result of call, discarding
            let newMessage = try await inboxRepository.markMessageRead(id: privateMessage.id, isRead: privateMessage.read)
            RunLoop.main.perform {
                updateTracker(newMessage)
            }
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
            
            // revert state fake
            privateMessage = originalPrivateMessage
            RunLoop.main.perform { [self] in
                updateTracker(self)
            }
        }
    }
    
    func menuFunctions(_ updateTracker: @escaping (_ item: Self) -> Void = { _ in }) -> [MenuFunction] {
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
                var new = self
                await new.toggleRead(updateTracker)
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
