//
//  ChangePasswordView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-25.
//

import Haptics
import MlemMiddleware
import SwiftUI

struct ChangePasswordView: View {
    enum ViewState {
        case initial, waiting, success
    }
    
    @Environment(AppState.self) var appState
    @Environment(HapticManager.self) var hapticManager
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
        !currentPassword.isEmpty
            && !newPassword.isEmpty
            && newPassword == confirmNewPassword
            && (10 ... 60 ~= newPassword.count)
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
                Button(action: submit) {
                    switch viewState {
                    case .initial:
                        Text("Save")
                            .transition(.scale(scale: 0.9).combined(with: .opacity))
                    case .waiting:
                        ProgressView()
                            .transition(.scale(scale: 0.9).combined(with: .opacity))
                    case .success:
                        Image(icon: .general.success)
                            .symbolVariant(.circle.fill)
                            .foregroundStyle(.themedPositive)
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
                Group {
                    if !newPassword.isEmpty {
                        if newPassword != confirmNewPassword {
                            Text("Passwords don't match.")
                        } else if !(10 ... 60 ~= newPassword.count) {
                            Text("New password must be between \(10) and \(60) characters long.")
                        }
                    }
                }
                .foregroundStyle(.themedWarning)
            }
        }
        .onAppear {
            focusedField = .newPassword
        }
    }
    
    func submit() {
        if viewState == .initial {
            Task { @MainActor in
                do {
                    viewState = .waiting
                    try await appState.firstApi.changePassword(
                        newPassword: newPassword,
                        confirmNewPassword: confirmNewPassword,
                        oldPassword: currentPassword
                    )
                    AccountsTracker.main.saveAccounts(ofType: .user)
                    viewState = .success
                    hapticManager.play(haptic: .success, tier: .high)
                    try? await Task.sleep(for: .seconds(0.5))
                    dismiss()
                    // Catch separately to prevent the token expiry sheet opening in this view
                } catch ApiClientError.invalidSession {
                    ToastModel.main.add(.failure("Current password is incorrect"))
                    viewState = .initial
                } catch let ApiClientError.response(response, _) where response.error == "invalid_password" {
                    ToastModel.main.add(.failure("New password is invalid"))
                    viewState = .initial
                } catch {
                    handleError(error)
                    viewState = .initial
                }
            }
        }
    }
}
