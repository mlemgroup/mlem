//
//  NavigationRoot.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import SwiftUI
import SwiftUIIntrospect

struct NavigationSplitRootView: View {
    @Setting(\.navigation_feedInSidebar) var feedInSidebar
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State var layer: NavigationLayer
    @State var sidebarLayer: NavigationLayer
    @State var postLayer: NavigationLayer
    let sidebar: NavigationPage
    
    @State var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var splitViewController: UISplitViewController?

    @State private var preferredColumn = NavigationSplitViewColumn.detail
    
    init(sidebar: NavigationPage, root: NavigationPage) {
        self._layer = .init(wrappedValue: .init(
            root: root,
            model: .main
        ))
        let sidebarLayer = NavigationLayer(root: sidebar, path: [root], model: .main)
        let postLayer = NavigationLayer(root: .noPostSelected, model: .main)
        sidebarLayer.detailLayer = postLayer
        postLayer.sidebarLayer = sidebarLayer
        self._sidebarLayer = .init(wrappedValue: sidebarLayer)
        self._postLayer = .init(wrappedValue: postLayer)
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
        .modifier(HandleThreadiverseLinksModifier())
        .environment(feedInSidebar ? sidebarLayer : layer)
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
                NavigationLayerView(layer: postLayer, hasSheetModifiers: false)
                    .animation(nil, value: hasSelectedPost)
            }
        )
        .onChange(of: postLayer.root.updateCountHash) {
            preferredColumn = hasSelectedPost ? .detail : .sidebar
        }
        .onChange(of: sidebarLayer.path.count) {
            if horizontalSizeClass == .compact {
                preferredColumn = .sidebar
            }
        }
        .introspect(.navigationSplitView, on: .iOS(.v26, .v27)) {
            if splitViewController !== $0 {
                splitViewController = $0
                $0.registerForTraitChanges(
                    [UITraitHorizontalSizeClass.self]
                ) { (splitViewController: UISplitViewController, _: UITraitCollection) in
                    if splitViewController.traitCollection.horizontalSizeClass == .regular {
                        Self.showSidebarIfHidden(in: splitViewController)
                    }
                }
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
        if case .noPostSelected = postLayer.root.page { false } else { true }
    }

    private static func showSidebarIfHidden(in splitViewController: UISplitViewController) {
        let showSidebar = {
            if splitViewController.displayMode == .secondaryOnly {
                splitViewController.preferredDisplayMode = .oneBesideSecondary
            }
        }
        if let transitionCoordinator = splitViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: nil) { _ in showSidebar() }
        } else {
            showSidebar()
        }
    }
}

extension EnvironmentValues {
    @Entry var sidebarPresentationMode: SidebarPresentationMode = .single
}

enum SidebarPresentationMode {
    case single, double, stacked
}
