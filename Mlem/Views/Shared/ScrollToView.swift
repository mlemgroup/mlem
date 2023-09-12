//
//  ScrollToView.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-09-12.
//

import SwiftUI

/// To enable scroll to behaviour: Assign a @Namespace id, and place this view inside a scroll view in the desired position.
///
/// This view is not visible to users.
/// - Warning: Do not set this view to hidden.
struct ScrollToView: View {
    
    @Binding var appeared: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            EmptyView()
        }
        .frame(height: 1)
        .onAppear {
            appeared = true
        }
        .onDisappear {
            appeared = false
        }
    }
}
