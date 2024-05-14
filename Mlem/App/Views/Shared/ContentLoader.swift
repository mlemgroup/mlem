//
//  ContentLoader.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-13.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct ContentLoader<Content: View, Model>: View {
    var model: Model?
    var content: (Model) -> Content
    var upgrade: () async throws -> Void
    
    var body: some View {
        if let model {
            content(model)
        } else {
            Text("Loading")
                .task {
                    do {
                        try await upgrade()
                    } catch {
                        print(error)
                    }
                }
        }
    }
}
