//
//  ReplyToProtocol.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation
import SwiftUI

/**
 Protocol for things that can be responded to--e.g., with a comment or a report
 */
protocol Respondable: Identifiable {
    var id: Int { get }
    
    var appState: AppState { get }
    
    var canUpload: Bool { get } // whether the response can include uploaded images
    
    var modalName: String { get } // what to title the modal
    
    func embeddedView() -> AnyView
    
    func sendResponse(responseContents: String) async throws
}
