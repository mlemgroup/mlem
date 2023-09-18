//
//  Instance Summary.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-17.
//

import Dependencies
import Foundation
import SwiftUI

struct InstanceSummary: View {
    @Dependency(\.apiClient) var apiClient: APIClient
    @Dependency(\.errorHandler) var errorHandler: ErrorHandler
    
    let instance: InstanceMetadata
    let onboarding: Bool
    @Binding var selectedInstance: InstanceMetadata?
    
    @State var fetchFailed: Bool = false
    @State var siteData: APISiteView?
    @State var isPresentingRedirectAlert: Bool = false
    
    var isLoading: Bool { siteData == nil && !fetchFailed }
    var downvotesSymbolName: String { instance.downvotes ? AppConstants.presentSymbolName : AppConstants.absentSymbolName }
    var federatedSymbolName: String { instance.federated ? AppConstants.presentSymbolName : AppConstants.absentSymbolName }
    var signupURL: URL? {
        let signupString = "\(instance.url.description)/signup"
        if let ret = URL(string: signupString) {
            return ret
        } else {
            assertionFailure("Invalid signup string \(signupString)")
            return nil
        }
    }
    
    var body: some View {
        DisclosureGroup {
            instanceDetails
                .padding(.vertical)
                .task { await fetchInstanceDetails() }
        } label: {
            Text(instance.name)
                .fontWeight(.semibold)
                .padding(.vertical, 5)
        }
        .tint(.primary)
    }
    
    @ViewBuilder
    private var instanceDetails: some View {
        if let siteData {
            VStack(spacing: AppConstants.postAndCommentSpacing) {
                HStack(alignment: .top, spacing: AppConstants.postAndCommentSpacing) {
                    instanceIcon(url: siteData.site.iconUrl)
                        .padding(.leading, 1)
                    
                    Spacer()
                    
                    if let description = siteData.site.description {
                        Text(description)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Grid(alignment: .center) {
                    GridRow {
                        Text("Uptime: \(instance.uptime)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(Image(systemName: federatedSymbolName)) Federated")
                            .imageScale(.small)
                        
                        Text("\(Image(systemName: downvotesSymbolName)) Downvotes")
                            .imageScale(.small)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .font(.callout)
                    .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                if let signupURL {
                    Button {
                        isPresentingRedirectAlert = true
                    } label: {
                        Text("Join")
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity)
                    }
                    .tint(nil) // override DisclosureGroup .primary tint
                    .alert(
                        "Redirection Notice",
                        isPresented: $isPresentingRedirectAlert
                    ) {
                        Button {
                            _ = URLHandler.handle(signupURL)
                            
                            Task { @MainActor in
                                try await Task.sleep(for: .seconds(0.5))
                                selectedInstance = instance
                            }
                        } label: {
                            Text("Got it, let's go!")
                        }
                        .keyboardShortcut(.defaultAction)
                        
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text(
                            """
                            Due to different sign-up procedures across instances, you will be directed to \
                            the instance website to sign up. Once that's done, you can navigate back to Mlem to sign in.
                            """)
                    }
                    .buttonStyle(.bordered)
                } else {
                    EmptyView()
                }
            }
        } else {
            LoadingView(whatIsLoading: .instanceDetails)
        }
    }
    
    @ViewBuilder
    func instanceIcon(url: URL?) -> some View {
        CachedImage(
            url: url,
            shouldExpand: false,
            fixedSize: CGSize(width: 80, height: 80)
        ) {
            AnyView(Image(systemName: "server.rack")
                .resizable()
                .frame(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize))
        }
        .frame(width: 80, height: 80)
        .clipShape(Circle())
        .overlay(Circle()
            .stroke(.secondary, lineWidth: 2))
    }
    
    private func fetchInstanceDetails() async {
        do {
            // need to do this slightly ugly thing to get the API url
            if let url = URL(string: instance.url.description + "/api/v3") {
                let request = GetSiteRequest(instanceURL: url)
                let siteResponse = try await apiClient.perform(request: request)
                siteData = siteResponse.siteView
            } else {
                fetchFailed = true
            }
        } catch {
            errorHandler.handle(error)
        }
    }
}
