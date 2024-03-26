//
//  PurgeContentView.swift
//  Mlem
//
//  Created by Sjmarf on 26/03/2024.
//

import Dependencies
import SwiftUI

protocol Purgable: ContentIdentifiable {
    mutating func purge(reason: String?) async -> Bool
}

struct PurgeContentView: View {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.notifier) var notifier
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.siteInformation) var siteInformation
    
    @Environment(\.dismiss) var dismiss
    
    @State var reason: String = ""
    @FocusState var reasonFocused: FocusedField?
    @State var isWaiting: Bool = false
    
    let content: any Purgable
    
    var title: String {
        if content is PostModel {
            return "Purge Post"
        }
        if content is HierarchicalComment {
            return "Purge Comment"
        }
        if content is UserModel {
            return "Purge User"
        }
        if content is CommunityModel {
            return "Purge Community"
        }
        return "Purge"
    }
    
    var body: some View {
        form
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
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }
    
    var form: some View {
        Form {
            ReasonView(reason: $reason, focusedField: $reasonFocused, showReason: true)
            Section {
                VStack(alignment: .center, spacing: 12) {
                    Image(systemName: Icons.purge)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50)
                    Text("Purged content cannot is removed permanently from the database and cannot be restored.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.red, lineWidth: 3)
                        .background(Color.red.opacity(0.1))
                )
            }
        }
    }
    
    private func confirm() {
        isWaiting = true
        
        Task {
            var content = content
            let outcome = await content.purge(reason: reason.isEmpty ? nil : reason)
            if outcome {
                await notifier.add(.success("Purged"))
                DispatchQueue.main.async {
                    dismiss()
                }
            } else {
                DispatchQueue.main.async {
                    isWaiting = false
                }
            }
        }
    }
}

#Preview {
    PurgeContentView(content: CommunityModel.mock())
}
