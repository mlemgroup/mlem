//
//  OnboardingRecommendInstanceView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-05-27.
//

import MlemMiddleware
import SwiftUI

struct OnboardingRecommendInstanceView: View {
    @Environment(\.colorScheme) var colorScheme
    let instance: Instance3?
    let submit: () -> Void
    
    @State var showButtons: Bool = false
    
    private let lightModeForeground: Color = .init(red: 40 / 255, green: 113 / 255, blue: 127 / 255)
    
    var body: some View {
        VStack {
            Spacer()
            if let instance {
                text(instance)
                    .transition(.scale.combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showButtons = true
                        }
                    }
                buttons
                    .opacity(showButtons ? 1 : 0)
                    .scaleEffect(showButtons ? 1 : 0.9)
                    .animation(.bouncy, value: showButtons)
            }
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            if instance != nil {
                showButtons = true
            }
        }
    }
    
    func text(_ instance: Instance3) -> some View {
        Text("Join \(numberText(instance.activeUserCount.month)) active users on Lemmy.world")
            .foregroundStyle(colorScheme == .dark ? .white : .black)
            .compositingGroup()
            .font(.largeTitle)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
    }
    
    var buttons: some View {
        VStack {
            Button(action: submit) {
                Text("Let's Go")
                    .padding(.vertical, 10)
                    .padding(.horizontal, 50)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 16))
            .tint(colorScheme == .dark ? .blue : lightModeForeground)
            Button {} label: {
                Text("Choose another instance...")
                    .foregroundStyle(.gray)
                    .opacity(0.5)
            }
            .buttonStyle(.empty)
            .padding(.top, 5)
        }
    }
    
    func numberText(_ value: Int) -> Text {
        if colorScheme == .dark {
            Text("\(value)")
                .foregroundStyle(.teal.gradient.shadow(.drop(color: .blue, radius: 10)))
        } else {
            Text("\(value)")
                .foregroundStyle(lightModeForeground)
        }
    }
}
