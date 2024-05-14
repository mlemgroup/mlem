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
    
    var content: (Model.Upgraded) -> Content
    
    init(model: Model, content: @escaping (Model.Upgraded) -> Content) {
        self.model = model
        self.content = content
    }
    
    var body: some View {
        if let upgradedModel = model.upgraded as? Model.Upgraded {
            content(upgradedModel)
        } else {
            ProgressView()
                .task {
                    print("upgrading...")
                    do {
                        try await model.upgrade()
                    } catch {
                        print(error)
                    }
                }
        }
    }
}
