//
//  APILocalSiteRateLimit+Mock.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Foundation

extension APILocalSiteRateLimit {
    static func mock(
        localSiteId: Int = 0,
        message: Int = 60,
        messagePerSecond: Int = 600,
        post: Int = 60,
        postPerSecond: Int = 600,
        register: Int = 60,
        registerPerSecond: Int = 600,
        image: Int = 60,
        imagePerSecond: Int = 600,
        comment: Int = 60,
        commentPerSecond: Int = 600,
        search: Int = 60,
        searchPerSecond: Int = 600,
        published: Date = .mock,
        updated: Date? = nil
    ) -> APILocalSiteRateLimit {
        .init(
            id: nil,
            localSiteId: localSiteId,
            message: message,
            messagePerSecond: messagePerSecond,
            post: post,
            postPerSecond: postPerSecond,
            register: register,
            registerPerSecond: registerPerSecond,
            image: image,
            imagePerSecond: imagePerSecond,
            comment: comment,
            commentPerSecond: commentPerSecond,
            search: search,
            searchPerSecond: searchPerSecond,
            published: published,
            updated: updated
        )
    }
}
