//
//  PersistenceRepository.swift
//  Mlem
//
//  Created by mormaer on 26/07/2023.
//
//

import Dependencies
import Foundation
import MlemMiddleware

private enum Path {
    private static var root = {
        guard let path = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else {
            fatalError("unable to access application support path")
        }

        return path
    }()

    static var userAccounts = root.appendingPathComponent("Saved Accounts", conformingTo: .json)
    static var guestAccounts = root.appendingPathComponent("Guest Accounts", conformingTo: .json)
    static var filteredKeywords = root.appendingPathComponent("Blocked Keywords", conformingTo: .json)
    static var favoriteCommunities = root.appendingPathComponent("Favorite Communities", conformingTo: .json)
    static var recentSearches = root.appendingPathComponent("Recent Searches", conformingTo: .json)
    static var easterFlags = root.appendingPathComponent("Easter eggs flags", conformingTo: .json)
    static var instanceMetadata = root.appendingPathComponent("Instance Metadata", conformingTo: .json)
    static var layoutWidgets = root.appendingPathComponent("Layout Widgets", conformingTo: .json)
    static var systemSettings = root.appendingPathComponent("System Settings", conformingTo: .directory)
    static var userSettings = root.appendingPathComponent("User Settings", conformingTo: .directory)
}

private enum DiskAccess {
    static func load(from path: URL) throws -> Data {
        try Data(contentsOf: path, options: .mappedIfSafe)
    }
    
    static func save(_ data: Data, to path: URL) async throws {
        try await Task(priority: .background) {
            try data.write(to: path, options: .atomic)
        }
        .value
    }
}

// Enumeration of system-managed settings
enum SystemSetting {
    case v_1, v_2
    
    var path: String {
        switch self {
        case .v_1: "v1"
        case .v_2: "v2"
        }
    }
}

class PersistenceRepository {
    @Dependency(\.date) private var date
    
    private var keychainAccess: (String) -> String?
    private var read: (URL) throws -> Data
    private var write: (Data, URL) async throws -> Void
    private let bundle: Bundle
    
    init(
        keychainAccess: @escaping (String) -> String?,
        read: @escaping (URL) throws -> Data = { try DiskAccess.load(from: $0) },
        write: @escaping (Data, URL) async throws -> Void = { try await DiskAccess.save($0, to: $1) },
        bundle: Bundle = Bundle.main
    ) {
        self.keychainAccess = keychainAccess
        self.read = read
        self.write = write
        self.bundle = bundle
        
        // set up settings directories--if this fails, something has gone _terribly_ wrong
        do {
            try FileManager.default.createDirectory(at: Path.systemSettings, withIntermediateDirectories: true)
            try FileManager.default.createDirectory(at: Path.userSettings, withIntermediateDirectories: true)
        } catch {
            fatalError("Could not create settings directories")
        }
    }
    
    // MARK: - Public methods
    
    func loadUserAccounts() -> [UserAccount] {
        load([UserAccount].self, from: Path.userAccounts) ?? []
    }
    
    func saveUserAccounts(_ value: [UserAccount]) async throws {
        try await save(value, to: Path.userAccounts)
    }
    
    func loadGuestAccounts() -> [GuestAccount] {
        load([GuestAccount].self, from: Path.guestAccounts) ?? []
    }
    
    func saveGuestAccounts(_ value: [GuestAccount]) async throws {
        try await save(value, to: Path.guestAccounts)
    }

//
//    func loadRecentSearches(for accountId: String) -> [ContentModelIdentifier] {
//        let searches = load([String: [ContentModelIdentifier]].self, from: Path.recentSearches) ?? [:]
//        return searches[accountId] ?? []
//    }
//
//    func saveRecentSearches(for accountId: String, with searches: [ContentModelIdentifier]) async throws {
//        var extant = load([String: [ContentModelIdentifier]].self, from: Path.recentSearches) ?? [:]
//        extant[accountId] = searches
//        try await save(extant, to: Path.recentSearches)
//    }
//
//    func loadFavoriteCommunities() -> [FavoriteCommunity] {
//        load([FavoriteCommunity].self, from: Path.favoriteCommunities) ?? []
//    }
//
//    func saveFavoriteCommunities(_ value: [FavoriteCommunity]) async throws {
//        try await save(value, to: Path.favoriteCommunities)
//    }
//
//    func loadEasterFlags() -> Set<EasterFlag> {
//        load(Set<EasterFlag>.self, from: Path.easterFlags) ?? .init()
//    }
//
//    func saveEasterFlags(_ value: Set<EasterFlag>) async throws {
//        try await save(value, to: Path.easterFlags)
//    }
    
    func loadFilteredKeywords() -> [String] {
        load([String].self, from: Path.filteredKeywords) ?? []
    }
    
    func saveFilteredKeywords(_ value: [String]) async throws {
        try await save(value, to: Path.filteredKeywords)
    }
    
    func getFilteredKeywordsPath() -> URL {
        Path.filteredKeywords
    }
    
    func loadInteractionBarConfigurations() -> InteractionBarConfigurations {
        load(InteractionBarConfigurations.self, from: Path.layoutWidgets) ?? .default
    }
    
    func saveInteractionBarConfigurations(_ value: InteractionBarConfigurations) async throws {
        try await save(value, to: Path.layoutWidgets)
    }
    
    /// Saves the given user settings
    func saveUserSettings(_ settings: Settings, name: String) async throws {
        try await save(settings, to: Path.userSettings.appendingPathComponent(name, conformingTo: .json))
    }
    
    /// Loads given user settings, if present
    func loadUserSettings(name: String) -> Settings? {
        load(Settings.self, from: Path.userSettings.appendingPathComponent(name, conformingTo: .json))
    }
    
    /// Returns true if the given system settings exist, false otherwise
    func systemSettingsExists(_ setting: SystemSetting) -> Bool {
        // FileManager does offer fileExists but it always returns false, this way is reliable
        if loadSystemSettings(setting) != nil { return true }
        return false
    }
    
    /// Saves the given system settings
    func saveSystemSettings(_ settings: Settings, setting: SystemSetting) async throws {
        try await save(settings, to: Path.systemSettings.appendingPathComponent(setting.path, conformingTo: .json))
    }
    
    /// Loads given system settings, if present
    func loadSystemSettings(_ setting: SystemSetting) -> Settings? {
        load(Settings.self, from: Path.systemSettings.appendingPathComponent(setting.path, conformingTo: .json))
    }
    
    // DEV ONLY
    func deleteAllSystemSettings() throws {
        try FileManager.default.removeItem(at: Path.systemSettings)
        try FileManager.default.createDirectory(at: Path.systemSettings, withIntermediateDirectories: true)
    }

//
//    func loadInstanceMetadata() -> TimestampedValue<[InstanceMetadata]> {
//        let localFile = load(TimestampedValue<[InstanceMetadata]>.self, from: Path.instanceMetadata)
//        let bundledFile = loadFromBundle(TimestampedValue<[InstanceMetadata]>.self, filename: "instance_metadata")
//
//        if let localFile, localFile.timestamp > bundledFile.timestamp {
//            return localFile
//        }
//
//        return bundledFile
//    }
//
//    func saveInstanceMetadata(_ value: [InstanceMetadata]) async throws {
//        let timestamped = TimestampedValue(value: value, timestamp: date.now, lifespan: .days(1))
//        try await save(timestamped, to: Path.instanceMetadata)
//    }
    
    // MARK: Private methods
    
    private func load<T: Decodable>(_ model: T.Type, from path: URL) -> T? {
        do {
            let data = try read(path)
            
            guard !data.isEmpty else {
                return nil
            }
            
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == 260 {
            // Don't show error toast if file not found
            return nil
        } catch {
            handleError(error)
            return nil
        }
    }
    
    private func loadFromBundle<T: Decodable>(_ model: T.Type, filename: String, type: String = "json") -> T {
        do {
            let path = bundle.path(forResource: filename, ofType: type)!
            let stringValue = try String(contentsOfFile: path)
            let data = stringValue.data(using: .utf8)!
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            fatalError("☠️ failed to load \(filename).\(type) from the application bundle.")
        }
    }
    
    private func save(_ value: some Encodable, to path: URL) async throws {
        do {
            let data = try JSONEncoder().encode(value)
            try await write(data, path)
        } catch {
            handleError(error)
        }
    }
}
