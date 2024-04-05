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
