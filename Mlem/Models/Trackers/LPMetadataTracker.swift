//
//  LPMetadataTracker.swift
//  Mlem
//
//  Created by tht7 on 09/09/2023.
//

import Foundation
import LinkPresentation

class LPMetadataTracker {
    var onGoingTasks: [URL: Task<LPLinkMetadata?, Error>] = .init(minimumCapacity: 60)
    let cache: NSCache<NSString, LPLinkMetadata> = .init()
    
    // singleton to use in app
    static let shared = LPMetadataTracker()
    
    func fetchForLater(_ url: URL?) {
        cache.evictsObjectsWithDiscardedContent = true
        cache.countLimit = 64
        guard let url else { return }
        if cache.object(forKey: NSString(string: url.absoluteString)) != nil {
            return
        }
        if onGoingTasks[url] != nil {
            return
        }
        _fetch(url)
        return
    }
    
    func fetch(_ url: URL?) async -> LPLinkMetadata? {
        guard let url else { return nil; }
        if let task = onGoingTasks[url] {
            do {
                return try await task.value
            } catch {
                return nil
            }
        }
        if let metadata = cache.object(forKey: NSString(string: url.description)) {
            return metadata
        }
        do {
            return try await _fetch(url).value
        } catch {
            return nil
        }
    }
    
    @discardableResult
    private func _fetch(_ url: URL) -> Task<LPLinkMetadata?, Error> {
        let task = Task<LPLinkMetadata?, Error>(priority: .background) {
            var results: LPLinkMetadata?
            defer {
                if let res = results {
                    cache.setObject(res, forKey: NSString(string: url.absoluteString))
                }
                onGoingTasks[url] = nil
            }
            
            let metaFetcher = LPMetadataProvider()
            metaFetcher.shouldFetchSubresources = true
            do {
                results = try await metaFetcher.startFetchingMetadata(for: url)
            } catch {
                print(error.localizedDescription)
            }
            
            return results
        }
        onGoingTasks[url] = task
        return task
    }
}
