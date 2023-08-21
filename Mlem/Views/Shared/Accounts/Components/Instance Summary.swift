//
//  Instance Summary.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-17.
//

import Foundation
import SwiftUI
import Dependencies

struct InstanceSummary: View {
    
    @Dependency(\.apiClient) var apiClient: APIClient
    @Dependency(\.errorHandler) var errorHandler: ErrorHandler
    
    let instance: InstanceMetadata
    let onboarding: Bool
    @Binding var selectedInstance: InstanceMetadata?
    
    @State var isCollapsed: Bool = true
    @State var fetchFailed: Bool = false
    @State var siteData: APISiteView?
    @State var isPresentingRedirectAlert: Bool = false
    
    var rotation: Angle { Angle(degrees: isCollapsed ? 0.0 : 90.0) }
    var isLoading: Bool { siteData == nil && !fetchFailed }
    var downvotesSymbolName: String { instance.downvotes ? AppConstants.checkSymbolName : AppConstants.xSymbolName }
    var federatedSymbolName: String { instance.federated ? AppConstants.checkSymbolName : AppConstants.xSymbolName }
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
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 1)) {
                self.isCollapsed.toggle()
            }
        } label: {
            VStack {
                collapsibleHeader
                
                if !isCollapsed {
                    instanceDetails
                      .task { await fetchInstanceDetails() }
                }
            }
            .padding()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var collapsibleHeader: some View {
        HStack {
            Text(instance.name)
                .fontWeight(.semibold)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .rotationEffect(rotation)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var instanceDetails: some View {
        if let siteData {
            VStack(spacing: AppConstants.postAndCommentSpacing) {
                HStack(alignment: .top, spacing: AppConstants.postAndCommentSpacing) {
                    instanceIcon(url: siteData.site.icon)
                    
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
                    .alert("Redirection Notice",
                           isPresented: $isPresentingRedirectAlert) {
                        Button {
                            _ = URLHandler.handle(signupURL)
                            
                            selectedInstance = instance
                        } label: {
                            Text("Got it, let's go!")
                        }
                        .keyboardShortcut(.defaultAction)
                        
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        // swiftlint:disable line_length
                        Text("Due to different sign-up procedures across instances, you will be directed to the instance website to sign up. Once that's done, you can navigate back to Mlem to sign in.")
                        // swiftlint:enable line_length
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
        CachedImage(url: url,
                    shouldExpand: false,
                    fixedSize: CGSize(width: 80, height: 80)) {
            AnyView(Image(systemName: "server.rack")
                .resizable()
                .frame(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize))
        }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(Circle()
                        .stroke(.secondary, lineWidth: 2))
    }
    
    func siteNotFoundView() -> AnyView {
        AnyView(Image(systemName: "server.rack")
            .resizable()
            .frame(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize))
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
            errorHandler.handle(.init(underlyingError: error))
        }
    }
}
