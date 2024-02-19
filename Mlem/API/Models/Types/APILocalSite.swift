//
//  APILocalSite.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/LocalSite.ts
struct APILocalSite: Codable {
    let id: Int
    let site_id: Int
    let site_setup: Bool
    let enable_downvotes: Bool
    let enable_nsfw: Bool
    let community_creation_admin_only: Bool
    let require_email_verification: Bool
    let application_question: String?
    let private_instance: Bool
    let default_theme: String
    let default_post_listing_type: APIListingType
    let legal_information: String?
    let hide_modlog_mod_names: Bool
    let application_email_admins: Bool
    let slur_filter_regex: String?
    let actor_name_max_length: Int
    let federation_enabled: Bool
    let captcha_enabled: Bool
    let captcha_difficulty: String
    let published: String
    let updated: String?
    let registration_mode: APIRegistrationMode
    let reports_email_admins: Bool
    let federation_signed_fetch: Bool

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
