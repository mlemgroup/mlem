//
//  APIEditSite.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/EditSite.ts
struct APIEditSite: Codable {
    let name: String?
    let sidebar: String?
    let description: String?
    let icon: URL?
    let banner: URL?
    let enable_downvotes: Bool?
    let enable_nsfw: Bool?
    let community_creation_admin_only: Bool?
    let require_email_verification: Bool?
    let application_question: String?
    let private_instance: Bool?
    let default_theme: String?
    let default_post_listing_type: APIListingType?
    let legal_information: String?
    let application_email_admins: Bool?
    let hide_modlog_mod_names: Bool?
    let discussion_languages: [Int]?
    let slur_filter_regex: String?
    let actor_name_max_length: Int?
    let rate_limit_message: Int?
    let rate_limit_message_per_second: Int?
    let rate_limit_post: Int?
    let rate_limit_post_per_second: Int?
    let rate_limit_register: Int?
    let rate_limit_register_per_second: Int?
    let rate_limit_image: Int?
    let rate_limit_image_per_second: Int?
    let rate_limit_comment: Int?
    let rate_limit_comment_per_second: Int?
    let rate_limit_search: Int?
    let rate_limit_search_per_second: Int?
    let federation_enabled: Bool?
    let federation_debug: Bool?
    let captcha_enabled: Bool?
    let captcha_difficulty: String?
    let allowed_instances: [String]?
    let blocked_instances: [String]?
    let taglines: [String]?
    let registration_mode: APIRegistrationMode?
    let reports_email_admins: Bool?
}
