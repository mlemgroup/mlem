//
//  APIMyUserInfo.swift
//  Mlem
//
//  Created by Jonathan de Jong on 14.06.2023
//

import Foundation

// lemmy_api_common::site::MyUserInfo
struct APIMyUserInfo: Decodable {
    // Some properties aren't implemented yet: https://join-lemmy.org/api/interfaces/MyUserInfo.html
    var localUserView: APILocalUserView
    let moderates: [APICommunityModeratorView]
    var discussionLanguages: [Int]
    var communityBlocks: [APICommunityBlockView]
    var personBlocks: [APIUserBlockView]
    var instanceBlocks: [APIInstanceBlockView]? // Nil pre-0.19.0
}

struct APICommunityBlockView: Decodable {
    let community: APICommunity
    let person: APIPerson
}

struct APIUserBlockView: Decodable {
    let target: APIPerson
    let person: APIPerson
}

struct APIInstanceBlockView: Decodable {
    let instance: APIInstance
    let person: APIPerson
}

struct APIInstance: Decodable, Identifiable {
    // Not all properties implemented yet https://join-lemmy.org/api/interfaces/Instance.html
    let id: Int
    let domain: String
}
