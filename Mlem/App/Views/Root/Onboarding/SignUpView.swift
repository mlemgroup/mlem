//
//  SignUpView.swift
//  Mlem
//
//  Created by Sjmarf on 05/09/2024.
//

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
    @Environment(Palette.self) var palette
    @Environment(\.isRootView) var isRootView
    @Environment(\.scenePhase) var scenePhase
    
    @State var instance: any InstanceStubProviding
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
            if let instance = instance as? any Instance2Providing, captcha != nil || !instance.captchaEnabled {
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
                    if instance.registrationMode == .closed {
                        Text("Registrations are closed on this instance.")
                    } else {
                        content(instance)
                    }
                }
            } else {
                ProgressView()
                    .tint(palette.secondary)
            }
        }
        .animation(.easeOut(duration: 0.1), value: signInResult)
        .animation(.easeOut(duration: 0.1), value: instance is any Instance2Providing)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(palette.groupedBackground)
        .task {
            guard upgradeState == .idle else { return }
            upgradeState = .loading
            do {
                if !(instance is any Instance3Providing) {
                    let instance = try await instance.upgradeLocal()
                    self.instance = instance
                    if instance.captchaEnabled_ ?? false {
                        captcha = try await instance.guestApi.getCaptcha()
                    }
                }
                upgradeState = .done
            } catch {
                upgradeState = .idle
                handleError(error)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if navigation.isInsideSheet, isRootView {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        navigation.dismissSheet()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func content(_ instance: any Instance2Providing) -> some View {
        Form {
            header(instance)
            if instance.applicationQuestion != nil {
                applicationQuestionWarning
            }
            usernameSection(instance)
            emailSection(instance)
            passwordSection(instance)
            applicationQuestionSection(instance)
            Section {
                Toggle("Show NSFW Content", isOn: $showNsfw)
                    .tint(palette.warning)
            }
            captchaSection(instance)
            Section {
                submitButton(instance)
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init())
            }
        }
        .environment(\.defaultMinListHeaderHeight, 0)
        .scrollDismissesKeyboard(.interactively)
        .disabled(submitting)
    }
}
