//
//  Instance3.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation
import Observation

@Observable
public final class Instance3: Instance3Providing {
    // TODO: NOW make this shitty shim code better
    public var blockedValue: Bool { instance2.blockedValue }
    
    public static let tierNumber: Int = 3
    public var api: ApiClient
    public var instance3: Instance3 { self }
    
    public let instance2: Instance2
    
    public var software: SiteSoftware
    
    public let allLanguages: [Locale.Language]
    
    // This excludes the "undetermined" language identifier (which is 0),
    // because its presence or absence doesn't actually affect whether you're
    // able to create a post with "undetermined" as the language
    public var allowedLanguageIds: Set<Int>
    
    public var blockedUrls: [InstanceUrlBlockRecord]?
    public var administrators: [Person]
  
    init(
        api: ApiClient,
        instance2: Instance2,
        software: SiteSoftware,
        allLanguages: [Locale.Language],
        allowedLanguageIds: Set<Int>,
        blockedUrls: [InstanceUrlBlockRecord]?,
        administrators: [Person]
    ) {
        self.api = api
        self.instance2 = instance2
        self.software = software
        self.allLanguages = allLanguages
        self.allowedLanguageIds = allowedLanguageIds
        self.blockedUrls = blockedUrls
        self.administrators = administrators
    }
}
