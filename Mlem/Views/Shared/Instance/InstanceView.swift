//
//  InstanceView.swift
//  Mlem
//
//  Created by Sjmarf on 13/01/2024.
//

import SwiftUI
import Charts
import Dependencies

enum InstanceViewTab: String, Identifiable, CaseIterable {
    case about, administrators, statistics, uptime, safety
    
    var id: Self { self }
    
    var label: String {
        switch self {
        case .safety:
            return "Trust & Safety"
        default:
            return rawValue.capitalized
        }
    }
}

struct InstanceView: View {
    @Dependency(\.errorHandler) var errorHandler
    
    @Environment(\.navigationPathWithRoutes) private var navigationPath
    @Environment(\.scrollViewProxy) private var scrollViewProxy
    
    @State var domainName: String
    @State var instance: InstanceModel?
    @State var errorDetails: ErrorDetails?
    
    @Namespace var scrollToTop
    @State private var scrollToTopAppeared = false
    
    @State var selectedTab: InstanceViewTab = .about
    
    init(domainName: String, instance: InstanceModel? = nil) {
        _domainName = State(wrappedValue: domainName)
        _instance = State(wrappedValue: instance)
    }
    
    var subtitleText: String {
        if let version = instance?.version {
            "\(domainName) • \(String(describing: version))"
        } else {
            domainName
        }
    }
    
    var body: some View {
        ScrollView {
            ScrollToView(appeared: $scrollToTopAppeared)
                .id(scrollToTop)
            VStack(spacing: AppConstants.postAndCommentSpacing) {
                AvatarBannerView(instance: instance)
                    .padding(.horizontal, AppConstants.postAndCommentSpacing)
                    .padding(.top, 10)
                VStack(spacing: 5) {
                    if errorDetails == nil {
                        if let instance {
                            Text(instance.name)
                                .font(.title)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)

                            Text(subtitleText)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text(domainName)
                            .font(.title)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .padding(.bottom, 5)
                        Divider()
                    }
                }
                .padding(.bottom, 5)
                if let instance {
                    VStack(spacing: 0) {
                        VStack(spacing: 4) {
                            Divider()
                            BubblePicker([.about, .administrators], selected: $selectedTab) { tab in
                                Text(tab.label)
                            }
                            Divider()
                        }
                        switch self.selectedTab {
                        case .about:
                            if let description = instance.description {
                                MarkdownView(text: description, isNsfw: false)
                                    .padding(.horizontal, AppConstants.postAndCommentSpacing)
                                    .padding(.top)
                            } else {
                                Text("No Description")
                                    .foregroundStyle(.secondary)
                            }
                        case .administrators:
                            if let administrators = instance.administrators {
                                Divider()
                                ForEach(administrators, id: \.self) { user in
                                    UserResultView(user)
                                    Divider()
                                }
                            } else {
                                ProgressView()
                            }
                        default:
                            EmptyView()
                        }
                        Spacer()
                            .frame(height: 100)
                    }
                    
                } else if let errorDetails {
                    ErrorView(errorDetails)
                } else {
                    LoadingView(whatIsLoading: .instanceDetails)
                }
            }
        }
        .toolbar {
            if let instance {
                ToolbarItem(placement: .topBarTrailing) {
                    Link(destination: instance.url) {
                        Label("Open in Browser", systemImage: Icons.browser)
                    }
                }
            }
        }
        .task {
            if instance?.administrators == nil {
                do {
                    let client = APIClient(transport: { urlSession, urlRequest in try await urlSession.data(for: urlRequest) })
                    let url = try await getCorrectURLtoEndpoint(baseInstanceAddress: domainName)
                    client.session = .unauthenticated(url)
                    let info = try await client.loadSiteInformation()
                    DispatchQueue.main.async {
                        withAnimation(.easeOut(duration: 0.2)) {
                            if var instance {
                                instance.update(with: info)
                                self.instance = instance
                            } else {
                                self.instance = InstanceModel(from: info)
                            }
                        }
                    }
                } catch EndpointDiscoveryError.couldNotFindAnyCorrectEndpoints {
                    withAnimation(.easeOut(duration: 0.2)) {
                        errorDetails = ErrorDetails(
                            title: "Cannot Connect to Instance",
                            body: "Maybe this is a KBin instance? Mlem can't yet display KBin instance details.",
                            icon: "point.3.filled.connected.trianglepath.dotted"
                        )
                    }
                } catch {
                    withAnimation(.easeOut(duration: 0.2)) {
                        errorDetails = ErrorDetails(error: error)
                    }
                }
            }
        }
        .fancyTabScrollCompatible()
        .hoistNavigation {
            if navigationPath.isEmpty {
                withAnimation {
                    scrollViewProxy?.scrollTo(scrollToTop)
                }
                return true
            } else {
                if scrollToTopAppeared {
                    return false
                } else {
                    withAnimation {
                        scrollViewProxy?.scrollTo(scrollToTop)
                    }
                    return true
                }
            }
        }
        .navigationTitle(instance?.name ?? domainName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
