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
    
    @State var upgradeState: LoadingState = .idle
    
    let model: any Upgradable
    var content: (Model.MinimumRenderable) -> Content
    
    init(model: Model, content: @escaping (Model.MinimumRenderable) -> Content) {
        self.model = model
        self.content = content
    }
    
    var body: some View {
        if let modelValue = model.wrappedValue as? Model.MinimumRenderable {
            content(modelValue)
                .task {
                    if !model.isUpgraded {
                        await upgradeModel()
                    }
                }
        } else {
            ProgressView()
                .tint(palette.secondary)
                .task {
                    await upgradeModel()
                }
        }
    }
    
    func upgradeModel() async {
        // prevent multiple upgrades simultaneously
        guard upgradeState == .idle else { return }
        upgradeState = .loading
        
        do {
            try await model.upgrade()
            upgradeState = .done
        } catch {
            // if the task is cancelled or the call fails, reset upgradeState--upgrade will be retried on next render
            upgradeState = .idle
            print(error)
        }
    }
}
