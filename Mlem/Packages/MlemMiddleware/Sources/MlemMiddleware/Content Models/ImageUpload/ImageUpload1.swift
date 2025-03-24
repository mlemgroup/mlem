//
//  ImageUpload1.swift
//
//
//  Created by Sjmarf on 26/08/2024.
//

import Foundation
import Observation

// There are no higher tiers of this model yet - in future `ImageUpload2` will be
// created from `ApiLocalImage` and `ImageUpload3` will be created from `ApiLocalImageView`.

@Observable
public class ImageUpload1: ImageUpload1Providing {
    public static let tierNumber: Int = 1
    public var api: ApiClient
    public var mediaUpload1: ImageUpload1 { self }
    
    // This includes the file extension
    let alias: String
    let deleteToken: String
    
    public internal(set) var deleted: Bool = false
    
    public var url: URL {
        api.baseUrl.appending(path: "pictrs/image/\(alias)")
    }
    
    init(api: ApiClient, alias: String, deleteToken: String) {
        self.api = api
        self.alias = alias
        self.deleteToken = deleteToken
    }
}
