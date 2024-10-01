//
//  PhoneConstants.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-07.
//

import Foundation

// iPhone-specific constants
extension PlatformConstants {
    static let phone: PlatformConstants = .init(
        standardSpacing: 10,
        halfSpacing: 5,
        doubleSpacing: 20,
        compactSpacing: 6,
        thumbnailSize: 60,
        listRowAvatarSize: 46,
        largeAvatarSize: 36,
        mediumAvatarSize: 24,
        smallAvatarSize: 16,
        largeItemCornerRadius: 16,
        mediumItemCornerRadius: 8,
        smallItemCornerRadius: 6,
        appIconSize: 60,
        appIconCornerRadius: 10,
        settingsIconSize: 28,
        barIconSize: 18,
        barIconCornerRadius: 4,
        barIconPadding: 4.24,
        barIconHitbox: 36 // TODO: ERIC make "circle" constants
    )
}
