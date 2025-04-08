//
//  CodableSettings.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-05.
//

import Foundation
import MlemMiddleware
import UIKit
import Dependencies
import SwiftUI

/// Responsible for managing settings logic.
///
/// There should only ever be one instance of this class, the private `main`. To enforce this, interaction with the class
/// is entirely abstracted to behind a static API.
///
/// To access a settings value, it is recommended to use the `@Setting` property wrapper. In contexts where this is not available,
/// use `Settings.get(\.keypath)`.
class Settings {
    @Dependency(\.persistenceRepository) var persistenceRepository
    
    fileprivate let values: SettingsValues
    fileprivate static let main: Settings = .init()
    
    // MARK: - API
    
    static func get<T>(_ keyPath: ReferenceWritableKeyPath<SettingsValues, T>) -> T {
        main.values[keyPath: keyPath]
    }
    
    static func set<T>(_ keyPath: ReferenceWritableKeyPath<SettingsValues, T>, to newValue: T) {
        main.values[keyPath: keyPath] = newValue
        main._save()
    }
    
    static func save(to systemSetting: SystemSetting) async {
        await main._save(to: systemSetting)
    }
    
    @MainActor
    static func restore(from systemSetting: SystemSetting) {
        main._restore(from: systemSetting)
    }
    
    @MainActor
    static func reinit(with values: SettingsValues) {
        main._reinit(with: values)
    }
    
    static func encoded() throws -> Data {
        try JSONEncoder().encode(main.values)
    }
    
    // MARK: - Logic
    
    fileprivate func _save() {
        Task {
            try await persistenceRepository.saveSystemSettings(values, setting: .v2_system)
        }
    }
    
    private func _save(to systemSetting: SystemSetting) async {
        do {
            try await persistenceRepository.saveSystemSettings(values, setting: systemSetting)
            ToastModel.main.add(.success("Saved Settings"))
        } catch {
            handleError(error)
        }
    }
    
    @MainActor
    private func _restore(from systemSetting: SystemSetting) {
        if let savedSettings = persistenceRepository.loadSystemSettings(systemSetting) {
            _reinit(with: savedSettings)
            ToastModel.main.add(.success("Restored Settings"))
        } else {
            ToastModel.main.add(.failure("Could not find settings"))
        }
    }
    
    @MainActor
    private func _reinit(with newValues: SettingsValues) {
        values.reinit(from: newValues)
        _save()
    }
    
    private init() {
        @Dependency(\.persistenceRepository) var persistenceRepository
        if let savedSettings = persistenceRepository.loadSystemSettings(.v2_system) {
            values = savedSettings
        } else {
            values = .init(from: .main, filteredKeywords: persistenceRepository.loadFilteredKeywords())
            Task {
                do {
                    try await persistenceRepository.saveSystemSettings(values, setting: .v2_system)
                } catch {
                    handleError(error)
                }
            }
        }
    }
}

// MARK: Legacy Keyword Loading

private extension PersistencePath {
    static var filteredKeywords = root.appendingPathComponent("Blocked Keywords", conformingTo: .json)
}

private extension PersistenceRepository {
    func loadFilteredKeywords() -> Set<String> {
        load(Set<String>.self, from: PersistencePath.filteredKeywords) ?? .init()
    }
}
