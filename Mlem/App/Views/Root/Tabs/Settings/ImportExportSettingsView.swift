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
struct ImportExportSettingsView: View {
    @Dependency(\.persistenceRepository) var persistenceRepository
    
    @Environment(NavigationLayer.self) var navigation
    
    @State var importingSettingsFile: Bool = false
    
    // these are tracked as state vars so they can be updated as appropriate
    @State var v1SettingsExist: Bool = false
    @State var v2SettingsExist: Bool = false
    
    var body: some View {
        content
            .withConditionalLabelStyle()
            .onAppear {
                v1SettingsExist = persistenceRepository.systemSettingsExists(.v1_user)
                v2SettingsExist = persistenceRepository.systemSettingsExists(.v2_user)
            }
            .fileImporter(
                isPresented: $importingSettingsFile,
                allowedContentTypes: [.json]
            ) { result in
                do {
                    let fileUrl = try result.get()
                    if let fileData = readSettings(from: fileUrl) {
                        let importedSettings = try JSONDecoder().decode(SettingsValues.self, from: fileData)
                        Settings.reinit(with: importedSettings)
                        ToastModel.main.add(.success("Imported Settings"))
                    } else {
                        assertionFailure("Failed to import settings")
                        ToastModel.main.add(.failure("Failed to import settings"))
                    }
                } catch {
                    handleError(error)
                }
            }
    }
    
    var content: some View {
        Form {
            Section("Save and Restore") {
                Button("Save Settings", icon: .settings.saveSettings) {
                    Task {
                        await Settings.save(to: .v2_user)
                        v2SettingsExist = persistenceRepository.systemSettingsExists(.v2_user)
                    }
                }
                
                Button("Restore Settings", icon: .settings.restoreSettings) {
                    Task { @MainActor in
                        Settings.restore(from: .v2_user)
                    }
                }
                .disabled(!v2SettingsExist)
            } footer: {
                Text("Save the current settings and restore them later.")
            }
            
            Section {
                Button("Export Settings", icon: .general.export) {
                    Task {
                        let data = try Settings.encoded()
                        let fileUrl = FileManager.default.temporaryDirectory.appending(path: "settings.json")
                        try data.write(to: fileUrl, options: .atomic)
                        navigation.model?.shareInfo = .init(url: fileUrl)
                    }
                }
                
                Button("Import Settings", icon: .general.import) {
                    importingSettingsFile = true
                }
            }
        }
    }
    
    func readSettings(from fileUrl: URL) -> Data? {
        let accessing = fileUrl.startAccessingSecurityScopedResource()
        
        // ensure we relinquish access
        defer {
            if accessing {
                fileUrl.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            return try Data(contentsOf: fileUrl, options: .mappedIfSafe)
        } catch {
            handleError(error)
            return nil
        }
    }
}
