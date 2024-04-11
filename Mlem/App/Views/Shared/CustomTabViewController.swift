//
//  CustomTabBarController.swift
//  Mlem
//
//  Created by Sjmarf on 11/04/2024.
//

import Foundation
import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    let swipeGestureCallback: () -> Void
    
    init(
        swipeGestureCallback: @escaping () -> Void,
        nibName: String? = nil,
        bundle: Bundle? = nil
    ) {
        self.swipeGestureCallback = swipeGestureCallback
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

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
        guard let viewControllers = viewControllers else { return }
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
            item?.rootView.onLongPress?()
            break
        }
    }
    
    @objc func swipeGestureTriggered(_ recognizer: UISwipeGestureRecognizer) {
        swipeGestureCallback()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print(tabBarController.selectedViewController?.tabBarItem.title)
        print("Selected view controller", viewController.tabBarItem.title)
        return true
    }
}
