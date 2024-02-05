//
//  ProfileTabLabel.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-08.
//

import Foundation

enum ProfileTabLabel: String {
    case nickname, instance, anonymous
}

extension ProfileTabLabel: SettingsOptions {
    var label: String { rawValue.capitalized }
    
    var id: Self { self }
}

extension ProfileTabLabel: AssociatedIcon {
    var iconName: String { "person.text.rectangle" }
    
    var iconNameFill: String { "person.text.rectangle.fill" }
}
