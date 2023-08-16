//
//  APIClient.swift
//  Mlem
//
//  Created by Nicholas Lawson on 04/06/2023.
//

// swiftlint:disable file_length

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
        return try await perform(request: request)
    }
    
    func loadPost(id: Int, commentId: Int? = nil) async throws -> APIPostView {
        let request = GetPostRequest(session: try session, id: id, commentId: commentId)
        return try await perform(request: request).postView
    }
    
    func createPost(
        communityId: Int,
        name: String,
        nsfw: Bool?,
        body: String?,
        url: String?
    ) async throws -> PostResponse {
        let request = CreatePostRequest(
            session: try session,
            communityId: communityId,
            name: name,
            nsfw: nsfw,
            body: body,
            url: url
        )
        
        return try await perform(request: request)
    }
    
    func editPost(
        postId: Int,
        name: String?,
        url: String?,
        body: String?,
        nsfw: Bool?,
        languageId: Int? = nil
    ) async throws -> PostResponse {
        let request = EditPostRequest(
            session: try session,
            postId: postId,
            name: name,
            url: url,
            body: body,
            nsfw: nsfw,
            languageId: languageId
        )
        
        return try await perform(request: request)
    }
    
    func ratePost(id: Int, score: ScoringOperation) async throws -> APIPostView {
        let request = CreatePostLikeRequest(session: try session, postId: id, score: score)
        return try await perform(request: request).postView
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
    
    func markCommentReplyRead(id: Int, isRead: Bool) async throws -> CommentReplyResponse {
        let request = MarkCommentReplyAsRead(session: try session, commentId: id, read: isRead)
        return try await perform(request: request)
    }
    
    // MARK: Person Requests
    
    func getUnreadCount() async throws -> APIPersonUnreadCounts {
        let request = GetPersonUnreadCount(session: try session)
        return try await perform(request: request)
    }
    
    func getPersonDetails(session: APISession, username: String) async throws -> GetPersonDetailsResponse {
        // this call is used when a user is logging in and creating an account for the first time
        // so an external session is required, as the expectation is the client will not yet have a session or
        // the session will be for another account.
        let request = try GetPersonDetailsRequest(session: session, username: username)
        return try await perform(request: request)
    }
    
    func getPersonDetails(for personId: Int, limit: Int?, savedOnly: Bool) async throws -> GetPersonDetailsResponse {
        // this call is made by the `UserView` to load this user, or other Lemmy users details
        // TODO: currently only the first page is loaded, with the passed in limit - we should instead be loading on
        // demand as the user scrolls through this feed similar to what we do elsewhere
        let request = try GetPersonDetailsRequest(
            session: try session,
            limit: limit,
            savedOnly: savedOnly,
            personId: personId
        )
        
        return try await perform(request: request)
    }
    
    func markAllAsRead() async throws {
        let request = MarkAllAsRead(session: try session)
        try await perform(request: request)
    }
    
    func blockPerson(id: Int, shouldBlock: Bool) async throws -> BlockPersonResponse {
        let request = BlockPersonRequest(session: try session, personId: id, block: shouldBlock)
        return try await perform(request: request)
    }
}

// MARK: - Object Resolving methods

enum ResolvedObject {
    case post(APIPostView)
    case person(APIPersonView)
    case comment(APICommentView)
    case community(APICommunityView)
}

extension APIClient {
    func resolve(query: String) async throws -> ResolvedObject? {
        let request = ResolveObjectRequest(session: try session, query: query)
        let response = try await perform(request: request)
        if let post = response.post {
            return .post(post)
        }
        
        if let person = response.person {
            return .person(person)
        }
        
        if let comment = response.comment {
            return .comment(comment)
        }
        
        if let community = response.community {
            return .community(community)
        }
        
        return nil
    }
}

// MARK: - Miscellaneous requests (these will end up in repositories soon)

extension APIClient {
    func loadSiteInformation() async throws -> SiteResponse {
        let request = GetSiteRequest(session: try session)
        return try await perform(request: request)
    }
    
    // swiftlint:disable function_parameter_count
    func performSearch(query: String,
                       searchType: SearchType,
                       sortOption: PostSortType,
                       listingType: FeedType,
                       page: Int?,
                       limit: Int?
    ) async throws -> SearchResponse {
        let request = SearchRequest(
            session: try session,
            query: query,
            searchType: searchType,
            sortOption: sortOption,
            listingType: listingType,
            page: page,
            communityId: nil,
            communityName: nil,
            creatorId: nil,
            limit: limit
        )
        
        return try await perform(request: request)
    }
    // swiftlint:enable function_parameter_count
    
    func getCommunityDetails(id: Int) async throws -> GetCommunityResponse {
        let request = GetCommunityRequest(session: try session, communityId: id)
        return try await perform(request: request)
    }
    
    func followCommunity(id: Int, shouldSubscribe: Bool) async throws -> CommunityResponse {
        let request = FollowCommunityRequest(session: try session, communityId: id, follow: shouldSubscribe)
        return try await perform(request: request)
    }
    
    func blockCommunity(id: Int, shouldBlock: Bool) async throws -> BlockCommunityResponse {
        let request = BlockCommunityRequest(session: try session, communityId: id, block: shouldBlock)
        return try await perform(request: request)
    }
    
    func loadCommunityList(sort: PostSortType?, page: Int?, limit: Int?, type: FeedType) async throws -> ListCommunityResponse {
        let request = ListCommunitiesRequest(
            session: try session,
            sort: sort,
            page: page,
            limit: limit,
            type: type
        )
        
        return try await perform(request: request)
    }
    
    func login(
        instanceURL: URL,
        username: String,
        password: String,
        totpToken: String? = nil
    ) async throws -> LoginResponse {
        let request = LoginRequest(
            instanceURL: instanceURL,
            username: username,
            password: password,
            totpToken: totpToken
        )
        
        return try await perform(request: request)
    }
}

// swiftlint:enable file_length
