//
//  InstanceView.swift
//  Mlem
//
//  Created by Sjmarf on 13/01/2024.
//

import Charts
import Dependencies
import SwiftUI

enum InstanceViewTab: String, Identifiable, CaseIterable {
    case about, administrators, details, uptime, safety
    
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
    
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.navigationPathWithRoutes) private var navigationPath
    @Environment(\.scrollViewProxy) private var scrollViewProxy
    
    enum UptimeDataStatus {
        case success(UptimeData)
        case failure(Error)
    }
    
    @State var instance: InstanceModel
    @State var uptimeData: UptimeDataStatus?
    @State var errorDetails: ErrorDetails?
    
    @Namespace var scrollToTop
    @State private var scrollToTopAppeared = false
    
    @State var selectedTab: InstanceViewTab = .about
    
    var uptimeRefreshTimer = Timer.publish(every: 30, tolerance: 0.5, on: .main, in: .common)
        .autoconnect()
    
    init(instance: InstanceModel) {
        var instance = instance
        @Dependency(\.siteInformation) var siteInformation
        if instance.name == siteInformation.instance?.url.host() {
            instance = siteInformation.instance ?? instance
        }
        _instance = State(wrappedValue: instance)
    }
    
    var subtitleText: String {
        if let version = instance.version {
            "\(instance.name) • \(String(describing: version))"
        } else {
            instance.name
        }
    }
    
    var availableTabs: [InstanceViewTab] {
        var tabs: [InstanceViewTab] = [.about, .administrators, .details]
        if instance.canFetchUptime {
            tabs.append(.uptime)
        }
        return tabs
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
                        Text(instance.displayName)
                            .font(.title)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .transition(.opacity)
                            .id("Title" + instance.displayName) // https://stackoverflow.com/a/60136737/17629371
                        Text(subtitleText)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .transition(.opacity)
                            .id("Subtitle" + subtitleText)
                    } else {
                        Text(instance.name)
                            .font(.title)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .padding(.bottom, 5)
                        Divider()
                    }
                }
                if let errorDetails {
                    if instance.canFetchUptime {
                        switch uptimeData {
                        case let .success(uptimeData):
                            VStack(alignment: .leading, spacing: 0) {
                                Text("We couldn't connect to \(instance.name). Perhaps the instance is offline?")
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, AppConstants.postAndCommentSpacing)
                                Divider()
                                InstanceUptimeView(instance: instance, uptimeData: uptimeData)
                            }
                        case .failure:
                            ErrorView(errorDetails)
                                .padding(.top, 5)
                        default:
                            ProgressView()
                                .padding(.top, 30)
                        }
                    } else {
                        ErrorView(errorDetails)
                            .padding(.top, 5)
                    }
                } else if instance.creationDate != nil {
                    VStack(spacing: 0) {
                        VStack(spacing: 4) {
                            Divider()
                            BubblePicker(availableTabs, selected: $selectedTab) { tab in
                                Text(tab.label)
                            }
                            Divider()
                        }
                        switch selectedTab {
                        case .about:
                            if let description = instance.description {
                                MarkdownView(text: description, isNsfw: false)
                                    .padding(.horizontal, AppConstants.postAndCommentSpacing)
                                    .padding(.top)
                            } else {
                                Text("No Description")
                                    .foregroundStyle(.secondary)
                                    .padding(.top)
                            }
                        case .administrators:
                            if let administrators = instance.administrators {
                                ForEach(administrators, id: \.self) { user in
                                    UserListRow(user, complications: [.date])
                                    Divider()
                                }
                            } else {
                                ProgressView()
                                    .padding(.top, 30)
                            }
                        case .details:
                            if instance.userCount != nil {
                                VStack(spacing: 0) {
                                    InstanceDetailsView(instance: instance)
                                        .padding(.vertical, 16)
                                        .background(Color(uiColor: .systemGroupedBackground))
                                    if colorScheme == .light {
                                        Divider()
                                    }
                                }
                            } else {
                                ProgressView()
                                    .padding(.top, 30)
                            }
                        case .uptime:
                            VStack {
                                switch uptimeData {
                                case let .success(uptimeData):
                                    InstanceUptimeView(instance: instance, uptimeData: uptimeData)
                                case let .failure(error):
                                    ErrorView(.init(error: error))
                                default:
                                    ProgressView()
                                        .padding(.top, 30)
                                }
                            }
                            .onAppear(perform: attemptToLoadUptimeData)
                            .onReceive(uptimeRefreshTimer) { _ in attemptToLoadUptimeData() }
                        default:
                            EmptyView()
                        }
                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.top, 5)
                } else {
                    LoadingView(whatIsLoading: .instanceDetails)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Link(destination: instance.url) {
                    Label("Open in Browser", systemImage: Icons.browser)
                }
            }
        }
        .task {
            if instance.administrators == nil {
                do {
                    if let url = URL(string: "https://\(instance.name)") {
                        let info = try await apiClient.loadSiteInformation(instanceURL: url)
                        DispatchQueue.main.async {
                            withAnimation(.easeOut(duration: 0.2)) {
                                instance.update(with: info)
                            }
                        }
                    } else {
                        errorDetails = ErrorDetails(title: "\"\(instance.name)\" is an invalid URL.")
                    }
                } catch let APIClientError.decoding(data, error) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        if let content = String(data: data, encoding: .utf8),
                           content.contains("<div class=\"kbin-container\">") {
                            errorDetails = ErrorDetails(
                                title: "KBin Instance",
                                body: "We can't yet display KBin details.",
                                icon: Icons.federation
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
        .navigationTitle(instance.displayName ?? instance.name)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: errorDetails == nil) { _ in
            attemptToLoadUptimeData()
        }
    }
    
    func attemptToLoadUptimeData() {
        print("Fetching uptime data...")
        if let url = instance.uptimeDataUrl {
            Task {
                do {
                    let data = try await URLSession.shared.data(from: url).0
                    let uptimeData = try JSONDecoder.defaultDecoder.decode(UptimeData.self, from: data)
                    DispatchQueue.main.async {
                        withAnimation(.easeOut(duration: 0.2)) {
                            self.uptimeData = .success(uptimeData)
                        }
                    }
                } catch {
                    errorHandler.handle(error)
                }
            }
        }
    }
}
