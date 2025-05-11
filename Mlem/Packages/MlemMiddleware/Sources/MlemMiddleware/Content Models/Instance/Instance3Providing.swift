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
}
