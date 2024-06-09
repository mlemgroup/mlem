//
//  ExternalApiInfoView.swift
//  Mlem
//
//  Created by Sjmarf on 08/06/2024.
//

import MlemMiddleware
import SwiftUI

struct ExternalApiInfoView: View {
    enum Blame {
        case bothDefederated, externalDefederated, internalDefederated, unknown
    }
    
    @Environment(AppState.self) private var appState
    @Environment(Palette.self) private var palette
    
    @State private var isLoading: Bool = true
    @State private var blame: Blame = .unknown
    @State private var externalInstance: Instance3?
    
    let api: ApiClient
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .foregroundStyle(.secondary)
            } else {
                avatars
            }
        }.task(loadData)
    }
    
    @ViewBuilder
    var avatars: some View {
        Line()
            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5]))
            .frame(height: 2)
            .foregroundStyle(palette.tertiary)
            .frame(width: 150, height: 30)
            .overlay {
                HStack {
                    Image(systemName: Icons.failure)
                        .bold()
                        .foregroundStyle(.red)
                        .imageScale(.large)
                        .frame(maxWidth: .infinity)
                }
            }
    }
    
    @Sendable
    func loadData() async {
        do {
            let externalApi = api
            let internalApi = appState.firstApi
            
            async let externalFederated = await externalApi.federatedWith(with: internalApi.baseUrl)
            async let internalFederated = await internalApi.federatedWith(with: externalApi.baseUrl)
            
            let externalInstance = try await externalApi.getMyInstance()
            
            let blame: Blame
            switch try await (externalFederated, internalFederated) {
            case (false, false):
                blame = .bothDefederated
            case (false, _):
                blame = .externalDefederated
            case (_, false):
                blame = .internalDefederated
            default:
                blame = .unknown
            }
            Task { @MainActor in
                self.blame = blame
                self.externalInstance = externalInstance
                isLoading = false
            }
            
        } catch {
            Task { @MainActor in
                isLoading = false
            }
        }
    }
}
