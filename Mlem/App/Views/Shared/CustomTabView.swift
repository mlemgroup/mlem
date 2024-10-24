//
//  UITabBarWrapper.swift
//  Mlem
//
//  Created by Sjmarf on 11/04/2024.
//

import Foundation
import SwiftUI

struct CustomTabView: UIViewControllerRepresentable {
    @Environment(Palette.self) var palette
    
    let tabs: [CustomTabItem]
    let swipeGestureCallback: () -> Void
    
    @Binding var selectedIndex: Int
    
    init(selectedIndex: Binding<Int>, tabs: [CustomTabItem], onSwipeUp: @escaping () -> Void) {
        self.tabs = tabs
        self.swipeGestureCallback = onSwipeUp
        self._selectedIndex = selectedIndex
    }
    
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<CustomTabView>
    ) -> UITabBarController {
        let tabBarController = CustomTabBarController(
            selectedIndex: $selectedIndex,
            swipeGestureCallback: swipeGestureCallback
        )
        tabBarController.viewControllers = tabs.enumerated().map { CustomTabViewHostingController(item: $1, index: $0) }
        
        return tabBarController
    }
    
    func updateUIViewController(
        _ uiViewController: UITabBarController,
        context: UIViewControllerRepresentableContext<CustomTabView>
    ) {
        if let controller = uiViewController as? CustomTabBarController {
            Task.detached { @MainActor in
                for (tabData, tabBarItem) in zip(tabs, controller.tabBar.items ?? []) {
                    tabBarItem.title = tabData.title
                    
                    tabBarItem.badgeValue = tabData.badge
                    tabBarItem.image = tabData.image
                    tabBarItem.selectedImage = tabData.selectedImage
                    tabBarItem.badgeColor = UIColor(palette.warning)
                }
            }
        }
        
        withObservationTracking {
            _ = palette.accent
        } onChange: {
            if let controller = uiViewController as? CustomTabBarController {
                Task.detached { @MainActor in
                    controller.tabBar.tintColor = UIColor(palette.accent)
                }
            }
        }
        
        withObservationTracking {
            _ = AppState.main.contentViewTab
        } onChange: {
            if let controller = uiViewController as? CustomTabBarController {
                Task.detached { @MainActor in
                    controller.selectedIndex = selectedIndex
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: CustomTabView
        
        init(_ controller: CustomTabView) {
            self.parent = controller
        }
    }
}
