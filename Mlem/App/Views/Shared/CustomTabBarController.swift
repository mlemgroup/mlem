//
//  CustomTabBarController.swift
//  Mlem
//
//  Created by Sjmarf on 11/04/2024.
//

import Dependencies
import Foundation
import os
import SwiftUI
import Theming

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    private let log: Logger = .mlemLogger()
    
    @Binding var selectedIndexBinding: Int
    let swipeGestureCallback: () -> Void
    let palette: Theming.Palette
    
    init(
        selectedIndex: Binding<Int>,
        swipeGestureCallback: @escaping () -> Void,
        palette: Theming.Palette,
        nibName: String? = nil,
        bundle: Bundle? = nil
    ) {
        self.swipeGestureCallback = swipeGestureCallback
        self._selectedIndexBinding = selectedIndex
        self.palette = palette
        super.init(nibName: nibName, bundle: bundle)
    }
    
    // This is used for Storyboard, and wont ever be called as long as we dont use Storyboard
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        hidesBottomBarWhenPushed = true
        tabBar.tintColor = UIColor(palette.accent)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard !TabReselectTracker.main.blockTabSwitch else {
            return false
        }
        
        TabReselectTracker.main.reset() // reset to prevent unconsumed actions from blocking the reselect flag
        if tabBarController.selectedViewController === viewController,
           let item = viewController as? CustomTabViewHostingController {
            log.debug("\(item.item.title) tab re-selected")
            TabReselectTracker.main.signal()
            return TabReselectTracker.main.consumers == 0
        }
        selectedIndexBinding = viewControllers?.firstIndex(of: viewController) ?? 0
        return true
    }
}
