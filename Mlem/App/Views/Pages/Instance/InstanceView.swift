//
//  InstanceView.swift
//  Mlem
//
//  Created by Sjmarf on 08/07/2024.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct InstanceView: View {
    enum Tab: String, CaseIterable, Identifiable {
        case about, administration, details, uptime, safety
        
        var label: LocalizedStringResource {
            switch self {
            case .about: "About"
            case .administration: "Administration"
            case .details: "Details"
            case .uptime: "Uptime"
            case .safety: "Trust & Safety"
            }
        }
        
        var id: Self { self }
    }
    
    enum UptimeDataStatus {
        case success(UptimeData)
        case failure(Error)
    }
    
    var uptimeRefreshTimer = Timer.publish(every: 30, tolerance: 0.5, on: .main, in: .common)
        .autoconnect()
    
    @Environment(Palette.self) var palette
    @Environment(AppState.self) var appState
    @Environment(\.colorScheme) var colorScheme
    
    // This is fetched from the instance itself, not from the logged-in account.
    @State var instance: any InstanceStubProviding
    @State var uptimeData: UptimeDataStatus?
    @State var upgradeState: LoadingState = .idle
    
    @State var selectedTab: Tab = .about
    @State var isAtTop: Bool = true
    
    // If != nil, blocking is in progress
    @State var isBlocking: UUID?
    
    init(instance: any InstanceStubProviding) {
        self._instance = .init(wrappedValue: instance)
    }
    
    var body: some View {
        VStack {
            if let instance = instance as? any Instance {
                content(instance)
                    .navigationTitle(isAtTop ? "" : instance.displayName)
            } else {
                ProgressView()
                    .tint(palette.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: instance is any Instance)
        .task {
            guard upgradeState == .idle else { return }
            upgradeState = .loading
            do {
                if !(instance is any Instance3Providing) {
                    instance = try await instance.upgradeLocal()
                }
                upgradeState = .done
            } catch {
                upgradeState = .idle
                handleError(error)
            }
        }
        .isAtTopSubscriber(isAtTop: $isAtTop)
        .navigationBarTitleDisplayMode(.inline)
        .background(palette.groupedBackground)
        .onAppear(perform: attemptToLoadUptimeData)
        .onReceive(uptimeRefreshTimer) { _ in attemptToLoadUptimeData() }
    }
    
    @ViewBuilder
    func content(_ instance: any Instance) -> some View {
        FancyScrollView {
            ProfileHeaderView(
                instance,
                fallback: .instance,
                blockedOverride: (appState.firstSession as? UserSession)?.blocks?.contains(instance)
            )
            .padding([.horizontal, .bottom], Constants.main.standardSpacing)
            BubblePicker(
                tabs,
                selected: $selectedTab,
                label: { $0.label }
            )
            switch selectedTab {
            case .about:
                if let description = instance.description {
                    Markdown(description, configuration: .default)
                        .padding(Constants.main.standardSpacing)
                        .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
                        .padding([.horizontal, .bottom], Constants.main.standardSpacing)
                }
            case .details:
                InstanceDetailsView(instance: instance)
            case .administration:
                administrationTab(instance: instance)
            case .uptime:
                uptimeTab(instance: instance)
            default:
                EmptyView()
            }
        }
        .toolbar {
            ToolbarEllipsisMenu(instance.menuActions(allowExternalBlocking: true))
        }
    }
    
    @ViewBuilder
    func administrationTab(instance: any Instance) -> some View {
        VStack(spacing: 0) {
            ForEach(instance.administrators_ ?? []) { person in
                PersonListRow(person)
                Divider()
                    .padding(.leading, 71)
            }
        }
        .background(palette.secondaryGroupedBackground)
        .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
        .padding([.horizontal, .bottom], Constants.main.standardSpacing)
    }
    
    @ViewBuilder
    func uptimeTab(instance: any Instance) -> some View {
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
}
