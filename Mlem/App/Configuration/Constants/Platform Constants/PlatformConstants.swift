//
//  PlatformConstants.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-07.
//

import Foundation

// Struct enumerating all platform-specific constants
struct PlatformConstants {
    // Standard spacings
    let standardSpacing: CGFloat
    let halfSpacing: CGFloat
    let doubleSpacing: CGFloat
    let compactSpacing: CGFloat
    
    // Standard sizes
    let thumbnailSize: CGFloat
    let listRowAvatarSize: CGFloat
    let largeAvatarSize: CGFloat
    let mediumAvatarSize: CGFloat
    let smallAvatarSize: CGFloat
    
    // Standard corner radii
    let largeItemCornerRadius: CGFloat
    let mediumItemCornerRadius: CGFloat
    let smallItemCornerRadius: CGFloat
    
    // Non-standard dimensions
    let appIconSize: CGFloat
    let appIconCornerRadius: CGFloat
    let settingsIconSize: CGFloat
    let barIconSize: CGFloat
    let barIconCornerRadius: CGFloat
    let barIconPadding: CGFloat
    let barIconHitbox: CGFloat
}
