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

enum PersistencePath {
    static var root = {
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
    static var favoriteCommunities = root.appendingPathComponent("Favorite Communities", conformingTo: .json)
    static var instanceMetadata = root.appendingPathComponent("Instance Metadata", conformingTo: .json)
    static var layoutWidgets = root.appendingPathComponent("Layout Widgets", conformingTo: .json)
    static var pinnedSortTypes = root.appendingPathComponent("Sort Settings", conformingTo: .json)
    static var systemSettings = root.appendingPathComponent("System Settings", conformingTo: .directory)
    
    static func accountSettingsDirectory(for account: any Account) -> URL {
        root
            .appendingPathComponent("Account Settings", conformingTo: .directory)
            .appendingPathComponent(account.uniqueStringId, conformingTo: .directory)
    }
    
    static func accountSettings(for account: any Account) -> URL {
        accountSettingsDirectory(for: account)
            .appendingPathComponent("Settings", conformingTo: .json)
    }
    
    static func visitHistory(for account: any Account) -> URL {
        accountSettingsDirectory(for: account)
            .appendingPathComponent("Visit History", conformingTo: .json)
    }
}

private enum DiskAccess {
    static func load(from path: URL) throws -> Data {
        try Data(contentsOf: path, options: .mappedIfSafe)
    }
    
    static func save(_ data: Data, to path: URL) async throws {
        try await Task(priority: .background) {
            try FileManager.default.createDirectory(
                at: path.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try data.write(to: path, options: .atomic)
        }
        .value
    }
}

// Enumeration of system-managed settings
enum SystemSetting {
    // swiftlint:disable:next identifier_name
    case v1, v2
    
    var path: String {
        switch self {
        case .v1: "v1"
        case .v2: "v2"
        }
    }
}

class PersistenceRepository {
    enum PersistenceRepositoryError: Error {
        case noFullName
    }
    
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
            try FileManager.default.createDirectory(at: PersistencePath.systemSettings, withIntermediateDirectories: true)
        } catch {
            fatalError("Could not create settings directories")
        }
    }
    
    // MARK: - Public methods
    
    func deleteAccountSettings(for account: any Account) throws {
        try FileManager.default.removeItem(at: PersistencePath.accountSettingsDirectory(for: account))
    }
    
    func loadUserAccounts() -> [UserAccount] {
        load([UserAccount].self, from: PersistencePath.userAccounts) ?? []
    }
    
    func saveUserAccounts(_ value: [UserAccount]) async throws {
        try await save(value, to: PersistencePath.userAccounts)
    }
    
    func loadGuestAccounts() -> [GuestAccount] {
        load([GuestAccount].self, from: PersistencePath.guestAccounts) ?? []
    }
    
    func saveGuestAccounts(_ value: [GuestAccount]) async throws {
        try await save(value, to: PersistencePath.guestAccounts)
    }

    func loadInteractionBarConfigurations() -> InteractionBarConfigurations {
        if let standard = load(InteractionBarConfigurations.self, from: PersistencePath.layoutWidgets, silentError: true) {
            return standard
        }
        // if v2 format decoding fails, try legacy format
        if let legacy = load(LegacyInteractionBarConfigurations.self, from: PersistencePath.layoutWidgets) {
            let ret: InteractionBarConfigurations = .init(legacyConfiguration: legacy)
            Task {
                // save in v2 format
                do {
                    try await saveInteractionBarConfigurations(ret)
                } catch {
                    handleError(error)
                }
            }
            return ret
        }
        return .default
    }
    
    func saveInteractionBarConfigurations(_ value: InteractionBarConfigurations) async throws {
        print("SAVE", value.post.leadingSwipes)
        try await save(value, to: PersistencePath.layoutWidgets)
    }
    
    func loadVisitHistory(for account: UserAccount) async throws -> VisitHistory {
        let path = PersistencePath.visitHistory(for: account)
        let data = load(VisitHistory.CodedData.self, from: path, silentError: true) ?? .init()
        return try await .init(data: data, api: account.api)
    }
    
    func saveVisitHistory(_ visitHistory: VisitHistory, for account: UserAccount) async throws {
        let path = PersistencePath.visitHistory(for: account)
        try await save(visitHistory.codedData(), to: path)
    }
    
    func loadPinnedSortTypes() -> Set<PostSortType> {
        let apiSortTypes = load(Set<ApiSortType>.self, from: PersistencePath.pinnedSortTypes) ?? [
            .hot, .new, .topSixHour, .topDay, .topWeek, .topMonth, .topYear, .topAll
        ]
        return Set(apiSortTypes.map(PostSortType.init))
    }
    
    func savePinnedSortTypes(_ value: Set<PostSortType>) async throws {
        try await save(value.compactMap(\.legacyApiSortType), to: PersistencePath.pinnedSortTypes)
    }
    
    /// Saves the given user settings
    func saveAccountSettings(_ settings: CodableSettings, for account: any Account) async throws {
        try await save(settings, to: PersistencePath.accountSettings(for: account))
    }
    
    /// Loads given user settings, if present
    func loadAccountSttings(for account: any Account) -> CodableSettings? {
        load(CodableSettings.self, from: PersistencePath.accountSettings(for: account))
    }
    
    /// Returns true if the given system settings exist, false otherwise
    func systemSettingsExists(_ setting: SystemSetting) -> Bool {
        // FileManager does offer fileExists but it always returns false, this way is reliable
        if loadSystemSettings(setting) != nil { return true }
        return false
    }
    
    /// Saves the given system settings
    func saveSystemSettings(_ settings: CodableSettings, setting: SystemSetting) async throws {
        try await save(settings, to: PersistencePath.systemSettings.appendingPathComponent(setting.path, conformingTo: .json))
    }
    
    /// Loads given system settings, if present
    func loadSystemSettings(_ setting: SystemSetting) -> CodableSettings? {
        load(CodableSettings.self, from: PersistencePath.systemSettings.appendingPathComponent(setting.path, conformingTo: .json))
    }
    
    // DEV ONLY
    func deleteAllSystemSettings() throws {
        try FileManager.default.removeItem(at: PersistencePath.systemSettings)
        try FileManager.default.createDirectory(at: PersistencePath.systemSettings, withIntermediateDirectories: true)
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
    
    // MARK: Loading methods
    
    func load<T: Decodable>(_ model: T.Type, from path: URL, silentError: Bool = false) -> T? {
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
            handleError(error, silent: silentError)
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
    
    func save(_ value: some Encodable, to path: URL) async throws {
        do {
            let data = try JSONEncoder().encode(value)
            try await write(data, path)
        } catch {
            handleError(error)
        }
    }
}
