//
//  ReportMessage.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-15.
//

import Foundation
import SwiftUI

struct ReportMessage: Respondable {
    
    var id: Int { message.id }
    let appState: AppState
    let canUpload: Bool = false
    let modalName: String = "Report Message"
    let message: APIPrivateMessageView
    
    func embeddedView() -> AnyView {
        return AnyView(InboxMessageView(message: message, menuFunctions: [])
            .padding(.horizontal))
    }
    
    func sendResponse(responseContents: String) async throws {
        _ = try await reportMessage(messageId: message.id, reason: responseContents, appState: appState)
    }
}
