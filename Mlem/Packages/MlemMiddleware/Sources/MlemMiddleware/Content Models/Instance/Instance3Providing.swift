//
//  Instance3Providing.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

public protocol Instance3Providing: Instance2Providing {
    var instance3: Instance3 { get }
    
    var version: SiteVersion { get }
    var allLanguages: [Locale.Language] { get }
    var allowedLanguageIds: Set<Int> { get }
    var taglines: [ApiTagline] { get }
    var blockedUrls: [ApiLocalSiteUrlBlocklist]? { get }
    var administrators: [Person2] { get }
}

public extension Instance3Providing {
    var instance2: Instance2 { instance3.instance2 }
    
    var version: SiteVersion { instance3.version }
    var allLanguages: [Locale.Language] { instance3.allLanguages }
    var allowedLanguageIds: Set<Int> { instance3.allowedLanguageIds }
    var taglines: [ApiTagline] { instance3.taglines }
    var blockedUrls: [ApiLocalSiteUrlBlocklist]? { instance3.blockedUrls }
    var administrators: [Person2] { instance3.administrators }
    
    var version_: SiteVersion? { instance3.version }
    var allLanguages_: [Locale.Language]? { instance3.allLanguages }
    var allowedLanguageIds_: Set<Int>? { instance3.allowedLanguageIds }
    var taglines_: [ApiTagline]? { instance3.taglines }
    var blockedUrls_: [ApiLocalSiteUrlBlocklist]? { instance3.blockedUrls }
    var administrators_: [Person2]? { instance3.administrators }
    
    func addAdmin(personId: Int, added: Bool) async throws {
        try await api.addAdmin(personId: personId, added: added)
    }
    
    func addAdmin(_ person: any Person, added: Bool) async throws {
        try await addAdmin(personId: person.id, added: added)
    }
    
    func language(withId id: Int) -> Locale.Language? {
        allLanguages[safeIndex: id - 1]
    }
    
    func getLanguageId(for language: Locale.Language) -> Int? {
        allLanguages.firstIndex(of: language)?.advanced(by: 1)
    }
    
    func languages(withIds ids: Set<Int>) -> [Locale.Language] {
        ids.lazy.sorted(by: <).compactMap { self.language(withId: $0) }
    }
    
    var allowedLanguages: Set<Locale.Language> {
        Set(allowedLanguageIds.lazy.compactMap { self.language(withId: $0) })
    }
    
    func usernameIsValidForNewAccount(_ username: String) async throws -> UsernameValidity {
        guard username.count >= 3 else {
            return .invalid(.tooShort(minLength: 3))
        }
        guard username.count <= actorNameMaxLength else {
            return .invalid(.tooLong(maxLength: actorNameMaxLength))
        }
        
        // Relevant backend code https://github.com/LemmyNet/lemmy/blob/5095092d3a6b0c194295e2cf3034d2b9abf8db54/crates/utils/src/utils/validation.rs#L94
        
        let regex = /^(?:[a-zA-Z0-9_]+|[0-9_\p{Arabic}]+|[0-9_\p{Cyrillic}]+)$/
        
        if try regex.wholeMatch(in: username) == nil {
            // If username isn't english, give a generic error
            let englishRegex = /[^\p{Arabic}\p{Cyrillic}]+/
            if try englishRegex.wholeMatch(in: username) == nil { return .invalid(.other) }
            
            // If the username *is* in english, we can be more descriptive
            let invalidCharacters = username.filter { char in
                if char == "_" { return false }
                guard let scalar = char.unicodeScalars.first, char.unicodeScalars.count == 1 else { return true }
                if scalar.value >= 65, scalar.value <= 90 { return false } // Uppercase
                if scalar.value >= 97, scalar.value <= 122 { return false } // Lowercase
                if scalar.value >= 48, scalar.value <= 57 { return false } // Numbers
                return true
            }
            
            if !invalidCharacters.isEmpty {
                return .invalid(.containsInvalidCharacters(Set(invalidCharacters)))
            }
            
            assertionFailure()
            return .invalid(.other)
        }
        
        do {
            _ = try await api.getPerson(username: username)
            return .taken
        } catch ApiClientError.noEntityFound {
            return .available
        }
    }
}
