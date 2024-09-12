//
//  APIClient.swift
//  Mlem
//
//  Created by Nicholas Lawson on 04/06/2023.
//

import Dependencies
import Foundation

// swiftlint:disable file_length

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
    case decoding(Data, Error?)
    case unexpectedResponse
}

extension APIClientError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .encoding(error):
            return "Unable to encode: \(error)"
        case let .networking(error):
            return "Networking error: \(error)"
        case let .response(errorResponse, status):
            if let status {
                return "Response error: \(errorResponse) with status \(status)"
            }
            return "Response error: \(errorResponse)"
        case .cancelled:
            return "Cancelled"
        case .invalidSession:
            return "Invalid session"
        case let .decoding(data, error):
            guard let string = String(data: data, encoding: .utf8), !string.isEmpty else {
                return localizedDescription
            }
            
            if let error {
                return "Unable to decode: \(string)\nError: \(error)"
            }
            
            return "Unable to decode: \(string)"
        case .unexpectedResponse:
            return "Unexpected response"
        }
    }
}

class APIClient {
    @Dependency(\.siteInformation) var siteInformation
    
    let urlSession: URLSession
    let decoder: JSONDecoder
    let transport: (URLSession, URLRequest) async throws -> (Data, URLResponse)
    
    var session: APISession = .undefined
    
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
    func perform<Request: APIRequest>(request: Request, overrideToken: String? = nil) async throws -> Request.Response {
        let urlRequest = try urlRequest(from: request, overrideToken: overrideToken)
        
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

    private func urlRequest(from definition: any APIRequest, overrideToken: String?) throws -> URLRequest {
        var urlRequest = URLRequest(url: definition.endpoint)
        definition.headers.forEach { header in
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }
    
        if let overrideToken {
            urlRequest.setValue("Bearer \(overrideToken)", forHTTPHeaderField: "Authorization")
        } else if case let .authenticated(_, token) = session, try session.instanceUrl == definition.instanceURL {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if definition is any APIGetRequest {
            urlRequest.httpMethod = "GET"
        } else if let postDefinition = definition as? any APIPostRequest {
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = try createBodyData(for: postDefinition)
        } else if let putDefinition = definition as? any APIPutRequest {
            urlRequest.httpMethod = "PUT"
            urlRequest.httpBody = try createBodyData(for: putDefinition)
        } else if definition is any APIDeleteRequest {
            urlRequest.httpMethod = "DELETE"
        }

        return urlRequest
    }

    private func createBodyData(for defintion: any APIRequestBodyProviding) throws -> Data {
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try encoder.encode(defintion.body)
        } catch {
            throw APIClientError.encoding(error)
        }
    }
    
    private func decode<T: Decodable>(_ model: T.Type, from data: Data) throws -> T {
        do {
            return try decoder.decode(model, from: data)
        } catch {
            throw APIClientError.decoding(data, error)
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
        return try await perform(request: request, overrideToken: session.token)
    }
    
    @available(*, deprecated, message: "This method is deprecated, use getPersonDetails with pagination parameter instead")
    func getPersonDetails(for personId: Int, limit: Int?, savedOnly: Bool) async throws -> GetPersonDetailsResponse {
        let request = try GetPersonDetailsRequest(
            session: session,
            limit: limit,
            savedOnly: savedOnly,
            personId: personId
        )
        
        return try await perform(request: request)
    }
    
    func getPersonDetails(
        for personId: Int,
        sort: PostSortType?,
        page: Int,
        limit: Int,
        savedOnly: Bool
    ) async throws -> GetPersonDetailsResponse {
        let request = try GetPersonDetailsRequest(
            session: session,
            sort: sort,
            page: page,
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
    
    func banPerson(id: Int, shouldBan: Bool, expires: Int?, reason: String?, removeData: Bool) async throws -> BanPersonResponse {
        let request = try BanPersonRequest(
            session: session,
            personId: id,
            ban: shouldBan,
            expires: expires,
            reason: reason,
            removeData: removeData
        )
        return try await perform(request: request)
    }
    
    func purgePerson(id: Int, reason: String?) async throws -> SuccessResponse {
        let request = try PurgePersonRequest(session: session, personId: id, reason: reason)
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

    func legacyDeleteUser(user: SavedAccount, password: String) async throws {
        let request = LegacyDeleteAccountRequest(account: user, password: password)
        try await perform(request: request)
    }
    
    func deleteUser(user: SavedAccount, password: String, deleteContent: Bool) async throws {
        let request = DeleteAccountRequest(account: user, password: password, deleteContent: deleteContent)
        try await perform(request: request)
    }
    
    @discardableResult
    func saveUserSettings(
        myUserInfo info: APIMyUserInfo
    ) async throws -> SuccessResponse {
        // Despite all values being optional, we actually have to provide all values
        // here otherwise Lemmy returns 'user_already_exists'. Possibly fixed >0.19.0
        // https://github.com/LemmyNet/lemmy/issues/4076
        
        let person = info.localUserView.person
        let localUser = info.localUserView.localUser
        
        let request = try SaveUserSettingsRequest(
            session: session,
            body: .init(
                avatar: person.avatar,
                banner: person.banner,
                bio: person.bio,
                botAccount: person.botAccount,
                defaultListingType: localUser.defaultListingType,
                defaultSortType: localUser.defaultSortType,
                discussionLanguages: info.discussionLanguages,
                displayName: person.displayName,
                email: localUser.email,
                generateTotp2fa: nil,
                interfaceLanguage: localUser.interfaceLanguage,
                matrixUserId: person.matrixUserId,
                openLinksInNewTab: localUser.openLinksInNewTab,
                sendNotificationsToEmail: localUser.sendNotificationsToEmail,
                showAvatars: localUser.showAvatars,
                showBotAccounts: localUser.showBotAccounts,
                showNewPostNotifs: localUser.showNewPostNotifs,
                showNsfw: localUser.showNsfw,
                showReadPosts: localUser.showReadPosts,
                showScores: localUser.showScores,
                theme: localUser.theme,
                auth: session.token
            )
        )
        return try await SuccessResponse(from: perform(request: request))
    }
    
    @discardableResult
    func changePassword(newPassword: String, confirmNewPassword: String, currentPassword: String) async throws -> LoginResponse {
        let request = try ChangePasswordRequest(
            session: session,
            newPassword: newPassword,
            newPasswordVerify: confirmNewPassword,
            oldPassword: currentPassword
        )
        return try await perform(request: request)
    }
    
    @discardableResult
    func fetchInstanceList() async throws -> [InstanceStub] {
        if let url = URL(string: "https://raw.githubusercontent.com/mlemgroup/mlem-stats/master/output/instances_by_score.json") {
            if let data = try? await urlSession.data(from: url).0 {
                return try decode([InstanceStub].self, from: data)
            }
        }
        return []
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
    
    func loadSiteInformation(instanceURL: URL) async throws -> SiteResponse {
        let request = GetSiteRequest(instanceURL: instanceURL.appendingPathComponent("api/v3/"))
        return try await perform(request: request)
    }
    
    // swiftlint:disable function_parameter_count
    func performSearch(
        query: String,
        searchType: SearchType,
        sortOption: PostSortType,
        listingType: APIListingType,
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
        
        return try await perform(request: request, overrideToken: "")
    }
    
    @discardableResult
    func reportPrivateMessage(id: Int, reason: String) async throws -> APIPrivateMessageReportView {
        let request = try CreatePrivateMessageReportRequest(session: session, privateMessageId: id, reason: reason)
        return try await perform(request: request).privateMessageReportView
    }
    
    @discardableResult
    func sendPrivateMessage(content: String, recipientId: Int) async throws -> PrivateMessageResponse {
        let request = try CreatePrivateMessageRequest(session: session, content: content, recipientId: recipientId)
        return try await perform(request: request)
    }
    
    func markPrivateMessageRead(id: Int, isRead: Bool) async throws -> APIPrivateMessageView {
        let request = try MarkPrivateMessageAsRead(session: session, privateMessageId: id, read: isRead)
        return try await perform(request: request).privateMessageView
    }
}

// swiftlint:enable file_length
