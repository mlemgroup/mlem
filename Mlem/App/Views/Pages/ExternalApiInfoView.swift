//
//  ExternalApiInfoView.swift
//  Mlem
//
//  Created by Sjmarf on 08/06/2024.
//

import MlemMiddleware
import SwiftUI

struct ExternalApiInfoView: View {
    enum FederationBlame {
        case both, external, `internal`, unknown
    }
    
    @Environment(AppState.self) var appState
    
    @State var isLoading: Bool = true
    @State var blame: FederationBlame = .unknown
    
    let entity: any ContentStub
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .foregroundStyle(.secondary)
            } else {
                Text("Hello")
            }
        }.task {
            do {
                let externalApi = entity.api
                let internalApi = appState.firstApi
                
                async let externalFederated = try await externalApi.federatedWith(with: internalApi.baseUrl)
                async let internalFederated = try await internalApi.federatedWith(with: externalApi.baseUrl)
                
                switch try await (externalFederated, internalFederated) {
                case (false, false):
                    blame = .both
                case (false, _):
                    blame = .external
                case (_, false):
                    blame = .internal
                default:
                    blame = .unknown
                }
                
            } catch {}
        }
    }
}
