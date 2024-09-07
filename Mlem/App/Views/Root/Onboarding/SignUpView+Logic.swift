//
//  SignUpView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 06/09/2024.
//

import MlemMiddleware
import SwiftUI

extension SignUpView {
    var canSubmit: Bool {
        guard let instance = instance as? any Instance2Providing else { return false }
        return (!instance.captchaEnabled || !captchaAnswer.isEmpty)
            && usernameValidity == .valid
            && (instance.applicationQuestion == nil || !applicationQuestionResponse.isEmpty)
            && (captcha == nil || !captchaAnswer.isEmpty)
            && password == confirmPassword
            && password.count >= 10
    }
    
    func checkUsernameValidity(_ instance: any Instance) async {
        if username.count < 3 {
            usernameValidity = .tooShort
            return
        }
        if (try? /[a-z_\d]*/.wholeMatch(in: username)) == nil {
            usernameValidity = .invalidCharacters
            return
        }
        usernameValidity = .checking
        do {
            if username.isEmpty { return }
            do {
                try await Task.sleep(for: .seconds(0.2))
                _ = try await instance.guestApi.getPerson(username: username)
                usernameValidity = .taken
            } catch ApiClientError.noEntityFound {
                usernameValidity = .valid
            } catch {
                print("Error checking username validity", error)
            }
        }
    }
    
    func submit() async {
        guard let instance = instance as? any Instance2Providing else { return }
        submitting = true
        do {
            let response = try await instance.guestApi.signUp(
                username: username,
                password: password,
                confirmPassword: confirmPassword,
                showNsfw: showNsfw,
                email: email.isEmpty ? nil : email,
                captcha: captcha,
                captchaAnswer: captchaAnswer.isEmpty ? nil : captchaAnswer,
                applicationQuestionResponse: applicationQuestionResponse.isEmpty ? nil : applicationQuestionResponse
            )
            if let token = response.jwt {
                let account = try await AccountsTracker.main.logIn(
                    username: username,
                    url: instance.guestApi.baseUrl,
                    token: token
                )
                AppState.main.changeAccount(to: account)
                navigation.dismissSheet()
                return
            } else if response.registrationCreated {
                signInResult = .awaitingApproval
            } else if response.verifyEmailSent {
                signInResult = .awaitingEmail
            }
        } catch {
            handleError(error)
        }
        submitting = false
    }
}
