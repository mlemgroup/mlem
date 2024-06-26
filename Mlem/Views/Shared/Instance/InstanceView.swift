//
//  InstanceView.swift
//  Mlem
//
//  Created by Sjmarf on 13/01/2024.
//

import Charts
import Dependencies
import Foundation
import SwiftUI

enum InstanceViewTab: String, Identifiable, CaseIterable {
    case about, administration, details, uptime, safety
    
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
    @State var fediseerData: FediseerData?
    @State var errorDetails: ErrorDetails?
    
    @Namespace var scrollToTop
    @State private var scrollToTopAppeared = false
    
    @State private var menuFunctionPopup: MenuFunctionPopup?
    
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
        var tabs: [InstanceViewTab] = [.about, .administration, .details]
        if instance.canFetchUptime {
            tabs.append(.uptime)
        }
        tabs.append(.safety)
        return tabs
    }
    
    var body: some View {
        ScrollView {
            ScrollToView(appeared: $scrollToTopAppeared)
                .id(scrollToTop)
            VStack(spacing: AppConstants.standardSpacing) {
                headerView
                    .padding(.bottom, AppConstants.halfSpacing)
                
                VStack(spacing: 0) {
                    BubblePicker(
                        availableTabs,
                        selected: $selectedTab,
                        withDividers: [.top, .bottom],
                        label: \.label
                    )
                    
                    if let errorDetails, [.about, .administration, .details].contains(selectedTab) {
                        ErrorView(errorDetails)
                    } else {
                        switch selectedTab {
                        case .about:
                            if let description = instance.description {
                                MarkdownView(text: description, isNsfw: false)
                                    .padding(.horizontal, AppConstants.postAndCommentSpacing)
                                    .padding(.top)
                            } else if instance.administrators != nil {
                                Text("No Description")
                                    .foregroundStyle(.secondary)
                                    .padding(.top)
                            } else {
                                ProgressView()
                                    .padding(.top, 30)
                            }
                        case .administration:
                            VStack(spacing: 0) {
                                ModlogNavigationLinkView(to: instance)
                                
                                Divider()
                                
                                if let administrators = instance.administrators {
                                    ForEach(administrators, id: \.self) { user in
                                        UserListRow(user, complications: [.date])
                                        Divider()
                                    }
                                } else {
                                    ProgressView()
                                        .padding(.top, 30)
                                }
                            }
                        case .details:
                            if instance.administrators != nil {
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
                                        .padding(.top, 5)
                                default:
                                    ProgressView()
                                        .padding(.top, 30)
                                }
                            }
                            .onAppear(perform: attemptToLoadUptimeData)
                            .onReceive(uptimeRefreshTimer) { _ in attemptToLoadUptimeData() }
                        case .safety:
                            Group {
                                if let fediseerData {
                                    InstanceSafetyView(instance: instance, fediseerData: fediseerData)
                                } else {
                                    ProgressView()
                                        .padding(.top, 30)
                                }
                            }
                            .onAppear(perform: attemptToLoadFediseerData)
                        }
                        Spacer()
                            .frame(height: 100)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ToolbarEllipsisMenu {
                    ForEach(instance.menuFunctions { new in
                        instance = new
                    }) { item in
                        MenuButton(menuFunction: item, menuFunctionPopup: $menuFunctionPopup)
                    }
                }
            }
        }
        .destructiveConfirmation(menuFunctionPopup: $menuFunctionPopup)
        .onAppear(perform: attemptToLoadInstanceData)
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
    
    @ViewBuilder
    var headerView: some View {
        AvatarBannerView(instance: instance)
            .padding(.horizontal, AppConstants.postAndCommentSpacing)
            .padding(.top, 10)
        VStack(spacing: 5) {
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
        }
    }
}

#Preview {
    InstanceView(instance: .mock())
}
