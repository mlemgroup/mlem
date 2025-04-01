//
//  InstanceView.swift
//  Mlem
//
//  Created by Sjmarf on 08/07/2024.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI
import Theming

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
    
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.palette) var palette
    @Environment(\.colorScheme) var colorScheme
    
    let visitContext: VisitHistory.VisitContext?

    // This is fetched from the instance itself, not from the logged-in account.
    @State var instance: any InstanceStubProviding
    @State var uptimeData: UptimeDataStatus?
    @State var fediseerData: FediseerData?
    @State var upgradeState: LoadingState = .idle
    
    @State var selectedTab: Tab = .about
    
    @State var showingConfirmation: Bool = false
    @State var newAdmin: Person2?
    
    init(instance: any InstanceStubProviding, visitContext: VisitHistory.VisitContext?) {
        self._instance = .init(wrappedValue: instance)
        self.visitContext = visitContext
    }
    
    var body: some View {
        VStack {
            if let instance = instance as? any Instance {
                content(instance)
                    .conditionalNavigationTitle(instance.displayName)
            } else {
                ProgressView()
                    .tint(.themedSecondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: instance is any Instance)
        .task {
            guard upgradeState == .idle else { return }
            upgradeState = .loading
            do {
                if !(instance is any Instance3Providing) {
                    let instance3: Instance3
                    if let myInstance = appState.firstSession.instance, instance.host == myInstance.host {
                        instance3 = myInstance
                    } else {
                        instance3 = try await instance.upgradeLocal()
                    }
                    instance = instance3
                    logVisit(instance3)
                }
                upgradeState = .done
            } catch {
                upgradeState = .idle
                handleError(error)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(ThemedColor.themedGroupedBackground.ignoresSafeArea())
    }
    
    @ViewBuilder
    func content(_ instance: any Instance) -> some View {
        FancyScrollView {
            ProfileHeaderView(
                instance,
                fallback: .instanceAvatar,
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
                    Markdown(description, configuration: .default(palette: palette))
                        .padding(Constants.main.standardSpacing)
                        .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
                        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
                        .padding([.horizontal, .bottom], Constants.main.standardSpacing)
                }
            case .details:
                InstanceDetailsView(instance: instance)
            case .administration:
                administrationTab(instance: instance)
            case .uptime:
                uptimeTab(instance: instance)
                    .onAppear(perform: attemptToLoadUptimeData)
                    .onReceive(uptimeRefreshTimer) { _ in attemptToLoadUptimeData() }
            case .safety:
                safetyTab(instance: instance)
                    .onAppear(perform: attemptToLoadFediseerData)
            }
        }
        .toolbar {
            ToolbarEllipsisMenu(instance.menuActions(
                appState: appState,
                navigation: navigation,
                allowExternalBlocking: true
            ))
        }
    }
    
    @ViewBuilder
    func administrationTab(instance: any Instance) -> some View {
        VStack(spacing: Constants.main.standardSpacing) {
            ModlogButtonView(instance: instance)
            
            VStack(spacing: Constants.main.halfSpacing) {
                ForEach(instance.administrators_ ?? []) { person in
                    PersonListRow(person)
                        .quickSwipes(administratorQuickSwipes(person: person))
                }
            }
            
            if appState.firstApi.isAdmin {
                Button("Add Administrator", systemImage: Icons.add, action: openAddAdminSheet)
                    .buttonStyle(.capsule)
                    .padding(.bottom, Constants.main.halfSpacing)
                    .confirmationDialog("Add Administrator", isPresented: $showingConfirmation) {
                        Button("Yes", action: addNewAdmin)
                    } message: {
                        if let displayName = newAdmin?.displayName {
                            Text("Really appoint \(displayName) as an administrator of \(instance.displayName)?")
                        } else {
                            Text("Really appoint this user as an administrator of \(instance.displayName)?")
                        }
                    }
            }
        }
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
    
    @ViewBuilder
    func safetyTab(instance: any Instance) -> some View {
        if let fediseerData {
            InstanceSafetyView(instance: instance, fediseerData: fediseerData)
        } else {
            ProgressView()
                .padding(.top, 30)
        }
    }
}
