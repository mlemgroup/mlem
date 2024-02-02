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
    func update(with: APIType)
}

private struct WeakReference<Content: ContentModel> {
    weak var content: Content?
}

class ContentCache<Content: ContentModel> {
    private var cachedItems: [WeakReference<Content>] = .init()
    
    func createModel(for apiType: Content.APIType) -> Content {
        if let item = cachedItems.first(where: { $0.content?.contentId == apiType.contentId }) {
            print("Using existing item for id \(apiType.contentId)")
            return item.content!
        }
        print("Creating new item for id \(apiType.contentId)")
        let newItem = Content(from: apiType)
        cachedItems.append(.init(content: newItem))
        return newItem
        
        // IMPORTANT - we use weak references here to avoid storing extra ContentModel
        // instances unecessarily, but we do not yet remove the empty WeakReference
        // wrappers from the array. We'll need to check and purge empty wrappers every now
        // and again to prevent them from piling up
    }
}