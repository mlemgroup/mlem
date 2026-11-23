//
//  NavigationRoot.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import SwiftUI

struct NavigationSplitRootView: View {
    @Setting(\.navigation_feedInSidebar) var feedInSidebar
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State var layer: NavigationLayer
    @State var sidebarLayer: NavigationLayer
    let sidebar: NavigationPage
    
    @State var columnVisibility: NavigationSplitViewVisibility = .all

    @State private var preferredColumn = NavigationSplitViewColumn.detail
    
    init(sidebar: NavigationPage, root: NavigationPage) {
        self._layer = .init(wrappedValue: .init(
            root: root,
            model: .main
        ))
        let sidebarLayer = NavigationLayer(root: sidebar, path: [root], model: .main)
        sidebarLayer.detailLayer = NavigationLayer(root: .dummy, model: .main)
        self._sidebarLayer = .init(wrappedValue: sidebarLayer)
        self.sidebar = sidebar
        self._columnVisibility = .init(wrappedValue: Settings.get(\.navigation_sidebarVisibleByDefault) ? .all : .detailOnly)
        if Settings.get(\.navigation_feedInSidebar) {
            self._preferredColumn = .init(wrappedValue: .sidebar)
        }
    }
    
    var body: some View {
        Group {
            if feedInSidebar {
                feedInSidebarSplitView
            } else {
                standardSplitView
            }
        }
        .onChange(of: feedInSidebar) {
            preferredColumn = feedInSidebar && !hasSelectedPost ? .sidebar : .detail
        }
    }

    var standardSplitView: some View {
        NavigationSplitView(
            columnVisibility: $columnVisibility,
            preferredCompactColumn: $preferredColumn,
            sidebar: {
                sidebar.view()
                    .navigationSplitViewColumnWidth(min: 200, ideal: 300, max: 500)
                    .environment(\.sidebarPresentationMode, preferredColumn == .sidebar ? .single : .double)
            },
            detail: {
                NavigationLayerView(layer: layer, hasSheetModifiers: false)
            }
        )
        .modifier(HandleThreadiverseLinksModifier())
        .environment(layer)
        .onChange(of: layer.root.updateCountHash) {
            preferredColumn = .detail
        }
    }

    var feedInSidebarSplitView: some View {
        NavigationSplitView(
            columnVisibility: $columnVisibility,
            preferredCompactColumn: $preferredColumn,
            sidebar: {
                NavigationLayerView(layer: sidebarLayer, hasSheetModifiers: false)
                    .navigationSplitViewColumnWidth(min: 320, ideal: 420, max: 600)
                    .environment(\.sidebarPresentationMode, .stacked)
            },
            detail: {
                Group {
                    if let postLayer = sidebarLayer.detailLayer, hasSelectedPost {
                        NavigationLayerView(layer: postLayer, hasSheetModifiers: false)
                            .id(postLayer.id)
                    } else {
                        ContentUnavailableView("No Post Selected", systemImage: "doc.text")
                            .background(.themedBackground)
                    }
                }
                .animation(nil, value: hasSelectedPost)
            }
        )
        .modifier(HandleThreadiverseLinksModifier())
        .environment(sidebarLayer)
        .onChange(of: sidebarLayer.detailLayer?.root.updateCountHash) {
            if hasSelectedPost {
                preferredColumn = .detail
            }
        }
        .onChange(of: preferredColumn) {
            if preferredColumn == .sidebar, horizontalSizeClass == .compact {
                withAnimation {
                    sidebarLayer.clearDetailLayer()
                }
            }
        }
    }

    var hasSelectedPost: Bool {
        switch sidebarLayer.detailLayer?.root.page {
        case .dummy, nil: false
        default: true
        }
    }
}

extension EnvironmentValues {
    @Entry var sidebarPresentationMode: SidebarPresentationMode = .single
}

enum SidebarPresentationMode {
    case single, double, stacked
}
