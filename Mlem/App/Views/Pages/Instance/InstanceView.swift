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
    
    @State var internalInstance: any InstanceStubProviding
    @State var externalInstance: Instance3?
    
    @State var internalUpgradeState: LoadingState = .idle
    @State var externalUpgradeState: LoadingState = .idle
    
    @State var selectedTab: Tab = .about
    @State var isAtTop: Bool = true
    
    var internalStub: InstanceStub {
        .init(api: appState.firstApi, actorId: internalInstance.actorId)
    }
    
    init(instance: any InstanceStubProviding) {
        if instance.actorId == AppState.main.firstApi.actorId, AppState.main.firstSession.instance != nil {
            self.externalInstance = AppState.main.firstSession.instance
            self.internalInstance = AppState.main.firstSession.instance ?? instance
            self.internalUpgradeState = .done
            self.externalUpgradeState = .done
        } else {
            self.externalInstance = nil
            self.internalInstance = instance
        }
    }
    
    var body: some View {
        VStack {
            if let externalInstance {
                content(externalInstance)
                    .navigationTitle(isAtTop ? "" : externalInstance.displayName)
            } else {
                ProgressView()
                    .tint(palette.secondary)
            }
        }
        .animation(.easeOut(duration: 0.2), value: externalInstance is any Instance)
        .task {
            guard internalUpgradeState == .idle else { return }
            internalUpgradeState = .loading
            do {
                internalInstance = try await internalStub.upgrade()
                internalUpgradeState = .done
            } catch {
                internalUpgradeState = .idle
                handleError(error)
            }
        }
        .task {
            guard externalUpgradeState == .idle else { return }
            externalUpgradeState = .loading
            do {
                externalInstance = try await internalStub.upgradeLocal()
                externalUpgradeState = .done
            } catch {
                externalUpgradeState = .idle
                handleError(error)
            }
        }
        .onPreferenceChange(IsAtTopPreferenceKey.self, perform: { value in
            isAtTop = value
        })
    }
    
    @ViewBuilder
    func content(_ externalInstance: any Instance) -> some View {
        FancyScrollView {
            ProfileHeaderView(externalInstance, type: .instance, blockedOverride: internalInstance.blocked_)
                .padding([.horizontal, .bottom], AppConstants.standardSpacing)
            BubblePicker(
                [.about, .details],
                selected: $selectedTab,
                withDividers: [.top, .bottom], label: { $0.label }
            )
            switch selectedTab {
            case .about:
                if let description = externalInstance.description {
                    Markdown(description, configuration: .default)
                        .padding(.horizontal, AppConstants.standardSpacing)
                        .padding(.vertical, 16)
                }
            case .details:
                InstanceDetailsView(instance: externalInstance)
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
            ToolbarEllipsisMenu(
                (internalInstance as? any Instance)?.menuActions() ?? externalInstance.menuActions()
            )
        }
    }
}
