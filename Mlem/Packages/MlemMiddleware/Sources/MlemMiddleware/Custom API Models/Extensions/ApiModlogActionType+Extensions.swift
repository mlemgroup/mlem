//
//  ApiModlogActionType+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-28.
//  

import Foundation

extension ApiModlogActionType {
    static var allFilteredCases: [ApiModlogActionType] = [
        .modRemovePost,
        .modLockPost,
        .modFeaturePost,
        .modRemoveComment,
        .modRemoveCommunity,
        .modBanFromCommunity,
        .modAddCommunity,
        .modTransferCommunity,
        .modAdd,
        .modBan,
        .modHideCommunity,
        .adminPurgePerson,
        .adminPurgeCommunity,
        .adminPurgePost,
        .adminPurgeComment
    ]
}
