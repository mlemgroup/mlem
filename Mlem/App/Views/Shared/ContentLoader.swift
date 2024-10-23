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
    @Environment(AppState.self) var appState: AppState
    
    @State var proxy: ContentLoaderProxy<Model>
    let resolveIfModelExternal: Bool
    @ViewBuilder var content: (_ proxy: ContentLoaderProxy<Model>) -> Content
    var upgradeOperation: ((_ model: Model, _ api: ApiClient) async throws -> Void)?
    
    init(
        model: Model,
        resolveIfModelExternal: Bool = true,
        @ViewBuilder content: @escaping (_ proxy: ContentLoaderProxy<Model>) -> Content,
        upgradeOperation: ((_ model: Model, _ api: ApiClient) async throws -> Void)? = nil
    ) {
        self._proxy = .init(wrappedValue: ContentLoaderProxy(model: model))
        self.resolveIfModelExternal = resolveIfModelExternal
        self.upgradeOperation = upgradeOperation
        self.content = content
    }
    
    var body: some View {
        content(proxy)
            .animation(.easeOut(duration: 0.2), value: proxy.model.wrappedValue is Model.MinimumRenderable)
            .task { @MainActor in
                if resolveIfModelExternal || !proxy.model.isUpgraded, proxy.upgradeState == .idle {
                    await proxy.upgradeModel(
                        api: resolveIfModelExternal ? appState.firstApi : nil,
                        upgradeOperation: upgradeOperation
                    )
                }
            }
            .onChange(of: appState.firstApi) {
                if proxy.upgradeState != .loading {
                    // This code is needed here despite also being in `upgradeModel` to
                    // ensure that `upgradeState` is changed fast enough
                    proxy.upgradeState = .loading
                    Task { @MainActor in
                        await proxy.upgradeModel(api: appState.firstApi, upgradeOperation: upgradeOperation)
                    }
                }
            }
    }
}

@Observable @MainActor
class ContentLoaderProxy<Model: Upgradable> {
    fileprivate enum UpgradeState: String {
        case idle, loading, done, failed
    }
    
    fileprivate var model: Model
    fileprivate var upgradeState: UpgradeState = .idle
    
    var error: Error?
    private let loadingSemaphore: AsyncSemaphore = .init(value: 1)
    
    init(model: Model) {
        self.model = model
    }
    
    var entity: (Model.MinimumRenderable)? {
        model.wrappedValue as? Model.MinimumRenderable
    }
    
    var isLoading: Bool { upgradeState == .loading }
    
    func upgradeModel(
        api: ApiClient? = nil,
        upgradeOperation: ((_ model: Model, _ api: ApiClient) async throws -> Void)?
    ) async {
        // critical function, only one thread allowed!
        await loadingSemaphore.wait()
        defer { loadingSemaphore.signal() }
        
        upgradeState = .loading
        do {
            do {
                guard let modelApi = (model.wrappedValue as? any ContentModel)?.api else {
                    assertionFailure()
                    return
                }
                if let upgradeOperation {
                    try await upgradeOperation(model, api ?? modelApi)
                } else {
                    try await model.upgrade(api: api ?? modelApi, upgradeOperation: nil)
                }
            } catch ApiClientError.noEntityFound {
                print("No entity found, upgrading from local...")
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
