//
//  ContentModel.swift
//  Mlem
//
//  Created by Sjmarf on 22/09/2023.
//

import Foundation

protocol ContentModel: Equatable {
    var uid: ContentModelIdentifier { get }
    var imageUrls: [URL] { get }
    var searchResultScore: Int { get }
}

extension ContentModel where Self: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.uid == rhs.uid
    }
}

struct AnyContentModel: ContentModel {
    let wrappedValue: any ContentModel
    init(_ wrappedValue: any ContentModel) {
        self.wrappedValue = wrappedValue
    }
    
    var uid: ContentModelIdentifier { wrappedValue.uid }
    var imageUrls: [URL] { wrappedValue.imageUrls }
    var searchResultScore: Int { wrappedValue.searchResultScore }
}
