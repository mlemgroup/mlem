//
//  TabBarHostingController.swift
//  Mlem
//
//  Created by Sjmarf on 11/04/2024.
//

import Foundation
import SwiftUI

class CustomTabViewHostingController: UIHostingController<AnyView> {
    let item: CustomTabItem
    
    init(item: CustomTabItem, index: Int) {
        self.item = item
        super.init(rootView: item.content)
        
        self.tabBarItem = UITabBarItem(
            title: "rootView.title",
            image: .init(),
            selectedImage: .init()
        )
    }
    
    @available(*, unavailable)
    @MainActor dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
