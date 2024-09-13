//
//  Constants.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-07.
//

import Foundation
import KeychainAccess
import MlemMiddleware
import SwiftUI

class Constants {
    private var platformConstants: PlatformConstants
    
    public static let main: Constants = .init()
    
    private init() {
        if UIDevice.isPhone {
            self.platformConstants = .phone
        } else if UIDevice.isPad {
            self.platformConstants = .pad
        } else {
            assertionFailure("Unrecognized UIDevice!")
            self.platformConstants = .phone
        }
    }
    
    // MARK: - Common Constants
    
    // These constants are used across all platforms, and generally configure backend behavior
    
    // MARK: Versioning
    
    let minimumLemmyVersion: SiteVersion = .v18_0
    
    // MARK: Image Caching
    
    /// Size for the image cache (500MB)
    let cacheSize = 500_000_000
    /// URLCache to use for image caching
    let urlCache: URLCache = .init(memoryCapacity: 500_000_000, diskCapacity: 500_000_000)
    /// URLSession to use for image caching
    let urlSession: URLSession = .init(configuration: .default)
    /// Images are fetched at this resolution when displayed in the feed, and the maximum resolution is only fetched when the image viewer is opened
    let feedImageResolution: Int = 1024
    
    // MARK: Keychain

    let keychain: Keychain = .init(service: "com.hanners.Mlem-keychain")
    
    // MARK: - Platform Constants

    // These constants change depending on which platform the app is running on, and so passthrough to the current PlatformConstants. Standard dimensions are used for elements or element types that recur frequently, and are preferred over non-standard to promote a consistent layout structure. Non-standard spacings are used in cases where unique aesthetic considerations warrant deviation from the standards.
    
    // MARK: Standard Spacings
    
    /// Normal spacing between elements
    var standardSpacing: CGFloat { platformConstants.standardSpacing }
    /// Half of standardSpacing
    var halfSpacing: CGFloat { platformConstants.halfSpacing }
    /// Twice standardSpacing
    var doubleSpacing: CGFloat { platformConstants.doubleSpacing }
    /// Normal pacing between elements in a compact layout
    var compactSpacing: CGFloat { platformConstants.compactSpacing }
    
    // MARK: Standard Corner Radii
    
    /// Corner radius of a large item (tile post)
    var largeItemCornerRadius: CGFloat { platformConstants.largeItemCornerRadius }
    /// Corner radius of a medium item (website previews, large cards, etc.)
    var mediumItemCornerRadius: CGFloat { platformConstants.mediumItemCornerRadius }
    /// Corner radius of a small item (thumbnails, embedded cards, etc.)
    var smallItemCornerRadius: CGFloat { platformConstants.smallItemCornerRadius }
    
    // MARK: Sizes
    
    /// Size of a post thumbnail
    var thumbnailSize: CGFloat { platformConstants.thumbnailSize }
    /// Size of an avatar in a list context
    var listRowAvatarSize: CGFloat { platformConstants.listRowAvatarSize }
    /// Size of an avatar in a large label display
    var largeAvatarSize: CGFloat { platformConstants.largeAvatarSize }
    /// Size of an avatar in a medium label display
    var mediumAvatarSize: CGFloat { platformConstants.mediumAvatarSize }
    /// Size of an avatar in a compact label display
    var smallAvatarSize: CGFloat { platformConstants.smallAvatarSize }
    
    // MARK: Non-Standard Dimensions
    
    // App Icon
    
    /// Size of an app icon
    var appIconSize: CGFloat { platformConstants.appIconSize }
    /// Corner radius of an app icon
    var appIconCornerRadius: CGFloat { platformConstants.appIconCornerRadius }
    
    // Settings Icon
    
    /// Size of a settings icon
    var settingsIconSize: CGFloat { platformConstants.settingsIconSize }
    
    // Interaction Bar
    // Note: barIconHitbox = barIconSize + (2 * barIconPadding) + (2 * standardSpacing)
    
    /// Size of an interaction bar icon
    var barIconSize: CGFloat { platformConstants.barIconSize }
    /// Corner radius of an interaction bar icon's background
    var barIconCornerRadius: CGFloat { platformConstants.barIconCornerRadius }
    /// Padding between an interaction bar icon and its background
    var barIconPadding: CGFloat { platformConstants.barIconPadding }
    /// Tappable area for a bar icon (extends beyond visible background)
    var barIconHitbox: CGFloat { platformConstants.barIconHitbox }
}
