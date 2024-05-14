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
                    print("model not renderable!")
                    await upgradeModel()
                }
        }
    }
    
    func upgradeModel() async {
        print("upgrading model...")
        do {
            try await model.upgrade()
        } catch {
            print(error)
        }
    }
}
