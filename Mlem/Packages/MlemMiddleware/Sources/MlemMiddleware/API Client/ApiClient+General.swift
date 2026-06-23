//
//  ApiClient+General.swift
//
//
//  Created by Sjmarf on 25/06/2024.
//

import Foundation

public extension ApiClient {
    var isAdmin: Bool {
        myInstance?.administrators.value?.contains(where: { $0.id == myPerson?.id }) ?? false
    }
    
    /// Returns true if both myPerson and the given person are admins on this instance and myPerson outranks the given person, false otherwise
    func isHigherAdmin(than person: Person) -> Bool {
        guard person.api.actorId == actorId,
              let myPerson,
              let myAdminIndex = myInstance?.administrators.value?.firstIndex(of: myPerson),
              let targetAdminIndex = myInstance?.administrators.value?.firstIndex(where: { $0.actorId == person.actorId }) else {
            return false
        }
        return myAdminIndex < targetAdminIndex
    }

    func getSoftwareFallback() async throws -> SiteSoftware {
        try await repository.getSoftwareFallback()
    }
    
    func getAccountToken(usernameOrEmail: String, password: String, totpToken: String?) async throws -> String {
        try await repository.getAccountToken(usernameOrEmail: usernameOrEmail, password: password, totpToken: totpToken)
    }
    
    func getUsernameFromToken(token: String) async throws -> String {
        try await repository.getUsernameFromToken(token: token)
    }
    
    func login(password: String, totpToken: String?) async throws {
        guard let username else { throw ApiClientError.notLoggedIn }
        let token = try await getAccountToken(usernameOrEmail: username, password: password, totpToken: totpToken)
        updateToken(token)
    }
    
    func signUp(
        username: String,
        password: String,
        confirmPassword: String,
        showNsfw: Bool,
        email: String?,
        captcha: Captcha?,
        captchaAnswer: String?,
        applicationQuestionResponse: String?
    ) async throws -> SignUpResponse {
        try await repository.signUp(username: username, password: password, confirmPassword: confirmPassword, showNsfw: showNsfw, email: email, captcha: captcha, captchaAnswer: captchaAnswer, applicationQuestionResponse: applicationQuestionResponse)
    }
    
    @discardableResult
    func changePassword(
        newPassword: String,
        confirmNewPassword: String,
        oldPassword: String
    ) async throws -> String {
        let token = try await repository.changePassword(newPassword: newPassword, confirmNewPassword: confirmNewPassword, oldPassword: oldPassword)
        updateToken(token)
        return token
    }
    
    func getCaptcha() async throws -> Captcha {
        try await repository.getCaptcha()
    }
    
    /// Returns an object associated with the given URL.
    ///
    /// ## Overview
    ///
    /// The backend performs two steps to do this:
    /// 1) Check it already has the given actorId mapped in the database, in which case it returns the entity.
    /// 2) If the entity is not present in the database, it contacts the URL host to ask for it, then returns it back to us.
    ///   When this happens, the call will take longer to resolve.
    ///
    /// **Importantly, step 2) is only performed if the `ApiClient` is authenticated.**
    ///
    func resolve(url: URL) async throws -> (any ActorIdentifiable & Sharable) {
        let response = try await repository.resolve(url: url)
        return switch response {
        case let .comment(comment):
            await caches.comment.getModel(api: self, from: .comment2(comment))
        case let .post(post):
            await caches.post.getModel(api: self, from: .post2(post))
        case let .community(community):
            await caches.community.getModel(api: self, from: .community2(community))
        case let .person(person):
            await caches.person.getModel(api: self, from: .person2(person))
        }
    }
    
    func resolve<Value: ActorIdentifiable & Sharable>(urls: [URL]) async throws -> [URL: Value] {
        try await withThrowingTaskGroup(of: (url: URL, value: Value)?.self) { group in
            for url in urls {
                group.addTask {
                    if let value = try await self.resolve(url: url) as? Value {
                        return (url, value)
                    }
                    return nil
                }
            }
            
            var collected: [URL: Value] = .init()
            
            for try await result in group {
                if let result {
                    collected[result.url] = result.value
                }
            }
            
            return collected
        }
    }
    
    func getBlocked() async throws -> (people: [Person], communities: [Community], instances: [InstanceStub]) {
        let snapshots = try await repository.getBlocked()
        return await (
            people: caches.person.getModels(api: self, from: snapshots.people.map { .person1($0) }),
            communities: caches.community.getModels(api: self, from: snapshots.communities.map { .community1($0) }),
            instances: snapshots.instances.map { .init(api: self, actorId: .instance(host: $0)) }
        )
    }
    
    func getModlog(
        pageInfo: PageInfo,
        communityId: Int? = nil,
        moderatorId: Int? = nil,
        subjectPersonId: Int? = nil,
        postId: Int? = nil,
        commentId: Int? = nil,
        type: ModlogEntryType? = nil
    ) async throws -> PagedResponse<ModlogEntry> {
        let response = try await repository.getModlog(
            pageInfo: pageInfo,
            communityId: communityId,
            moderatorId: moderatorId,
            subjectPersonId: subjectPersonId,
            postId: postId,
            commentId: commentId,
            type: type
        )
        let entries = await createModlogEntries(response.items)
        return .init(items: entries, nextLocation: response.nextLocation)
    }
    
    @MainActor
    private func createModlogEntries(_ entries: [ModlogEntrySnapshot]) -> [ModlogEntry] {
        entries.map { entry in
            return ModlogEntry(
                api: self,
                created: entry.created,
                moderator: caches.person.getOptionalModel(
                    api: self,
                    from: .person1(entry.moderator)
                ),
                type: .init(from: entry.type, api: self)
            )
        }
    }
    
    func getPostLink(url: URL) async throws -> PostLink {
        try await repository.getPostLink(url: url)
    }
}
