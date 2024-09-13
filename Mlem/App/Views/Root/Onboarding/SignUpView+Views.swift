//
//  SignUpView+Views.swift
//  Mlem
//
//  Created by Sjmarf on 06/09/2024.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

extension SignUpView {
    @ViewBuilder
    var approvalInfo: some View {
        VStack(spacing: Constants.main.doubleSpacing) {
            Image(systemName: Icons.send)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 100)
                .foregroundStyle(palette.accent)
                .padding(.bottom)
            Text("Application Submitted!")
                .font(.title2)
                .fontWeight(.semibold)
            if email.isEmpty {
                Text("Once approved, you'll be able to log in to your account from the Settings tab.")
            } else {
                Text(
                    // swiftlint:disable:next line_length
                    "You'll receive an email once your application has been approved. Once approved, you can log in to your account from the Settings tab."
                )
            }
            Button("Done") {
                navigation.dismissSheet()
            }
            .buttonStyle(SubmitButtonStyle())
        }
        .multilineTextAlignment(.center)
        .padding()
    }
    
    @ViewBuilder
    func header(_ instance: any Instance2Providing) -> some View {
        Section {
            VStack {
                CircleCroppedImageView(instance, frame: 50)
                Text(instance.displayName)
                    .font(.title)
                    .bold()
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
            .listRowInsets(.init())
        } header: {
            // https://stackoverflow.com/a/78618856/17629371
            Spacer(minLength: 0).listRowInsets(EdgeInsets())
        }
    }
    
    @ViewBuilder
    func usernameSection(_ instance: any Instance2Providing) -> some View {
        Section("Username") {
            HStack {
                TextField("Username", text: $username, prompt: Text("john_doe"))
                    .focused($focused, equals: .username)
                    .onSubmit { focused = .email }
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .task(id: username) {
                        await checkUsernameValidity(instance)
                    }
                if !username.isEmpty {
                    switch usernameValidity {
                    case .checking:
                        ProgressView()
                            .tint(palette.secondary)
                    case .valid:
                        Image(systemName: Icons.successCircleFill)
                            .foregroundStyle(palette.positive)
                    case .taken, .tooShort, .invalidCharacters:
                        Image(systemName: Icons.failureCircleFill)
                            .foregroundStyle(palette.negative)
                    }
                }
            }
        } footer: {
            if username.isEmpty {
                Text("Choose wisely - you cannot change this later.")
            } else {
                Group {
                    switch usernameValidity {
                    case .invalidCharacters:
                        Text("Username can only contain lowercase letters, numbers and underscores.")
                    case .tooShort:
                        Text("Username must be 3 or more characters.")
                    case .taken:
                        Text("This username is taken.")
                    default:
                        Text(verbatim: "")
                    }
                }
                .foregroundStyle(palette.warning)
            }
        }
    }
    
    @ViewBuilder
    func emailSection(_ instance: any Instance2Providing) -> some View {
        Section("Email") {
            TextField(
                "Email",
                text: $email,
                prompt: Text(String(localized: "johndoe@example.com")) // Avoids this being rendered as a link
            )
            .focused($focused, equals: .email)
            .onSubmit { focused = .password }
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
        } footer: {
            if instance.emailVerificationRequired {
                Text("You are required to provide an email on this instance.")
            } else {
                Text("This field is optional.")
            }
        }
    }
    
    @ViewBuilder
    func passwordSection(_ instance: any Instance2Providing) -> some View {
        Section("Password") {
            SecureField("Password", text: $password)
                .focused($focused, equals: .password)
                .onSubmit { focused = .confirmPassword }
            SecureField("Confirm Password", text: $confirmPassword)
                .focused($focused, equals: .confirmPassword)
                .onSubmit {
                    focused = instance.applicationQuestion == nil ? .captchaAnswer : .applicationQuestionResponse
                }
        } footer: {
            if !confirmPassword.isEmpty, password != confirmPassword {
                Text("Passwords don't match.")
                    .foregroundStyle(palette.warning)
            } else if password.count < 10 {
                // Using interpolation so we don't have to change the localization if this changes
                Text("Password must be \(10) characters or more.")
                    .foregroundStyle(confirmPassword.isEmpty ? palette.secondary : palette.warning)
            }
        }
    }
    
    @ViewBuilder
    func applicationQuestionSection(_ instance: any Instance2Providing) -> some View {
        if let applicationQuestion = instance.applicationQuestion {
            Section {
                Markdown(applicationQuestion, configuration: .default)
                    .padding(.vertical, 8)
                TextField("Your Answer...", text: $applicationQuestionResponse, axis: .vertical)
                    .focused($focused, equals: .applicationQuestionResponse)
                    .lineLimit(8, reservesSpace: true)
            }
        }
    }
    
    @ViewBuilder
    func captchaSection(_ instance: any Instance2Providing) -> some View {
        if let captchaImage = captcha?.image {
            Section {
                captchaImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 500, alignment: .leading)
                    .listRowInsets(.init())
                TextField("Answer...", text: $captchaAnswer)
                    .focused($focused, equals: .captchaAnswer)
                    .onSubmit { focused = .captchaAnswer }
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            } footer: {
                Button("Try a different Captcha...") {
                    Task {
                        do {
                            captcha = try await instance.guestApi.getCaptcha()
                            captchaAnswer = ""
                        } catch {
                            handleError(error)
                        }
                    }
                }
                .foregroundStyle(palette.accent)
                .font(.footnote)
            }
        }
    }
    
    @ViewBuilder
    var applicationQuestionWarning: some View {
        Section {
            HStack {
                Image(systemName: Icons.warning)
                    .font(.title2)
                    .imageScale(.large)
                Text("To join this instance, you need to create an application and wait to be accepted.")
            }
            .foregroundStyle(palette.caution)
            .listRowBackground(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(palette.caution, lineWidth: 3)
                    .background(palette.caution.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            )
        }
    }
    
    @ViewBuilder
    func submitButton(_ instance: any Instance2Providing) -> some View {
        Button(String(localized: submitLabel(instance))) {
            Task { await submit() }
        }
        .buttonStyle(SubmitButtonStyle())
        .disabled(!canSubmit)
    }
    
    private func submitLabel(_ instance: any Instance2Providing) -> LocalizedStringResource {
        if submitting { return "Submitting..." }
        return instance.applicationQuestion == nil ? "Sign Up" : "Submit Application"
    }
}

private struct SubmitButtonStyle: ButtonStyle {
    @Environment(Palette.self) var palette
    @Environment(\.isEnabled) private var isEnabled: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(12)
            .frame(maxWidth: .infinity)
            .foregroundStyle(palette.selectedInteractionBarItem)
            .background(isEnabled ? palette.accent : palette.secondary, in: .rect(cornerRadius: 10))
            .opacity(opacity(isPressed: configuration.isPressed))
    }
    
    func opacity(isPressed: Bool) -> CGFloat {
        if !isEnabled { return 0.5 }
        return isPressed ? 0.8 : 1
    }
}
