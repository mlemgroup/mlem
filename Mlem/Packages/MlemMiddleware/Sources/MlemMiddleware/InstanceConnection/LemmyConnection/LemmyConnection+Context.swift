//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-08-10.
//

import Foundation

extension LemmyConnection {
    // For use inside LemmyConnection only
    func getRawContext() async throws -> RawContext {
        // Inconveniently, PieFed offers the `api/v3/site` endpoint in an attempt to look like a Lemmy instance.
        // We need to check that this *isn't* a PieFed instance, which we can do by making a second request.
        // The type of request doesn't matter - we're using `UnreadCountRequest` here.
        
        let response = try await processingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                async let site = await self.perform(LemmyGetSiteRequest(endpoint: .v3), endpoint: .v3)
                async let other = await self.perform(LemmyUnreadCountRequest(), endpoint: .v3)
                do {
                    _ = try await other
                } catch ApiClientError.notLoggedIn {
                    // no-op
                }
                let response = try await site
                return RawContext(site: response, myUser: response.myUser)
            case .v4:
                async let site = await self.perform(LemmyGetSiteRequest(endpoint: .v4), endpoint: .v4)
                
                var myUser: LemmyMyUserInfo?
                if self.token != nil {
                    myUser = try await self.perform(LemmyGetMyUserRequest(), endpoint: .v4)
                }
                
                return try await .init(site: site, myUser: myUser)
            }
        }
        return response
    }
    
    // Calls getRawContext, but if there's already a task running in the `contextDataManager` uses that instead.
    func getRawContextWithCaching() async throws -> RawContext {
        if let ongoingTask = contextDataManager.ongoingTask {
            return try await ongoingTask.result.get()
        } else {
            let task = Task(operation: getRawContext)
            Task.detached {
                _ = try await self.contextDataManager.getValue(task: task)
            }
            return try await task.result.get()
        }
    }
}
