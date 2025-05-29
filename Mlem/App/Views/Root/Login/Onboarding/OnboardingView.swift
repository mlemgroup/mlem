//
//  OnboardingView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-05-19.
//

import MlemMiddleware
import SwiftUI
import Theming

struct OnboardingView: View {
    enum Page { case recommendInstance, username }
    
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.palette) var palette

    @State var instance: Instance3?
    @State var page: Page = .recommendInstance
    
    var body: some View {
        VStack {
            switch page {
            case .recommendInstance:
                OnboardingRecommendInstanceView(instance: instance) { page = .username }
                    .transition(.blurReplace)
            case .username:
                if let instance {
                    OnboardingUsernameView(instance: instance) { page = .recommendInstance }
                        .transition(.blurReplace)
                }
            }
        }
        .animation(.easeOut(duration: 0.2), value: page)
        .animation(.bouncy, value: instance)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            VStack {
                switch page {
                case .recommendInstance:
                    image
                default:
                    ThemedColor.themedGroupedBackground.resolve(with: palette)
                }
            }
            .ignoresSafeArea(.container, edges: .top)
            .animation(.easeOut(duration: 0.2), value: page)
        }
        .onAppear {
            Task {
                let startTime = Date.now
                let stub = InstanceStub(api: appState.firstApi, actorId: .init(url: URL(string: "https://lemmy.world")!)!)
                let instance = try await stub.upgradeLocal()
                try await Task.sleep(for: .seconds(Date.now.advanced(by: 0.1).timeIntervalSince(startTime)))
                self.instance = instance
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    @ViewBuilder
    var image: some View {
        if colorScheme == .dark {
            Image("background.earth")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .background(.black)
        } else {
            Image("background.trees")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxHeight: .infinity, alignment: .top)
                .blur(radius: 5, opaque: true)
        }
    }
}
