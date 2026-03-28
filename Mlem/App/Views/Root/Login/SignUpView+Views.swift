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
            Image(icon: .lemmy.send)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 100)
                .foregroundStyle(.themedAccent)
                .padding(.bottom)
            Text("Application submitted!")
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
    var header: some View {
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
    var usernameSection: some View {
        Section("Username") {
            HStack {
                TextField("Username", text: $username, prompt: Text(
                    "john_doe",
                    comment: "Translate this into a similar placeholder name in your language."
                ))
                .focused($focused, equals: .username)
                .onSubmit { focused = .email }
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .task(id: username) {
                    await checkUsernameValidity(instance)
                }
                Group {
                    if !username.isEmpty {
                        switch usernameValidity {
                        case .checking:
                            ProgressView()
                                .tint(.themedSecondary)
                        case .valid:
                            Image(icon: .general.success)
                                .foregroundStyle(.themedPositive)
                        case .taken, .tooShort, .invalidCharacters:
                            Image(icon: .general.failure)
                                .foregroundStyle(.themedNegative)
                        }
                    }
                }
                .symbolVariant(.circle.fill)
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
                .foregroundStyle(.themedWarning)
            }
        }
    }
    
    @ViewBuilder
    var emailSection: some View {
        Section("Email") {
            TextField(
                "Email",
                text: $email,
                // Converting to a String avoids this being rendered as a link
                prompt: Text(String(
                    localized: "john_doe@example.com",
                    // swiftlint:disable:next line_length
                    comment: "Translate \"john_doe\" into the equivalent placeholder name in your language, and \"example.com\" into a suitable example domain for your locale."
                ))
            )
            .focused($focused, equals: .email)
            .onSubmit { focused = .password }
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
        } footer: {
            ExpectedView(instance.emailVerificationRequired) { emailVerificationRequired in
                if emailVerificationRequired {
                    Text("You are required to provide an email on this instance.")
                } else {
                    Text("This field is optional.")
                }
            }
        }
    }
    
    @ViewBuilder
    var passwordSection: some View {
        if let applicationQuestion = instance.applicationQuestion.value {
            Section("Password") {
                SecureField("Password", text: $password)
                    .focused($focused, equals: .password)
                    .onSubmit { focused = .confirmPassword }
                SecureField("Confirm Password", text: $confirmPassword)
                    .focused($focused, equals: .confirmPassword)
                    .onSubmit {
                        focused = applicationQuestion == nil ? .captchaAnswer : .applicationQuestionResponse
                    }
            } footer: {
                if !confirmPassword.isEmpty, password != confirmPassword {
                    Text("Passwords don't match.")
                        .foregroundStyle(.themedWarning)
                } else if password.count < 10 {
                    // Using interpolation so we don't have to change the localization if this changes
                    Text("Password must be \(10) characters or more.")
                        .foregroundStyle(confirmPassword.isEmpty ? .themedSecondary : .themedWarning)
                }
            }
        }
    }
    
    @ViewBuilder
    var applicationQuestionSection: some View {
        if let applicationQuestion = instance.applicationQuestion.value as? String {
            Section {
                Markdown(applicationQuestion, configuration: .default(palette: palette))
                    .padding(.vertical, 8)
                TextField("Your Answer...", text: $applicationQuestionResponse, axis: .vertical)
                    .focused($focused, equals: .applicationQuestionResponse)
                    .lineLimit(8, reservesSpace: true)
            }
        }
    }
    
    @ViewBuilder
    var captchaSection: some View {
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
                .foregroundStyle(.themedAccent)
                .font(.footnote)
            }
        }
    }
    
    @ViewBuilder
    var applicationQuestionWarning: some View {
        Section {
            HStack {
                Image(icon: .general.warning)
                    .font(.title2)
                    .imageScale(.large)
                Text("To join this instance, you need to create an application and wait to be accepted.")
            }
            .foregroundStyle(.themedCaution)
            .listRowBackground(
                RoundedRectangle(cornerRadius: UIDevice.isIos26 ? 26 : 10)
                    .stroke(.themedCaution, lineWidth: 3)
                    .background(.themedCaution.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            )
        }
    }
    
    @ViewBuilder
    var submitButton: some View {
        ExpectedView(instance.applicationQuestion) { applicationQuestion in
            Button(String(localized: submitLabel(applicationQuestion))) {
                Task { await submit() }
            }
            .buttonStyle(SubmitButtonStyle())
            .disabled(!canSubmit)
        }
    }
    
    private func submitLabel(_ applicationQuestion: String?) -> LocalizedStringResource {
        if submitting { return "Submitting..." }
        return applicationQuestion == nil ? "Sign Up" : "Submit Application"
    }
}

private struct SubmitButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(12)
            .frame(maxWidth: .infinity)
            .foregroundStyle(.themedContrastingLabel)
            .background(isEnabled ? .themedAccent : .themedSecondary, in: .rect(cornerRadius: 10))
            .opacity(opacity(isPressed: configuration.isPressed))
    }
    
    func opacity(isPressed: Bool) -> CGFloat {
        if !isEnabled { return 0.5 }
        return isPressed ? 0.8 : 1
    }
}
