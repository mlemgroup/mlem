//
//  OnboardingEmailView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-05-30.
//

import MlemMiddleware
import SwiftUI

struct OnboardingEmailView: View {
    @Environment(OnboardingModel.self) var model
    
    @State var email: String = ""
    @FocusState var focused: Bool
    
    var body: some View {
        VStack {
            Text("Email Address")
                .font(.title)
                .fontWeight(.bold)
            Text("You cannot use a temporary email address.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            VStack(spacing: 16) {
                textFieldView
                nextButtonView
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 30)
        .frame(minHeight: 0, maxHeight: .infinity) // Min height is needed here otherwise the keyboard padding doesn't work properly
        .keyboardAwarePadding(removePaddingOnDismiss: false)
        .overlay(alignment: .topLeading) {
            Button("Back", icon: .general.backward) {
                model.page = .username
            }
            .fontWeight(.semibold)
            .imageScale(.large)
            .labelStyle(.iconOnly)
            .padding()
        }
        .frame(maxHeight: .infinity)
    }
    
    @ViewBuilder
    var textFieldView: some View {
        TextField("Email", text: $email, prompt: Text(verbatim: ""))
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .submitLabel(.done)
            .onSubmit {}
            .focused($focused)
            .onAppear {
                focused = true
            }
            .padding()
            .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: 16))
    }
    
    @ViewBuilder
    var nextButtonView: some View {
        Button(action: submit) {
            Text("Next")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 16))
        .disabled(!emailIsValid)
    }
    
    var emailIsValid: Bool {
        (try? /[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}/.wholeMatch(in: email) != nil) ?? false
    }
    
    func submit() {
        model.email = email
    }
}
