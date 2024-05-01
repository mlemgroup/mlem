//
//  UITabBarWrapper.swift
//  Mlem
//
//  Created by Sjmarf on 11/04/2024.
//

import Foundation
import SwiftUI

struct CustomTabView: UIViewControllerRepresentable {
    var viewControllers: [CustomTabViewHostingController]
    let swipeGestureCallback: () -> Void
    
    init(tabs: [CustomTabItem], onSwipeUp: @escaping () -> Void) {
        self.viewControllers = tabs.enumerated().map { CustomTabViewHostingController(rootView: $1, index: $0) }
        self.swipeGestureCallback = onSwipeUp
    }
    
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<CustomTabView>
    ) -> UITabBarController {
        let tabBarController = CustomTabBarController(swipeGestureCallback: swipeGestureCallback)
        tabBarController.viewControllers = viewControllers
        return tabBarController
    }
    
    func updateUIViewController(
        _ uiViewController: UITabBarController,
        context: UIViewControllerRepresentableContext<CustomTabView>
    ) {
        // no-op
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
