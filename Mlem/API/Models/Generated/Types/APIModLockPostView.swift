//
//  APIModLockPostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/ModLockPostView.ts
struct APIModLockPostView: Codable {
    let modLockPost: APIModLockPost
    let moderator: APIPerson?
    let post: APIPost
    let community: APICommunity
}
