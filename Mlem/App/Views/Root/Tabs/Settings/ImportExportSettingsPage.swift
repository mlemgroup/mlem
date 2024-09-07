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
                v1SettingsExist = persistenceRepository.systemSettingsExists(.v_1)
                v2SettingsExist = persistenceRepository.systemSettingsExists(.v_2)
            }
            .fileImporter(
                isPresented: $importingSettingsFile,
                allowedContentTypes: [.json]
            ) { result in
                do {
                    let fileData = try Data(contentsOf: result.get(), options: .mappedIfSafe)
                    let importedSettings = try JSONDecoder().decode(Settings.self, from: fileData)
                    Settings.main.reinit(from: importedSettings)
                    ToastModel.main.add(.success("Imported Settings"))
                } catch {
                    handleError(error)
                }
            }
    }
    
    var content: some View {
        Form {
            if v1SettingsExist {
                Section("Settings Migration") {
                    Button("Migrate V1 Settings") {
                        Task { @MainActor in
                            Settings.main.restore(from: .v_1)
                            v1SettingsExist = false
                        }
                    }
                }
            }
            
            Section {
                Button("Save Settings") {
                    Task {
                        await Settings.main.save(to: .v_2)
                        v2SettingsExist = persistenceRepository.systemSettingsExists(.v_2)
                    }
                }
                
                // dev use only: saves the current settings under v1 to easily test migration behavior
                #if DEBUG
                    Button("Save V1 Settings") {
                        Task {
                            await Settings.main.save(to: .v_1)
                        }
                    }
                #endif
                
                Button("Restore Settings") {
                    Task { @MainActor in
                        Settings.main.restore(from: .v_2)
                    }
                }
                .disabled(!v2SettingsExist)
            }
            
            Section {
                Button("Export Settings") {
                    Task {
                        let data = try JSONEncoder().encode(Settings.main)
                        let fileUrl = FileManager.default.temporaryDirectory.appending(path: "settings.json")
                        try data.write(to: fileUrl, options: .atomic)
                        navigation.shareUrl = fileUrl
                    }
                }
                
                Button("Import Settings") {
                    importingSettingsFile = true
                }
            }
            
            #if DEBUG
                // clears system settings and
                Button("Reset Settings State") {
                    do {
                        try persistenceRepository.deleteAllSystemSettings()
                        firstAppearance = true
                        v1SettingsExist = persistenceRepository.systemSettingsExists(.v_1)
                        v2SettingsExist = persistenceRepository.systemSettingsExists(.v_2)
                    } catch {
                        handleError(error)
                    }
                }
            #endif
        }
    }
}
