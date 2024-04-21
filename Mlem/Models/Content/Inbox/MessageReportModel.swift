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
    
    func toggleResolved(unreadTracker: UnreadTracker, withHaptic: Bool = true) async {
        let originalReadState: Bool = read
        
        if withHaptic {
            hapticManager.play(haptic: .lightSuccess, priority: .high)
        }
        
        do {
            let response = try await apiClient.markPrivateMessageReportResolved(
                reportId: messageReport.id,
                resolved: !messageReport.resolved
            )
            await reinit(from: response)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                unreadTracker.messageReports.toggleRead(originalState: originalReadState)
            }
        } catch {
            errorHandler.handle(error)
        }
    }
    
    func toggleMessageCreatorBanned(modToolTracker: ModToolTracker, inboxTracker: InboxTracker, unreadTracker: UnreadTracker) {
        modToolTracker.banUser(
            messageCreator,
            bannedFromCommunity: false,
            shouldBan: !messageCreator.banned,
            userRemovalWalker: .init(inboxTracker: inboxTracker)
        ) {
            if !self.messageReport.resolved {
                Task(priority: .userInitiated) {
                    await self.toggleResolved(unreadTracker: unreadTracker, withHaptic: false)
                }
            }
        }
    }
    
    func genMenuFunctions(modToolTracker: ModToolTracker, inboxTracker: InboxTracker, unreadTracker: UnreadTracker) -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        
        ret.append(.toggleableMenuFunction(
            toggle: creatorBannedFromInstance,
            trueText: "Unban",
            trueImageName: Icons.instanceUnban,
            falseText: "Ban",
            falseImageName: Icons.instanceBan
        ) {
            self.toggleMessageCreatorBanned(modToolTracker: modToolTracker, inboxTracker: inboxTracker, unreadTracker: unreadTracker)
        })
        
        ret.append(.toggleableMenuFunction(
            toggle: messageReport.resolved,
            trueText: "Unresolve",
            trueImageName: Icons.unresolve,
            falseText: "Resolve",
            falseImageName: Icons.resolve
        ) {
            Task(priority: .userInitiated) {
                await self.toggleResolved(unreadTracker: unreadTracker)
            }
        })
        
        return ret
    }
    
    func swipeActions(
        modToolTracker: ModToolTracker,
        inboxTracker: InboxTracker,
        unreadTracker: UnreadTracker
    ) -> SwipeConfiguration {
        var leadingActions: [SwipeAction] = .init()
        var trailingActions: [SwipeAction] = .init()
        
        leadingActions.append(SwipeAction(
            symbol: .init(
                emptyName: read ? Icons.resolveFill : Icons.resolve,
                fillName: read ? Icons.resolve : Icons.resolveFill
            ),
            color: .green
        ) {
            Task(priority: .userInitiated) {
                await self.toggleResolved(unreadTracker: unreadTracker)
            }
        })
        
        trailingActions.append(SwipeAction(
            symbol: .init(
                emptyName: creatorBannedFromInstance ? Icons.instanceUnban : Icons.instanceBan,
                fillName: creatorBannedFromInstance ? Icons.instanceUnbanned : Icons.instanceBanned
            ),
            color: .red
        ) {
            self.toggleMessageCreatorBanned(
                modToolTracker: modToolTracker,
                inboxTracker: inboxTracker,
                unreadTracker: unreadTracker
            )
        })
        
        return SwipeConfiguration(leadingActions: leadingActions, trailingActions: trailingActions)
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
