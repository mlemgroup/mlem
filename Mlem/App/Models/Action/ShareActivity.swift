//
//  ShareActivity.swift
//  Mlem
//
//  Created by Sjmarf on 30/09/2024.
//

import UIKit
import Icons

class ShareActivity: UIActivity {
    let title: String
    let icon: Icon

    let action: @MainActor () -> Void
    
    init(appearance: LegacyActionAppearance, performAction: @escaping @MainActor () -> Void) {
        self.title = appearance.label
        self.icon = .init(appearance.menuIcon)
        self.action = performAction
        super.init()
    }
    
    override var activityTitle: String? { title }

    override var activityImage: UIImage? {
        .init(systemName: icon.computeImageName())
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
