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
    @Environment(AppState.self) var appState: AppState
    
    enum UpgradeState: String {
        case idle, loading, done, failed
    }
        
    @State var upgradeState: UpgradeState = .idle
    @State var error: Error?
    
    let model: Model
    @ViewBuilder var content: (_ model: Model.MinimumRenderable, _ isLoading: Bool) -> Content
    var upgradeOperation: ((_ model: Model, _ api: ApiClient) async throws -> Void)?
    
    init(
        model: Model,
        @ViewBuilder content: @escaping (_ model: Model.MinimumRenderable, _ isLoading: Bool) -> Content,
        upgradeOperation: ((_ model: Model, _ api: ApiClient) async throws -> Void)? = nil
    ) {
        self.model = model
        self.content = content
        self.upgradeOperation = upgradeOperation
    }
    
    var body: some View {
        print("REFRESH2")
        return VStack {
            if let modelValue = model.wrappedValue as? Model.MinimumRenderable {
                content(modelValue, upgradeState == .loading)
            } else {
                ProgressView()
                    .tint(palette.secondary)
            }
        }
        .animation(.easeOut(duration: 0.2), value: model.wrappedValue is Model.MinimumRenderable)
        .task {
            if !model.isUpgraded, upgradeState == .idle {
                await upgradeModel()
            }
        }
        .onChange(of: appState.firstApi.actorId) {
            if upgradeState != .loading {
                // This code is needed here despite also being in `upgradeModel` to
                // ensure that `upgradeState` is changed fast enough
                upgradeState = .loading
                Task { @MainActor in
                    await upgradeModel(api: appState.firstApi)
                }
            }
        }
    }
    
    func upgradeModel(api: ApiClient? = nil) async {
        upgradeState = .loading
        do {
            do {
                guard let modelApi = (model.wrappedValue as? any ContentStub)?.api else {
                    assertionFailure()
                    return
                }
                if let upgradeOperation {
                    try await upgradeOperation(model, api ?? modelApi)
                } else {
                    try await model.upgrade(api: api ?? modelApi, upgradeOperation: nil)
                }
            } catch ApiClientError.noEntityFound {
                if !model.isUpgraded {
                    try await model.upgradeFromLocal()
                }
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
