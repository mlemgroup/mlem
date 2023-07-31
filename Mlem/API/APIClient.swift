//
//  APIClient.swift
//  Mlem
//
//  Created by Nicholas Lawson on 04/06/2023.
//

import Foundation

enum HTTPMethod {
    case get
    case post(Data)
}

enum APIClientError: Error {
    case encoding(Error)
    case networking(Error)
    case response(APIErrorResponse, Int?)
    case cancelled
    case invalidSession
}

struct APISession {
    let token: String
    let URL: URL
}

class APIClient {

    let urlSession: URLSession
    let decoder: JSONDecoder
    
    private var _session: APISession?
    private var session: APISession {
        get throws {
            guard let _session else {
                throw APIClientError.invalidSession
            }
            
            return _session
        }
    }
    
    // MARK: - Initialisation
    
    init(session: URLSession = .init(configuration: .default), decoder: JSONDecoder = .defaultDecoder) {
        self.urlSession = session
        self.decoder = decoder
    }
    
    // MARK: - Public methods
    
    /// Configures the clients session based on the passed in account
    /// - Parameter account: a `SavedAccount` to use when configuring the clients session
    func configure(for account: SavedAccount) {
        self._session = .init(token: account.accessToken, URL: account.instanceLink)
    }
    
    @discardableResult
    func perform<Request: APIRequest>(request: Request) async throws -> Request.Response {
        
        let urlRequest = try urlRequest(from: request)

        let (data, response) = try await execute(urlRequest)
        
        if let response = response as? HTTPURLResponse {
            if response.statusCode >= 500 { // Error code for server being offline.
                throw APIClientError.response(
                    APIErrorResponse.init(error: "Instance appears to be offline.\nTry again later."),
                    response.statusCode
                )
            }
        }
        
        if let apiError = try? decoder.decode(APIErrorResponse.self, from: data) {
            // at present we have a single error model which appears to be used throughout
            // the API, however we may way to consider adding the error model type as an
            // associated value in the same was as the response to allow requests to define
            // their own error models when necessary, or drop back to this as the default...
            
            if apiError.isNotLoggedIn {
                throw APIClientError.invalidSession
            }
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            throw APIClientError.response(apiError, statusCode)
        }
        
        return try decoder.decode(Request.Response.self, from: data)
    }
    
    // MARK: - Private methods
    
    private func execute(_ urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await urlSession.data(for: urlRequest)
        } catch {
            if case URLError.cancelled = error as NSError {
                throw APIClientError.cancelled
            } else {
                throw APIClientError.networking(error)
            }
        }
    }

    private func urlRequest(from defintion: any APIRequest) throws -> URLRequest {
        var urlRequest = URLRequest(url: defintion.endpoint)
        defintion.headers.forEach { header in
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }

        if defintion as? any APIGetRequest != nil {
            urlRequest.httpMethod = "GET"
        } else if let postDefinition = defintion as? any APIPostRequest {
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = try createBodyData(for: postDefinition)
        } else if let putDefinition = defintion as? any APIPutRequest {
            urlRequest.httpMethod = "PUT"
            urlRequest.httpBody = try createBodyData(for: putDefinition)
        }

        return urlRequest
    }

    private func createBodyData(for defintion: any APIRequestBodyProviding) throws -> Data {
        do {
            return try JSONEncoder().encode(defintion.body)
        } catch {
            throw APIClientError.encoding(error)
        }
    }
}

// MARK: Post Requests
extension APIClient {
    func markPostAsRead(for postId: Int, read: Bool) async throws -> PostResponse {
        let request = MarkPostReadRequest(session: try session, postId: postId, read: read)
        print(request)
        return try await perform(request: request)
    }
}

// MARK: Comment Requests

extension APIClient {
    func loadComments(
        for postId: Int,
        maxDepth: Int = 15,
        type: FeedType = .all,
        sort: CommentSortType? = nil,
        page: Int? = nil,
        limit: Int? = nil,
        communityId: Int? = nil,
        communityName: String? = nil,
        parentId: Int? = nil,
        savedOnly: Bool? = nil
    ) async throws -> [APICommentView] {
        let request = GetCommentsRequest(
            session: try session,
            postId: postId,
            maxDepth: maxDepth,
            type: type,
            sort: sort,
            page: page,
            limit: limit,
            communityId: communityId,
            communityName: communityName,
            parentId: parentId,
            savedOnly: savedOnly
        )
        
        return try await perform(request: request).comments
    }
    
    func loadComment(id: Int) async throws -> CommentResponse {
        let request = GetCommentRequest(session: try session, id: id)
        return try await perform(request: request)
    }
    
    func createComment(
        content: String,
        languageId: Int? = nil,
        parentId: Int? = nil,
        postId: Int
    ) async throws -> CommentResponse {
        let request = CreateCommentRequest(
            session: try session,
            content: content,
            languageId: languageId,
            parentId: parentId,
            postId: postId
        )
        
        return try await perform(request: request)
    }
    
    func applyCommentScore(id: Int, score: Int) async throws -> CommentResponse {
        let request = CreateCommentLikeRequest(session: try session, commentId: id, score: score)
        return try await perform(request: request)
    }
    
    func editComment(
        id: Int,
        content: String? = nil,
        distinguished: Bool? = nil,
        languageId: Int? = nil,
        formId: String? = nil
    ) async throws -> CommentResponse {
        let request = EditCommentRequest(
            session: try session,
            commentId: id,
            content: content,
            distinguished: distinguished,
            languageId: languageId,
            formId: formId
        )
        
        return try await perform(request: request)
    }
    
    func deleteComment(
        id: Int,
        deleted: Bool
    ) async throws -> CommentResponse {
        let request = DeleteCommentRequest(session: try session, commentId: id, deleted: deleted)
        return try await perform(request: request)
    }
    
    func saveComment(id: Int, shouldSave: Bool) async throws -> CommentResponse {
        let request = SaveCommentRequest(session: try session, commentId: id, save: shouldSave)
        return try await perform(request: request)
    }
    
    func reportComment(id: Int, reason: String) async throws -> CreateCommentReportResponse {
        let request = CreateCommentReportRequest(session: try session, commentId: id, reason: reason)
        return try await perform(request: request)
    }
    
    // MARK: Person Requests
    func getUnreadCount() async throws -> APIPersonUnreadCounts {
        let request = GetPersonUnreadCount(session: try session)
        return try await perform(request: request)
    }
    
    func markAllAsRead() async throws {
        let request = MarkAllAsRead(session: try session)
        try await perform(request: request)
    }
}
