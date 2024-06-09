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
    
    @Environment(AppState.self) var appState
    
    @State var isLoading: Bool = true
    @State var blame: Blame = .unknown
    @State var externalInstance: Instance3?
    
    let entity: any ContentStub
    
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
            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
            .frame(height: 2)
            .foregroundStyle(Color(uiColor: .systemGroupedBackground))
            .frame(width: 200, height: 30)
    }
    
    @Sendable
    func loadData() async {
        do {
            let externalApi = entity.api
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
