//
//  ExternalApiInfoView.swift
//  Mlem
//
//  Created by Sjmarf on 08/06/2024.
//

import MlemMiddleware
import SwiftUI

struct ExternalApiInfoView: View {
    @Environment(AppState.self) private var appState
    @Environment(Palette.self) private var palette
    
    @State private var isLoading: Bool = true
    @State private var internalFederationStatus: FederationStatus?
    @State private var externalFederationStatus: FederationStatus?
    @State private var externalInstance: Instance3?
    
    let api: ApiClient
    
    var body: some View {
        VStack {
            if isLoading {
                Text("Diagnosing...")
                    .foregroundStyle(.secondary)
            } else {
                ScrollView {
                    content
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeOut(duration: 0.2), value: isLoading)
        .background(palette.groupedBackground)
        .task(loadData)
        .presentationDetents([.medium])
        .presentationBackgroundInteraction(.enabled)
    }
    
    @ViewBuilder
    var content: some View {
        VStack(spacing: 16) {
            box(spacing: 16) {
                if internalFederationStatus?.isAllowed ?? false, externalFederationStatus?.isAllowed ?? false {
                    Text(
                        // swiftlint:disable:next line_length
                        "Your instance and **\(api.host ?? "")** appear to be federating with one another, but we weren't able to access this content from your instance. This could be because the content is new, and hasn't federated to your instance yet. Or, it could be because your instance has purged this content."
                    )
                    .padding(.horizontal, AppConstants.standardSpacing)
                } else {
                    avatars
                        .padding(.horizontal, 16)
                    Text(text)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
            }
            box(alignment: .leading) {
                Text("To work around this, we're accessing this content from **\(api.host ?? "")** instead of your instance.")
                    .padding(.horizontal, AppConstants.standardSpacing)
            }
            box(alignment: .leading, spacing: 6) {
                Text("What is Federation?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal, AppConstants.standardSpacing)
                
                Text(
                    // swiftlint:disable:next line_length
                    "Lemmy instances talk to each other so that content can be shared across sites. This is called \"federation\". Instance administrators can choose which other instances they would like their instance to federate with. Some instances will federate with all other instances, except those on a \"block-list\" curated by the administrators. Other instances might only federate to instances on an \"allow-list\"."
                )
                .padding(.horizontal, AppConstants.standardSpacing)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
    }
    
    @ViewBuilder func box(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat = 16,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: alignment, spacing: spacing) {
            content()
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
            Color(uiColor: .secondarySystemGroupedBackground),
            in: .rect(cornerRadius: AppConstants.largeItemCornerRadius)
        )
    }
    
    @ViewBuilder
    var avatars: some View {
        Line()
            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5]))
            .frame(height: 2)
            .foregroundStyle(palette.tertiary)
            .frame(width: 150, height: 48)
            .padding(.horizontal)
            .overlay {
                HStack {
                    AvatarView(appState.firstSession.instance)
                    Image(systemName: Icons.failure)
                        .bold()
                        .foregroundStyle(.red)
                        .imageScale(.large)
                        .frame(maxWidth: .infinity)
                    AvatarView(externalInstance)
                }
            }
    }
    
    var text: LocalizedStringKey {
        let externalHost = api.host ?? ""
        let internalHost = appState.firstApi.host ?? ""
        switch (externalFederationStatus?.isAllowed ?? false, internalFederationStatus?.isAllowed ?? false) {
        case (false, false):
            return "**\(internalHost)** and **\(externalHost)** chose to defederate from one another."
        case (false, true):
            if externalFederationStatus?.isExplicit ?? false {
                return "**\(externalHost)** chose to defederate from your instance, **\(internalHost)**."
            } else {
                return "**\(externalHost)** hasn't chosen to federate with your instance, **\(internalHost)**."
            }
        case (true, false):
            if internalFederationStatus?.isExplicit ?? false {
                return "Your instance, **\(internalHost)**, chose to defederate from **\(externalHost)**."
            } else {
                return "Your instance, **\(internalHost)**, hasn't chosen to federate with **\(externalHost)**."
            }
        case (true, true):
            return "Unknown"
        }
    }
    
    @Sendable
    func loadData() async {
        do {
            let externalApi = api
            let internalApi = appState.firstApi
            
            async let externalFederationStatus = await externalApi.federatedWith(with: internalApi.baseUrl)
            async let internalFederationStatus = await internalApi.federatedWith(with: externalApi.baseUrl)
            async let externalInstance = await externalApi.getMyInstance()
            
            let externalInstanceResponse = try await externalInstance
            let externalFederationStatusResponse = try await externalFederationStatus
            let internalFederationStatusResponse = try await internalFederationStatus
            
            Task { @MainActor in
                self.externalFederationStatus = externalFederationStatusResponse
                self.internalFederationStatus = internalFederationStatusResponse
                self.externalInstance = externalInstanceResponse
                isLoading = false
            }
            
        } catch {
            Task { @MainActor in
                isLoading = false
            }
        }
    }
}
