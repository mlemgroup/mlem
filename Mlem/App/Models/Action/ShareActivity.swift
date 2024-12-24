//
//  ShareActivity.swift
//  Mlem
//
//  Created by Sjmarf on 30/09/2024.
//

import UIKit

class ShareActivity: UIActivity {
    let appearance: ActionAppearance
    let action: @MainActor () -> Void
    
    init(appearance: ActionAppearance, performAction: @escaping @MainActor () -> Void) {
        self.appearance = appearance
        self.action = performAction
        super.init()
    }
    
    override var activityTitle: String? {
        appearance.label
    }

    override var activityImage: UIImage? {
        .init(systemName: appearance.menuIcon)
    }
    
    override var activityType: UIActivity.ActivityType {
        UIActivity.ActivityType(rawValue: "com.hanners.mlem")
    }

    override class var activityCategory: UIActivity.Category {
        .action
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        true
    }
    
    @MainActor
    override func perform() {
        action()
        activityDidFinish(true)
    }
}
