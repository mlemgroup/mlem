//
//  SignUpView.swift
//  Mlem
//
//  Created by Sjmarf on 05/09/2024.
//

import ComponentViews
import MlemMiddleware
import SwiftUI

struct SignUpView: View {
    enum UsernameValidity {
        case checking, valid, tooShort, taken, invalidCharacters
    }

    enum FocusedField: Hashable {
        case username, email, password, confirmPassword, applicationQuestionResponse, captchaAnswer
    }

    enum SignInResult {
        case awaitingEmail, awaitingApproval
    }

    @Environment(NavigationLayer.self) var navigation
    @Environment(\.palette) var palette
    @Environment(\.isRootView) var isRootView
    @Environment(\.scenePhase) var scenePhase
    
    @State var instance: Instance
    @State var upgradeState: LoadingState = .idle
    @State var captcha: Captcha?
    
    @State var username: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State var applicationQuestionResponse: String = ""
    @State var showNsfw: Bool = false
    @State var captchaAnswer: String = ""
    
    @State var usernameValidity: UsernameValidity = .tooShort
    @State var submitting: Bool = false
    @FocusState var focused: FocusedField?
    
    @State var signInResult: SignInResult?
    
    var body: some View {
        VStack {
            if let captchaEnabled = instance.captchaEnabled.value,
               let registrationMode = instance.registrationMode.value,
               captcha != nil || !captchaEnabled {
                switch signInResult {
                case .awaitingEmail:
                    EmailConfirmationView(
                        api: instance.guestApi,
                        email: email,
                        username: username,
                        password: password
                    )
                case .awaitingApproval:
                    approvalInfo
                case nil:
                    if registrationMode == .closed {
                        Text("Registrations are closed on this instance.")
                    } else {
                        content
                    }
                }
            } else {
                ProgressView()
                    .tint(.themedSecondary)
            }
        }
        .task(id: instance.captchaEnabled.value) {
            if captcha == nil, instance.captchaEnabled.value ?? false {
                do {
                    captcha = try await instance.guestApi.getCaptcha()
                } catch {
                    handleError(error)
                }
            }
        }
        .animation(.easeOut(duration: 0.1), value: signInResult)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.themedGroupedBackground)
        .presentationBackground(.themedGroupedBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if navigation.isInsideSheet, isRootView {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButtonView(ios18Label: .cancel) {
                        navigation.dismissSheet()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
        var content: some View {
        Form {
            header
            if instance.applicationQuestion.value is String {
                applicationQuestionWarning
            }
            usernameSection
            emailSection
            passwordSection
            applicationQuestionSection
            Section {
                Toggle("Show NSFW Content", isOn: $showNsfw)
                    .tint(.themedWarning)
            }
            captchaSection
            Section {
                submitButton
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init())
            }
        }
        .environment(\.defaultMinListHeaderHeight, 0)
        .scrollDismissesKeyboard(.interactively)
        .disabled(submitting)
    }
}
