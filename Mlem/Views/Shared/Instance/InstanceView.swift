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
    @Dependency(\.apiClient) var apiClient: APIClient
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.siteInformation) var siteInformation
    
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
        var instance = instance
        if domainName == siteInformation.instance?.url.host() {
            instance = siteInformation.instance ?? instance
        }
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
                if let errorDetails {
                    ErrorView(errorDetails)
                } else if let instance {
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
                                ForEach(administrators, id: \.self) { user in
                                    UserResultView(user, complications: [.date])
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
                    if let url = URL(string: "https://\(domainName)") {
                        let info = try await apiClient.loadSiteInformation(instanceURL: url)
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
                    } else {
                        errorDetails = ErrorDetails(title: "\"\(domainName)\" is an invalid URL.")
                    }
                } catch APIClientError.decoding(let data, let error) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        if let content = String(data: data, encoding: .utf8),
                           content.contains("<title>Error 404 - \(domainName)</title>" ) {
                            errorDetails = ErrorDetails(
                                title: "KBin Instance",
                                body: "We can't yet display KBin details.",
                                icon: "point.3.filled.connected.trianglepath.dotted"
                            )
                        } else {
                            errorDetails = ErrorDetails(error: APIClientError.decoding(data, error))
                        }
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
        .navigationBarColor()
        .navigationTitle(instance?.name ?? domainName)
        .navigationBarTitleDisplayMode(.inline)
    }
}