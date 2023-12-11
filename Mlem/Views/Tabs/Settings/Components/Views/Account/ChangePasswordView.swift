//
//  ChangePasswordView.swift
//  Mlem
//
//  Created by Sjmarf on 03/12/2023.
//

import SwiftUI
import Dependencies

struct ChangePasswordView: View {
    @Dependency(\.apiClient) var apiClient: APIClient
    @Dependency(\.errorHandler) var errorHandler: ErrorHandler
    
    enum ViewState {
        case initial
        case waiting
        case success
    }
    
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var viewState: ViewState = .initial
    
    @State var newPassword: String = ""
    @State var confirmNewPassword: String = ""
    @State var currentPassword: String = ""
    
    enum FocusedField {
        case newPassword, confirmNewPassword, currentPassword
    }
    @FocusState private var focusedField: FocusedField?
    
    var canSave: Bool {
        return currentPassword.isNotEmpty && newPassword.isNotEmpty && newPassword == confirmNewPassword
    }
    
    var body: some View {
        Form {
            Group {
                Section {
                    SecureField("New Password", text: $newPassword)
                        .focused($focusedField, equals: .newPassword)
                    SecureField("Confirm New Password", text: $confirmNewPassword)
                        .focused($focusedField, equals: .confirmNewPassword)
                }
                
                Section {
                    SecureField("Current Password", text: $currentPassword)
                        .focused($focusedField, equals: .currentPassword)
                }
            }
            .disabled(viewState != .initial)
            Section {
                Button {
                    if viewState == .initial {
                        Task {
                            do {
                                viewState = .waiting
                                let response = try await apiClient.changePassword(
                                    newPassword: newPassword,
                                    confirmNewPassword: confirmNewPassword,
                                    currentPassword: currentPassword
                                )
                                if let currentActiveAccount = appState.currentActiveAccount {
                                    appState.setActiveAccount(
                                        .init(
                                            from: currentActiveAccount,
                                            accessToken: response.jwt,
                                            avatarUrl: currentActiveAccount.avatarUrl
                                        )
                                    )
                                }
                                viewState = .success
                                HapticManager.shared.play(haptic: .success, priority: .high)
                                try? await Task.sleep(for: .seconds(0.5))
                                dismiss()
                            } catch {
                                errorHandler.handle(error)
                                viewState = .initial
                            }
                        }
                    }
                } label: {
                    switch viewState {
                    case .initial:
                        Text("Save")
                            .transition(.scale(scale: 0.9).combined(with: .opacity))
                    case .waiting:
                        ProgressView()
                            .transition(.scale(scale: 0.9).combined(with: .opacity))
                    case .success:
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .transition(.scale(scale: 0.9).combined(with: .opacity))
                    }
                }
                .animation(.easeOut(duration: 0.1), value: viewState)
                .frame(maxWidth: .infinity)
                .disabled(!canSave)
            }
            Section {
                Button("Cancel") {
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .disabled(viewState != .initial)
            } footer: {
                if newPassword != confirmNewPassword {
                    Text("Passwords don't match.")
                        .foregroundStyle(.red)
                }
            }
        }
        .onAppear {
            focusedField = .newPassword
        }
    }
}
