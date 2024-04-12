//
//  MessageReportModel.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-04.
//

import Dependencies
import Foundation

class MessageReportModel: ContentIdentifiable, ObservableObject {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.errorHandler) var errorHandler
    
    var reporter: UserModel
    var resolver: UserModel?
    @Published var messageCreator: UserModel
    @Published var messageReport: APIPrivateMessageReport
    
    var uid: ContentModelIdentifier { .init(contentType: .messageReport, contentId: messageReport.id) }
    
    init(
        reporter: UserModel,
        resolver: UserModel?,
        messageCreator: UserModel,
        messageReport: APIPrivateMessageReport
    ) {
        self.reporter = reporter
        self.resolver = resolver
        self.messageCreator = messageCreator
        self.messageReport = messageReport
    }
    
    @MainActor
    func reinit(from messageReport: MessageReportModel) {
        reporter = messageReport.reporter
        resolver = messageReport.resolver
        messageCreator = messageReport.messageCreator
        self.messageReport = messageReport.messageReport
    }
    
    func toggleResolved(withHaptic: Bool = true) async {
        if withHaptic {
            hapticManager.play(haptic: .lightSuccess, priority: .high)
        }
        
        do {
            let response = try await apiClient.markPrivateMessageReportResolved(
                reportId: messageReport.id,
                resolved: !messageReport.resolved
            )
            await reinit(from: response)
        } catch {
            errorHandler.handle(error)
        }
    }
    
    func toggleMessageCreatorBanned(modToolTracker: ModToolTracker, inboxTracker: InboxTracker) {
        modToolTracker.banUser(
            messageCreator,
            bannedFromCommunity: false,
            shouldBan: !messageCreator.banned,
            userRemovalWalker: .init(inboxTracker: inboxTracker)
        ) {
            if !self.messageReport.resolved {
                Task(priority: .userInitiated) {
                    await self.toggleResolved(withHaptic: false)
                }
            }
        }
    }
    
    func genMenuFunctions(modToolTracker: ModToolTracker, inboxTracker: InboxTracker) -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        
        ret.append(.toggleableMenuFunction(
            toggle: creatorBannedFromInstance,
            trueText: "Unban",
            trueImageName: Icons.instanceUnban,
            falseText: "Ban",
            falseImageName: Icons.instanceBan
        ) {
            self.toggleMessageCreatorBanned(modToolTracker: modToolTracker, inboxTracker: inboxTracker)
        })
        
        ret.append(.toggleableMenuFunction(
            toggle: messageReport.resolved,
            trueText: "Unresolve",
            trueImageName: Icons.unresolve,
            falseText: "Resolve",
            falseImageName: Icons.resolve
        ) {
            Task(priority: .userInitiated) {
                await self.toggleResolved()
            }
        })
        
        return ret
    }
}

extension MessageReportModel: Hashable, Equatable {
    static func == (lhs: MessageReportModel, rhs: MessageReportModel) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(reporter)
        hasher.combine(resolver)
        hasher.combine(messageCreator)
        hasher.combine(messageReport)
    }
}
