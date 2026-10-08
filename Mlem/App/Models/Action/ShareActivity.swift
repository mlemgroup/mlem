//
//  ShareActivity.swift
//  Mlem
//
//  Created by Sjmarf on 30/09/2024.
//

import Actions
import Icons
import SwiftUI

class ShareActivity: UIActivity {
    let title: String
    let icon: Icon

    let callback: @MainActor () -> Void
    
    init(action: Actions.Action, environment: EnvironmentValues) {
        let label = action.createAppearance(environment: environment).label(describing: .stateTransition)
        self.title = label.title
        self.icon = label.icon
        self.callback = { action.execute(environment: environment) }
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
        callback()
        activityDidFinish(true)
    }
}
