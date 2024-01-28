//
//  EditorModelProtocol.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation
import SwiftUI

/// Protocol for things that can be responded to--e.g., with a comment or a report
protocol ResponseEditorModel: Identifiable {
    var id: Int { get }
    
    var canUpload: Bool { get } // whether the response can include uploaded images
    
    var modalName: String { get } // what to title the modal
    
    var showSlurWarning: Bool { get }
    
    var prefillContents: String? { get } // optional, contents to prepopulate the editor with
    
    func embeddedView() -> AnyView
    
    func sendResponse(responseContents: String) async throws
}
