//
//  ProfileTabLabel.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-08.
//

import Foundation

enum ProfileTabLabel: String {
    case username, instance, nickname, anonymous
}

extension ProfileTabLabel: SettingsOptions {
    var label: String { self.rawValue.capitalized }
    
    var id: Self { self }
}

extension ProfileTabLabel: AssociatedIcon {
    var iconName: String { "person.text.rectangle" }
    
    var iconNameFill: String { "person.text.rectangle.fill"}
}
