//
//  APILocalUser.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/LocalUser.ts
struct APILocalUser: Codable {
    let id: Int
    let person_id: Int
    let email: String?
    let show_nsfw: Bool
    let theme: String
    let default_sort_type: APISortType
    let default_listing_type: APIListingType
    let interface_language: String
    let show_avatars: Bool
    let send_notifications_to_email: Bool
    let show_scores: Bool
    let show_bot_accounts: Bool
    let show_read_posts: Bool
    let email_verified: Bool
    let accepted_application: Bool
    let open_links_in_new_tab: Bool
    let blur_nsfw: Bool
    let auto_expand: Bool
    let infinite_scroll_enabled: Bool
    let admin: Bool
    let post_listing_mode: APIPostListingMode
    let totp_2fa_enabled: Bool
    let enable_keyboard_navigation: Bool
    let enable_animated_images: Bool
    let collapse_bot_comments: Bool
}
