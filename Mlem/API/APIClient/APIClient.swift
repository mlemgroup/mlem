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
    case decoding(Data)
}

extension APIClientError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .decoding(data):
            guard let string = String(data: data, encoding: .utf8) else {
                return localizedDescription
            }
            
            return "Unable to decode: \(string)"
        default:
            return localizedDescription
        }
    }
}

class APIClient {
    let urlSession: URLSession
    let decoder: JSONDecoder
    let transport: (URLSession, URLRequest) async throws -> (Data, URLResponse)
    
    private(set) var session: APISession = .undefined
    
    // MARK: - Initialisation
    
    init(
        urlSession: URLSession = .init(configuration: .default),
        decoder: JSONDecoder = .defaultDecoder,
        transport: @escaping (URLSession, URLRequest) async throws -> (Data, URLResponse)
    ) {
        self.urlSession = urlSession
        self.decoder = decoder
        self.transport = transport
    }
    
    // MARK: - Public methods
    
    /// Configures the clients session based on the passed in flow
    /// - Parameter flow: The application flow which the client should be configured for
    func configure(for flow: AppFlow) {
        switch flow {
        case let .account(account):
            session = .authenticated(account.instanceLink, account.accessToken)
        case .onboarding:
            // no calls to our `APIClient` should be made during onboarding
            // excluding a _login_ call which requires an explicit session to be provided
            // setting to `.undefined` here ensures that errors will be throw should a call
            // be attempted
            session = .undefined
        }
    }
    
    @discardableResult
    func perform<Request: APIRequest>(request: Request) async throws -> Request.Response {
        let urlRequest = try urlRequest(from: request)

        let (data, response) = try await execute(urlRequest)
        
        if let response = response as? HTTPURLResponse {
            if response.statusCode >= 500 { // Error code for server being offline.
                throw APIClientError.response(
                    APIErrorResponse(error: "Instance appears to be offline.\nTry again later."),
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
        
        return try decode(Request.Response.self, from: data)
    }
    
    public func attemptAuthenticatedCall() async throws {
        let request = try GetPrivateMessagesRequest(
            session: session,
            page: 1,
            limit: 1,
            unreadOnly: false
        )
        
        do {
            try await perform(request: request)
        } catch {
            // we're only interested in throwing for invalid sessions here...
            if case APIClientError.invalidSession = error {
                throw error
            }
        }
    }
    
    // MARK: - Private methods
    
    private func execute(_ urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await transport(urlSession, urlRequest)
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
        
        if case let .authenticated(_, token) = session {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
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
    
    private func decode<T: Decodable>(_ model: T.Type, from data: Data) throws -> T {
        do {
            return try decoder.decode(model, from: data)
        } catch {
            throw APIClientError.decoding(data)
        }
    }
}

// MARK: Post Requests

// MARK: Person Requests

extension APIClient {
    func getUnreadCount() async throws -> APIPersonUnreadCounts {
        let request = try GetPersonUnreadCount(session: session)
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
            session: session,
            limit: limit,
            savedOnly: savedOnly,
            personId: personId
        )
        
        return try await perform(request: request)
    }
    
    func markAllAsRead() async throws {
        let request = try MarkAllAsRead(session: session)
        try await perform(request: request)
    }
    
    func blockPerson(id: Int, shouldBlock: Bool) async throws -> BlockPersonResponse {
        let request = try BlockPersonRequest(session: session, personId: id, block: shouldBlock)
        return try await perform(request: request)
    }
    
    func markPersonMentionAsRead(mentionId: Int, isRead: Bool) async throws -> APIPersonMentionView {
        let request = try MarkPersonMentionAsRead(session: session, personMentionId: mentionId, read: isRead)
        return try await perform(request: request).personMentionView
    }
    
    func markCommentReplyRead(id: Int, isRead: Bool) async throws -> CommentReplyResponse {
        let request = try MarkCommentReplyAsRead(session: session, commentId: id, read: isRead)
        return try await perform(request: request)
    }
    
    func getPersonMentions(
        sort: PostSortType?,
        page: Int?,
        limit: Int?,
        unreadOnly: Bool
    ) async throws -> [APIPersonMentionView] {
        let request = try GetPersonMentionsRequest(session: session, sort: sort, page: page, limit: limit, unreadOnly: unreadOnly)
        return try await perform(request: request).mentions
    }
    
    func getPrivateMessages(
        page: Int?,
        limit: Int?,
        unreadOnly: Bool
    ) async throws -> [APIPrivateMessageView] {
        let request = try GetPrivateMessagesRequest(session: session, page: page, limit: limit, unreadOnly: unreadOnly)
        return try await perform(request: request).privateMessages
    }
    
    func getReplies(
        sort: PostSortType?,
        page: Int?,
        limit: Int?,
        unreadOnly: Bool
    ) async throws -> [APICommentReplyView] {
        let request = try GetRepliesRequest(session: session, sort: sort, page: page, limit: limit, unreadOnly: unreadOnly)
        return try await perform(request: request).replies
    }
    
    // MARK: - User requests

    func deleteUser(user: SavedAccount, password: String) async throws {
        let request = DeleteAccountRequest(account: user, password: password)
        try await perform(request: request)
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
        let request = try ResolveObjectRequest(session: session, query: query)
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
        let request = try GetSiteRequest(session: session)
        return try await perform(request: request)
    }
    
    // swiftlint:disable function_parameter_count
    func performSearch(
        query: String,
        searchType: SearchType,
        sortOption: PostSortType,
        listingType: FeedType,
        page: Int?,
        limit: Int?
    ) async throws -> SearchResponse {
        let request = try SearchRequest(
            session: session,
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
    
    @discardableResult
    func reportPrivateMessage(id: Int, reason: String) async throws -> APIPrivateMessageReportView {
        let request = try CreatePrivateMessageReportRequest(session: session, privateMessageId: id, reason: reason)
        return try await perform(request: request).privateMessageReportView
    }
    
    @discardableResult
    func sendPrivateMessage(content: String, recipient: APIPerson) async throws -> PrivateMessageResponse {
        let request = try CreatePrivateMessageRequest(session: session, content: content, recipient: recipient)
        return try await perform(request: request)
    }
    
    func markPrivateMessageRead(id: Int, isRead: Bool) async throws -> APIPrivateMessageView {
        let request = try MarkPrivateMessageAsRead(session: session, privateMessageId: id, read: isRead)
        return try await perform(request: request).privateMessageView
    }
}
