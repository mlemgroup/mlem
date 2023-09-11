//
//  LandingPage.swift
//  Mlem
//
//  Created by mormaer on 14/09/2023.
//
//

import SwiftUI

struct LandingPage: View {
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 40) {
                Text("Welcome to Mlem!")
                    .bold()
                
                LogoView()
                
                VStack {
                    newUserButton
                    existingUserButton
                }
            }
            .padding(.horizontal)
            .frame(maxHeight: .infinity)
            .navigationDestination(for: OnboardingRoute.self) { route in
                switch route {
                case .onboard:
                    OnboardingView(navigationPath: $navigationPath)
                case let .login(url):
                    AddSavedInstanceView(onboarding: true, givenInstance: url?.absoluteString)
                }
            }
        }
    }
    
    @ViewBuilder
    var newUserButton: some View {
        Button {
            navigationPath.append(OnboardingRoute.onboard)
        } label: {
            Text("I'm new here")
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
    }
    
    @ViewBuilder
    var existingUserButton: some View {
        Button {
            navigationPath.append(OnboardingRoute.login(nil))
        } label: {
            Text("I have a Lemmy account")
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
    }
}
