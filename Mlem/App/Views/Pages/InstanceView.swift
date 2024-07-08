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
    
    @State var internalInstance: any InstanceStubProviding
    @State var externalInstance: (any InstanceStubProviding)?
    
    @State var internalUpgradeState: LoadingState = .idle
    @State var externalUpgradeState: LoadingState = .idle
    
    @State var selectedTab: Tab = .about
    
    var internalStub: InstanceStub {
        .init(api: appState.firstApi, actorId: internalInstance.actorId)
    }
    
    var displayInstance: any InstanceStubProviding {
        guard let externalInstance else { return internalInstance }
        if type(of: internalInstance).tierNumber >= type(of: externalInstance).tierNumber {
            return internalInstance
        }
        return externalInstance
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
            if let displayInstance = displayInstance as? any Instance {
                content(displayInstance)
            } else {
                ProgressView()
                    .tint(palette.secondary)
            }
        }
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
    }
    
    @ViewBuilder
    func content(_ displayInstance: any Instance) -> some View {
        FancyScrollView {
            VStack(spacing: AppConstants.standardSpacing) {
                ProfileHeaderView(displayInstance, type: .instance)
                    .padding(.horizontal, AppConstants.standardSpacing)
                BubblePicker(
                    [.about, .administration, .details],
                    selected: $selectedTab,
                    withDividers: [.top, .bottom], label: { $0.label }
                )
                if let description = displayInstance.description {
                    Markdown(description, configuration: .default)
                        .padding(.horizontal, AppConstants.standardSpacing)
                }
            }
        }
        .toolbar {
            ToolbarEllipsisMenu(
                (internalInstance as? any Instance)?.menuActions() ?? displayInstance.menuActions()
            )
        }
    }
}
