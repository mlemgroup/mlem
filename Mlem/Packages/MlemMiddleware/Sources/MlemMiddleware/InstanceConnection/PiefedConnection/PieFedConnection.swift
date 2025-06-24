//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-05.
//

import Foundation
import Rest

public class PieFedConnection: InstanceConnection {
    private let restClient = RestClient<ApiErrorResponse>()
    
    enum PieFedConnectionError: Error {
        case invalidSession
    }
    
    struct Context {
        let siteVersion: SiteVersion
        let myPersonId: Int?
    }

    public let baseUrl: URL
    public var token: String?
    
    private(set) var contextDataManager: SharedTaskManager<Context, ApiGetSiteResponse> = .init()

    public var fetchedVersion: SiteVersion? {
        contextDataManager.fetchedValue?.siteVersion
    }
    
    /// Returns the `fetchedVersion` if the version has already been fetched. Otherwise, waits until the version has been fetched before returning the received value.
    public var version: SiteVersion {
        get async throws {
            try await contextDataManager.getValue().siteVersion
        }
    }
    
    public var myPersonId: Int? {
        get async throws {
            try await contextDataManager.getValue().myPersonId
        }
    }
    
    public var contextIsFetched: Bool {
        contextDataManager.fetchedValue != nil
    }
    
    public func ensureContextPresence() async throws {
        try await contextDataManager.getValue()
    }
    
    public required init(baseUrl: URL, token: String? = nil) {
        self.baseUrl = baseUrl
        self.token = token
        contextDataManager.fetchTask = {
            try await self.rawGetMyPerson()
        }
        contextDataManager.createValue = { response in
            .init(siteVersion: .init(response.version), myPersonId: response.myUser?.localUserView.person.id)
        }
    }

    public func updateToken(_ newToken: String) {
        token = newToken
    }

    @discardableResult
    func perform<Request: RestRequest>(_ request: Request, tokenOverride: String? = nil) async throws -> Request.Response {
        let token = tokenOverride ?? token
        do throws(RestError) {
            return try await restClient.perform(baseUrl: baseUrl, request, token: token)
        } catch {
            switch error {
            case let RestError.response(response, statusCode: _):
                if ApiErrorResponse(error: response).isNotLoggedIn {
                    if token == nil {
                        throw ApiClientError.notLoggedIn
                    } else {
                        throw PieFedConnectionError.invalidSession
                    }
                } else {
                    throw ApiClientError(from: error)
                }
            default:
                throw ApiClientError(from: error)
            }
        }
    }
}
