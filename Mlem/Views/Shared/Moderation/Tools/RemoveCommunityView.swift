//
//  RemoveCommunityView.swift
//  Mlem
//
//  Created by Sjmarf on 16/03/2024.
//

import Dependencies
import Foundation
import SwiftUI

struct RemoveCommunityView: View {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.notifier) var notifier
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.siteInformation) var siteInformation
    
    @Environment(\.dismiss) var dismiss
    
    @State var reason: String = ""
    @FocusState var reasonFocused: FocusedField?
    @State var isWaiting: Bool = false
    
    let community: CommunityModel
    let shouldRemove: Bool
    
    var verb: String { shouldRemove ? "Remove" : "Restore" }
    
    var body: some View {
        Form {
            ReasonView(reason: $reason, focusedField: $reasonFocused, showReason: shouldRemove)
        }
        .onAppear {
            reasonFocused = .reason
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") { reasonFocused = nil }
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .tint(.red)
                .disabled(isWaiting)
            }
            ToolbarItem(placement: .topBarTrailing) {
                if isWaiting {
                    ProgressView()
                } else {
                    Button("Confirm", systemImage: Icons.send, action: confirm)
                }
            }
        }
        .allowsHitTesting(!isWaiting)
        .opacity(isWaiting ? 0.5 : 1)
        .interactiveDismissDisabled(isWaiting)
        .navigationTitle("\(verb) Community")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func confirm() {
        isWaiting = true
        
        Task {
            await community.toggleRemove(reason: reason.isEmpty ? nil : reason) { community in
                Task {
                    if community.removed == shouldRemove {
                        await notifier.add(.success("\(verb)d community"))
                        DispatchQueue.main.async {
                            dismiss()
                        }
                    } else {
                        DispatchQueue.main.async {
                            isWaiting = false
                        }
                    }
                }
            } onFailure: {
                DispatchQueue.main.async {
                    isWaiting = false
                }
            }
        }
    }
}
