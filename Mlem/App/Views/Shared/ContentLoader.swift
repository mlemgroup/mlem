//
//  ContentLoader.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-13.
//

import Foundation
import MlemMiddleware
import Semaphore
import SwiftUI

struct ContentLoader<Content: View, Model: Upgradable>: View {
    @Environment(Palette.self) var palette: Palette
    
    private let loadingSemaphore: AsyncSemaphore = .init(value: 1)
    
    let model: Model
    var content: (Model.MinimumRenderable) -> Content
    
    init(model: Model, content: @escaping (Model.MinimumRenderable) -> Content) {
        self.model = model
        self.content = content
    }
    
    var body: some View {
        if let modelValue = model.wrappedValue as? Model.MinimumRenderable {
            content(modelValue)
                .task {
                    await upgradeModel()
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
        // critical function, only one thread allowed!
        await loadingSemaphore.wait()
        defer { loadingSemaphore.signal() }
        
        // if model upgraded, noop
        guard !model.isUpgraded else { return }
        
        do {
            try await model.upgrade(api: nil, upgradeOperation: nil)
        } catch {
            print(error)
        }
    }
}
