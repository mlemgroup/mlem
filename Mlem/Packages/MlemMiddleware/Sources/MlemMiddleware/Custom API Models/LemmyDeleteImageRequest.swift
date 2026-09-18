//
//  LemmyDeleteImageRequest.swift
//  Mlem
//
//  Created by Sjmarf on 2026-09-07.
//

import Rest

// Yes, this is a GET request. Allegedly DELETE is also accepted,
// but I couldn't get that to work. https://crates.io/crates/pict-rs
struct LemmyDeleteImageRequest: GetRequest {
    typealias Parameters = Never

    // The body is an empty string
    typealias Response = EmptyResponse

    let path: String
    let parameters: Never? = nil

    init(deleteToken: String, alias: String) {
        self.path = "pictrs/image/delete/\(deleteToken)/\(alias)"
    }
}
