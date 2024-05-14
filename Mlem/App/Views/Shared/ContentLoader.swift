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
    @Binding var model: Model?
    var upgrade: () async throws -> Model
    var content: (Model) -> Content
    
    var body: some View {
        if let model {
            content(model)
        } else {
            Text("Loading")
                .task {
                    do {
                        model = try await upgrade()
                    } catch {
                        print(error)
                    }
                }
        }
    }
}
