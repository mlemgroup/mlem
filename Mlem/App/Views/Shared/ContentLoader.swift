//
//  ContentLoader.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-13.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct ContentLoader<Content: View, Model: Upgradable>: View {
    @Environment(Palette.self) var palette: Palette
    
    enum UpgradeState {
        case idle, loading, done, failed
    }
        
    @State var upgradeState: UpgradeState = .idle
    @State var error: Error?
    
    let model: any Upgradable
    var content: (Model.MinimumRenderable) -> Content
    
    init(model: Model, content: @escaping (Model.MinimumRenderable) -> Content) {
        self.model = model
        self.content = content
    }
    
    var body: some View {
        VStack {
            if let modelValue = model.wrappedValue as? Model.MinimumRenderable {
                content(modelValue)
            } else {
                ProgressView()
                    .tint(palette.secondary)
            }
        }
        .animation(.easeOut(duration: 0.2), value: model.wrappedValue is Model.MinimumRenderable)
        .task {
            if !model.isUpgraded {
                await upgradeModel()
            }
        }
    }
    
    func upgradeModel() async {
        // prevent multiple upgrades simultaneously
        guard upgradeState == .idle else { return }
        upgradeState = .loading
        do {
            do {
                try await model.upgrade()
            } catch ApiClientError.noEntityFound {
                try await model.upgradeFromLocal()
            }
            upgradeState = .done
        } catch ApiClientError.cancelled {
            // if the task is cancelled, reset upgradeState--upgrade will be retried on next render
            upgradeState = .idle
        } catch {
            upgradeState = .failed
            self.error = error
        }
    }
}
