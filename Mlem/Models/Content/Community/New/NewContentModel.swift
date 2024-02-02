//
//  ContentModel.swift
//  Mlem
//
//  Created by Sjmarf on 02/02/2024.
//


protocol APIContentType {
    var contentId: Int { get }
}

protocol NewContentModel: AnyObject {
    associatedtype APIType: APIContentType
    
    var contentId: Int { get }
    static var cache: ContentCache<Self> { get }
    init(from: APIType)
}