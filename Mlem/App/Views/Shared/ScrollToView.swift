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
/// - Note: Use `ListScrollToView` in `List`.
/// - Warning: Do not set this view to hidden.
struct ScrollToView: View {
    @Binding var appeared: Bool

    var body: some View {
        /// We don't have any horizontal scroll views yet, but this may need to be a LazyHStack if we do. [2023.09]
        LazyVStack(spacing: 0) {
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
}

/// For use inside `List`.
///
/// See also: `ScrollToView`.
struct ListScrollToView: View {
    @Binding var appeared: Bool

    var body: some View {
        /// We don't have any horizontal scroll views yet, but this may need to be a LazyHStack if we do. [2023.09]
        LazyVStack(spacing: 0) {
            EmptyView()
                .frame(height: 1)
                .onAppear {
                    appeared = true
                }
                .onDisappear {
                    appeared = false
                }
        }
    }
}
