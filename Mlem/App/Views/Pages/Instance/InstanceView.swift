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
        
        var label: String {
            switch self {
            case .safety:
                "Trust & Safety"
            default:
                rawValue.capitalized
            }
        }
        
        var id: Self { self }
    }
    
    @Environment(Palette.self) var palette
    @Environment(AppState.self) var appState
    @Environment(\.colorScheme) var colorScheme
    
    // This is fetched from the instance itself, not from the logged-in account.
    @State var instance: any InstanceStubProviding
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
        .onPreferenceChange(IsAtTopPreferenceKey.self, perform: { value in
            isAtTop = value
        })
    }
    
    @ViewBuilder
    func content(_ instance: any Instance) -> some View {
        FancyScrollView {
            ProfileHeaderView(
                instance,
                type: .instance,
                blockedOverride: (appState.firstSession as? UserSession)?.blocks?.contains(instance)
            )
            .padding([.horizontal, .bottom], AppConstants.standardSpacing)
            BubblePicker(
                [.about, .details],
                selected: $selectedTab,
                withDividers: [.top, .bottom], label: { $0.label }
            )
            switch selectedTab {
            case .about:
                if let description = instance.description {
                    Markdown(description, configuration: .default)
                        .padding(.horizontal, AppConstants.standardSpacing)
                        .padding(.vertical, 16)
                }
            case .details:
                InstanceDetailsView(instance: instance)
                    .padding(.vertical, 16)
                    .background(palette.groupedBackground)
                if colorScheme == .light {
                    Divider()
                }
            default:
                EmptyView()
            }
        }
        .toolbar {
            let session = appState.firstSession as? UserSession
            let enabled = !(session?.ongoingInstanceBlockRequests.contains(instance.actorId) ?? true)
            ToolbarEllipsisMenu(
                instance.menuActions(
                    externalBlockStatus: session?.blocks?.contains(instance) ?? false,
                    externalBlockCallback: enabled ? { session?.toggleInstanceBlock(actorId: instance.actorId) } : nil
                )
            )
        }
    }
}
