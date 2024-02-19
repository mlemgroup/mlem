//
//  APISaveUserSettings.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/SaveUserSettings.ts
struct APISaveUserSettings: Codable {
    let show_nsfw: Bool?
    let blur_nsfw: Bool?
    let auto_expand: Bool?
    let show_scores: Bool?
    let theme: String?
    let default_sort_type: APISortType?
    let default_listing_type: APIListingType?
    let interface_language: String?
    let avatar: String?
    let banner: String?
    let display_name: String?
    let email: String?
    let bio: String?
    let matrix_user_id: String?
    let show_avatars: Bool?
    let send_notifications_to_email: Bool?
    let bot_account: Bool?
    let show_bot_accounts: Bool?
    let show_read_posts: Bool?
    let discussion_languages: [Int]?
    let open_links_in_new_tab: Bool?
    let infinite_scroll_enabled: Bool?
    let post_listing_mode: APIPostListingMode?
    let enable_keyboard_navigation: Bool?
    let enable_animated_images: Bool?
    let collapse_bot_comments: Bool?

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
