//
//  MarkReadBatcher.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-08.
//

import Dependencies
import Foundation
import Semaphore

class MarkReadBatcher {
    @Dependency(\.notifier) var notifier
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.postRepository) var postRepository
    
    private let loadingSemaphore: AsyncSemaphore = .init(value: 1)
    
    private(set) var enabled: Bool = false
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
  
    func add(_ postId: Int) async {
        // FUTURE DEV: wouldn't it be nicer to pass in a PostModel and perform the mark read state fake here?
        // PAST DEV: no, that causes nasty little memory errors in fringe cases thanks to pass-by-reference. Trust in the safety of pass-by-value, future dev.
        
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
        pending.append(postId)
    }
}
