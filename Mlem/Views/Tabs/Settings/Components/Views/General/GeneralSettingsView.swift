//
//  GeneralSettingsView.swift
//  Mlem
//
//  Created by David Bureš on 19.05.2023.
//

import Dependencies
import SwiftUI

struct GeneralSettingsView: View {
    @Dependency(\.siteInformation) var siteInformation: SiteInformationTracker
    
    @AppStorage("confirmImageUploads") var confirmImageUploads: Bool = true
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
    @AppStorage("appLock") var appLock: AppLock = .disabled
    @AppStorage("tapCommentToCollapse") var tapCommentToCollapse: Bool = true
    @AppStorage("markReadOnScroll") var markReadOnScroll: Bool = false
    
    @AppStorage("defaultFeed") var defaultFeed: DefaultFeedType = .subscribed
    
    @AppStorage("hapticLevel") var hapticLevel: HapticPriority = .low
    @AppStorage("upvoteOnSave") var upvoteOnSave: Bool = false

    @EnvironmentObject var appState: AppState

    @State var showErrorAlert: Bool = false
    @State var alertMessage: String = ""
    var body: some View {
        List {
            Section {
                #if DEBUG
                    Button("Print Settings") {
                        do {
                            try print(String(decoding: JSONEncoder().encode(CodableSettings()), as: UTF8.self))
                        } catch {
                            print(error)
                        }
                    }
                #endif
                
                SelectableSettingsItem(
                    settingIconSystemName: Icons.haptics,
                    settingName: "Haptic Level",
                    currentValue: $hapticLevel,
                    options: HapticPriority.allCases
                )
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.collapseComments,
                    settingName: "Tap Comments to Collapse",
                    isTicked: $tapCommentToCollapse
                )
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.upvoteOnSave,
                    settingName: "Upvote on Save",
                    isTicked: $upvoteOnSave
                )
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.read,
                    settingName: "Mark Read on Scroll",
                    isTicked: $markReadOnScroll
                )
                .disabled(siteInformation.version ?? .infinity <= .init("0.19.0"))
            } footer: {
                if siteInformation.version ?? .infinity <= .init("0.19.0") {
                    Text("Mark read on scroll is only available on instances running v0.19.0 or greater.")
                }
            }
            
            Section {
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.blurNsfw,
                    settingName: "Blur NSFW Content",
                    isTicked: $shouldBlurNsfw
                )
            } footer: {
                VStack(alignment: .leading, spacing: 3) {
                    // swiftlint:disable:next line_length
                    Text("Blurs content flagged as Not Safe For Work until tapped. You can disable NSFW content completely in Account Settings.")
                    
                    // TODO: 0.17 deprecation remove this check
                    if (siteInformation.version ?? .zero) >= .init("0.18.0") {
                        FooterLinkView(title: "Account Settings", destination: .settings(.accountGeneral))
                    }
                }
            }
            
            Section {
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.attachment,
                    settingName: "Confirm Image Uploads",
                    isTicked: $confirmImageUploads
                )
            } footer: {
                Text("Ask to confirm your choice before uploading an image to your instance.")
            }
            
            Section {
                SelectableSettingsItem(
                    settingIconSystemName: defaultFeed.settingsIconName,
                    settingName: "Default Feed",
                    currentValue: $defaultFeed,
                    options: DefaultFeedType.allCases
                )
            } footer: {
                Text("The feed to show by default when you open the app.")
            }
            
            Section {
                SelectableSettingsItem(
                    settingIconSystemName: Icons.connection,
                    settingName: "Internet Speed",
                    currentValue: $internetSpeed,
                    options: InternetSpeed.allCases
                )
            } header: {
                Text("Connection Type")
            } footer: {
                Text("Optimizes performance for your internet speed. You may need to restart the app for all optimizations to take effect.")
            }
            
            Section {
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.appLockSettings,
                    settingName: "Lock with Face ID",
                    isTicked: Binding(
                        get: { appLock == .instant },
                        set: { selected in
                            appLock = selected ? .instant : .disabled
                        }
                    )
                )
            } header: {
                Text("Privacy")
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("General")
        .navigationBarColor()
        .hoistNavigation()
        .onChange(of: appLock) { _ in
            if appLock != .disabled, !BiometricUnlock().requestBiometricPermissions() {
                showErrorAlert = true
                alertMessage = "Please allow Mlem to use Face ID in Settings."
                appLock = .disabled
            }
        }
        .alert(isPresented: $showErrorAlert, content: {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        })
    }
}
