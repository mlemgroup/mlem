//
//  CustomTabBarController.swift
//  Mlem
//
//  Created by Sjmarf on 11/04/2024.
//

import Dependencies
import Foundation
import SwiftUI

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    @Binding var selectedIndexBinding: Int
    let swipeGestureCallback: () -> Void
    
    init(
        selectedIndex: Binding<Int>,
        swipeGestureCallback: @escaping () -> Void,
        nibName: String? = nil,
        bundle: Bundle? = nil
    ) {
        self.swipeGestureCallback = swipeGestureCallback
        self._selectedIndexBinding = selectedIndex
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
        tabBar.tintColor = UIColor(Palette.main.accent)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureTriggered(_:)))
        tabBar.addGestureRecognizer(longPressRecognizer)
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeGestureTriggered(_:)))
        swipeGestureRecognizer.direction = .up
        tabBar.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    @objc func longPressGestureTriggered(_ recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == .began else { return }
        guard let tabBar = recognizer.view as? UITabBar else { return }
        guard let tabBarItems = tabBar.items else { return }
        guard let viewControllers else { return }
        guard tabBarItems.count == viewControllers.count else { return }

        let loc = recognizer.location(in: tabBar)

        for (index, item) in tabBarItems.enumerated() {
            guard let view = item.value(forKey: "view") as? UIView else { continue }
            guard view.frame.contains(loc) else { continue }
            
            let item: CustomTabViewHostingController?
            if let navigationController = viewControllers[index] as? UINavigationController {
                item = navigationController.viewControllers.first as? CustomTabViewHostingController
            } else {
                item = viewControllers[index] as? CustomTabViewHostingController
            }
            item?.item.onLongPress?()
            break
        }
    }
    
    @objc func swipeGestureTriggered(_ recognizer: UISwipeGestureRecognizer) {
        swipeGestureCallback()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        TabReselectTracker.main.reset() // reset to prevent unconsumed actions from blocking the reselect flag
        if tabBarController.selectedViewController === viewController,
           let item = viewController as? CustomTabViewHostingController {
            print("\(item.item.title) tab re-selected")
            TabReselectTracker.main.signal()
        }
        selectedIndexBinding = viewControllers?.firstIndex(of: viewController) ?? 0
        return true
    }
}
