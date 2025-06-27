//
//  NewSearchSheet.swift
//  Mlem
//
//  Created by Sjmarf on 2025-06-27.
//

import ComponentViews
import SwiftUI

struct NewSearchSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @State var fadeIn: Bool = false
    
    @State var query: String = ""
    
    var body: some View {
        ScrollView {}
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .overlay(alignment: .bottom) {
                overlayView
                    .padding(16)
            }
            .safeAreaInset(edge: .top) {
                CloseButtonView()
            }
            .keyboardAwarePadding(removePaddingOnDismiss: false)
            .compositingGroup()
            .opacity(fadeIn ? 1 : 0)
            .onAppear {
                withAnimation(.easeOut(duration: 0.2)) {
                    fadeIn = true
                }
            }
            .presentationBackground(.clear)
    }
    
    @ViewBuilder
    var overlayView: some View {
        HStack(spacing: 16) {
            HStack {
                Image(icon: .general.search)
                    .foregroundStyle(.secondary)
                TextField("Search", text: $query)
                    .introspect(.textField, on: .iOS(.v17, .v18)) { textField in
                        textField.becomeFirstResponder()
                    }
            }
            .onAppear {
                DispatchQueue.main.async {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.becomeFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }
            }
            .frame(height: 50)
            .padding(.horizontal)
            .background(.background, in: .capsule)
        }
        .scrollDismissesKeyboard(.interactively)
        .compositingGroup()
        .shadow(color: .black.opacity(0.2), radius: 15)
    }
}
