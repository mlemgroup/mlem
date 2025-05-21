//
//  SignUpRecommendSingleInstanceView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-05-19.
//

import MlemMiddleware
import SwiftUI

struct SignUpRecommendSingleInstanceView: View {
    @Environment(AppState.self) var appState
    
    @State var instance: Instance3?
    
    @State var showButtons: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            if let instance {
                text(instance)
                    .transition(.scale.combined(with: .opacity))
                buttons
                    .opacity(showButtons ? 1 : 0)
                    .scaleEffect(showButtons ? 1 : 0.9)
                    .animation(.bouncy, value: showButtons)
            }
            Spacer()
            Spacer()
        }
        .animation(.bouncy, value: instance)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            image
        }
        .onAppear {
            Task {
                let startTime = Date.now
                let stub = InstanceStub(api: appState.firstApi, actorId: .init(url: URL(string: "https://lemmy.world")!)!)
                let instance = try await stub.upgradeLocal()
                try await Task.sleep(for: .seconds(Date.now.advanced(by: 0.1).timeIntervalSince(startTime)))
                self.instance = instance
                try await Task.sleep(for: .seconds(0.5))
                showButtons = true
            }
        }
    }
    
    var image: some View {
        Image("background.earth")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(1.5)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .background(.black)
            .ignoresSafeArea()
    }
    
    func text(_ instance: Instance3) -> some View {
        Text("Join \(numberText(instance.activeUserCount.month)) active users on Lemmy.world")
            .foregroundStyle(.white)
            .compositingGroup()
            .font(.largeTitle)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .shadow(radius: 5)
    }
    
    func numberText(_ value: Int) -> Text {
        Text("\(value)")
            .foregroundStyle(.teal.gradient.shadow(.drop(color: .blue, radius: 10)))
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
            Button {} label: {
                Text("Choose another instance...")
                    .foregroundStyle(.gray)
                    .opacity(0.5)
            }
            .buttonStyle(.empty)
            .padding(.top, 5)
        }
    }
    
    func submit() {}
}

#Preview {
    SignUpRecommendSingleInstanceView()
}
