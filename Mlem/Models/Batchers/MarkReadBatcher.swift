//
//  MarkReadBatcher.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-08.
//

import Dependencies
import Foundation
import Semaphore

/// Class to handle accumulating and dispatching batch mark read requests. It maintains three collections of post IDs:
/// - Staged: post IDs that are ready to mark as read, but should not be marked just yet (even if threshold is met)
/// - Pending: post IDs that are queued to be marked read
/// - Sending: post IDs currently being marked read
/// To mark a post as read, it must first be staged; `add()` will ignore any request for a non-staged post. This is done to interface smoothly with the view logic that handles mark read on scroll; posts are flagged to be marked read when a later post appears, but only marked read once they disappear. The later post simply calls `stage()` in an `onAppear()` and the post itself calls `add()` in an `onDisappear()`, and the staging logic handles the rest.
class MarkReadBatcher {
    @Dependency(\.notifier) var notifier
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.postRepository) var postRepository
    @Dependency(\.apiClient) var apiClient
    
    private let loadingSemaphore: AsyncSemaphore = .init(value: 1)
    private let stagedSemaphore: AsyncSemaphore = .init(value: 1)
    
    private(set) var enabled: Bool = false
    private var staged: Set<Int> = .init()
    private var pending: [Int] = .init()
    private var sending: [Int] = .init()
    
    func resolveSiteVersion(to siteVersion: SiteVersion) {
        enabled = siteVersion >= .init("0.19.0")
    }
    
    func flush() async {
        // only one thread may execute this function at a time to avoid duplicate requests
        await loadingSemaphore.wait()
        defer { loadingSemaphore.signal() }
        
        sending = pending
        pending = .init()
        
        // perform this on background thread to return ASAP
        Task {
            await dispatchSending()
        }
    }
    
    func clearStaged() {
        staged.removeAll()
    }
    
    func dispatchSending() async {
        guard sending.count > 0 else {
            return
        }
        
        do {
            try await postRepository.markRead(postIds: sending, read: true)
        } catch {
            errorHandler.handle(error)
        }
        
        sending = .init()
    }
    
    func stage(_ postId: Int) async {
        guard enabled else {
            assertionFailure("Cannot stage to disabled batcher!")
            return
        }
        
        await stagedSemaphore.wait()
        staged.insert(postId)
        stagedSemaphore.signal()
    }
  
    func add(post: PostModel) async {
        guard enabled else {
            assertionFailure("Cannot add to disabled batcher!")
            return
        }
        
        if pending.count >= 50 {
            await flush()
        }
        
        // This call is deliberately placed *after* the flush check to avoid the potential data race:
        // - Threads 0 and 1 call add() at the same time
        // - Thread 0 calls flush() and performs sending = pending
        // - Thread 1 adds its id to pending
        // - Thread 0 performs pending = .init(), and thread 1's id is lost forever!
        await stagedSemaphore.wait()
        if staged.contains(post.postId) {
            pending.append(post.postId)
            staged.remove(post.postId)
            await post.setRead(true)
        }
        stagedSemaphore.signal()
    }
}
