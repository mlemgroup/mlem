//
//  ContentModel.swift
//  Mlem
//
//  Created by Sjmarf on 22/09/2023.
//

import Foundation

protocol ContentModel {
    var uid: ContentModelIdentifier { get }
    var imageUrls: [URL] { get }
}

public struct AnyContentModel: ContentModel {
    let wrappedValue: any ContentModel
    init(_ wrappedValue: any ContentModel) {
        self.wrappedValue = wrappedValue
    }
    
    var uid: ContentModelIdentifier { self.wrappedValue.uid }
    var imageUrls: [URL] { self.wrappedValue.imageUrls }
}
