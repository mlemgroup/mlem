//
//  TabBarHostingController.swift
//  Mlem
//
//  Created by Sjmarf on 11/04/2024.
//

import Foundation
import SwiftUI

class CustomTabViewHostingController: UIHostingController<CustomTabItem> {
    init(rootView: CustomTabItem, index: Int) {
        super.init(rootView: rootView)
        
        self.tabBarItem = UITabBarItem(
            title: rootView.title,
            image: UIImage(systemName: rootView.systemImage),
            tag: index
        )
    }
    
    @available(*, unavailable)
    @MainActor dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}