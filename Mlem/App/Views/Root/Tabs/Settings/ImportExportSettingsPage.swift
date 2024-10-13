//
//  ImportExportSettingsPage.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-06.
//

import Dependencies
import Foundation
import SwiftUI

// DO NOT use Picker in this page! It refuses to change the theme until it gets re-rendered. All other components pick up theme changes correctly.
struct ImportExportSettingsPage: View {
    @Dependency(\.persistenceRepository) var persistenceRepository
    
    @Environment(NavigationLayer.self) var navigation
    
    @AppStorage("status.firstAppearance") var firstAppearance: Bool = true
    
    @State var importingSettingsFile: Bool = false
    
    // these are tracked as state vars so they can be updated as appropriate
    @State var v1SettingsExist: Bool = false
    @State var v2SettingsExist: Bool = false
    
    var body: some View {
        content
            .onAppear {
                v1SettingsExist = persistenceRepository.systemSettingsExists(.v1)
                v2SettingsExist = persistenceRepository.systemSettingsExists(.v2)
            }
            .fileImporter(
                isPresented: $importingSettingsFile,
                allowedContentTypes: [.json]
            ) { result in
                do {
                    let fileUrl = try result.get()
                    if fileUrl.startAccessingSecurityScopedResource() {
                        let fileData = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
                        fileUrl.stopAccessingSecurityScopedResource()
                        
                        let importedSettings = try JSONDecoder().decode(CodableSettings.self, from: fileData)
                        Settings.main.reinit(from: importedSettings)
                        ToastModel.main.add(.success("Imported Settings"))
                    } else {
                        assertionFailure("Failed to access requested file")
                        ToastModel.main.add(.failure("Failed to Import Settings"))
                    }
                } catch {
                    handleError(error)
                }
            }
    }
    
    var content: some View {
        Form {
            Section {
                Button("Save Settings") {
                    Task {
                        await Settings.main.save(to: .v2)
                        v2SettingsExist = persistenceRepository.systemSettingsExists(.v2)
                    }
                }
                
                // dev use only: saves the current settings under v1 to easily test migration behavior
                #if DEBUG
                    Button("Save V1 Settings") {
                        Task {
                            await Settings.main.save(to: .v1)
                        }
                    }
                #endif
                
                Button("Restore Settings") {
                    Task { @MainActor in
                        Settings.main.restore(from: .v2)
                    }
                }
                .disabled(!v2SettingsExist)
            }
            
            Section {
                Button("Export Settings") {
                    Task {
                        let data = try JSONEncoder().encode(Settings.main.codable)
                        let fileUrl = FileManager.default.temporaryDirectory.appending(path: "settings.json")
                        try data.write(to: fileUrl, options: .atomic)
                        navigation.shareInfo = .init(url: fileUrl)
                    }
                }
                
                Button("Import Settings") {
                    importingSettingsFile = true
                }
            }
            
            #if DEBUG
                // clears saved system settings and resets the firstAppearance flag
                Button("Reset Settings State") {
                    do {
                        try persistenceRepository.deleteAllSystemSettings()
                        firstAppearance = true
                        v1SettingsExist = persistenceRepository.systemSettingsExists(.v1)
                        v2SettingsExist = persistenceRepository.systemSettingsExists(.v2)
                    } catch {
                        handleError(error)
                    }
                }
            #endif
        }
    }
}
