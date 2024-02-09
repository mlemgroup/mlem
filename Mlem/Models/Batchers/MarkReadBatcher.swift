//
//  MarkReadBatcher.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-08.
//

import Foundation
import Semaphore

class MarkReadBatcher: Batcher {
    private let loadingSemaphore: AsyncSemaphore = .init(value: 1)
    
    private(set) var enabled: Bool = false
    var batch: [Int] = .init()
    
    func resolveSiteVersion(to siteVersion: SiteVersion) {
        enabled = siteVersion >= .init("0.19.0")
    }
    
    func flush() async {
        // only one thread may execute this function at a time
        await loadingSemaphore.wait()
        defer { loadingSemaphore.signal() }
        
        await sendBatch()
        batch = .init()
    }
    
    func sendBatch() async {
        guard batch.count > 0 else {
            return
        }
        
        print("sending batch of size \(batch.count)")
    }
  
    func add(_ postId: Int) async {
        if batch.count >= 25 {
            await flush()
        }
        
        // This call is deliberately placed *after* the flush check to avoid the potential data race:
        // - Threads 0 and 1 call add() at the same time
        // - Thread 0's sends the batch
        // - Thread 1 adds its id to pending
        // - Thread 0's flush() call resets the batch, and thread 1's id is lost forever!
        batch.append(postId)
    }
}
