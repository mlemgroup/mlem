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
    let model: any Upgradable
    var content: (Model.MinimumRenderable) -> Content
    
    @State var upgradeState: LoadingState = .idle
    
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
