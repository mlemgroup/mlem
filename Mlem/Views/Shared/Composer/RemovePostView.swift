//
//  RemovePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27.
//

import Dependencies
import SwiftUI

struct RemovePostView: View {
    @Dependency(\.apiClient) var apiClient
    
    @State var reason: String
    @FocusState var reasonFocused: FocusedField?
    
    var body: some View {
        form
            .onAppear {
                reasonFocused = .reason
            }
    }
    
    var form: some View {
        Form {
            ReasonView(reason: $reason, focusedField: $reasonFocused, showReason: true)
        }
    }
}
