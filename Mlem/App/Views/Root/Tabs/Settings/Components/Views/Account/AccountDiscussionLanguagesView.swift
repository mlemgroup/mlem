//
//  AccountDiscussionLanguagesView.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-12-13.
//

import Dependencies
import SwiftUI

struct AccountDiscussionLanguagesView: View {
    @Dependency(\.errorHandler) var errorHandler: ErrorHandler

    @State private var discussionLanguages: Set<Int> = .init()
    
    init() {
//        if let info = siteInformation.myUserInfo {
//            _discussionLanguages = .init(wrappedValue: Set(info.discussionLanguages))
//        }
    }
    
    var body: some View {
        Form {
            Section {
                Toggle(isOn: Binding(
                    get: { discussionLanguages.contains(0) },
                    set: { selected in
                        if selected {
                            discussionLanguages.insert(0)
                        } else {
                            discussionLanguages.remove(0)
                        }
                        saveDiscussionLanguages()
                    }
                )) {
                    Text("Undetermined")
                }
            } footer: {
                Text("If you deselect Undetermined, you won't see most content.")
            }
            Section {
//                ForEach(siteInformation.allLanguages.dropFirst(), id: \.self) { language in
//                    Toggle(isOn: Binding(
//                        get: { discussionLanguages.contains(language.id) },
//                        set: { selected in
//                            if selected {
//                                discussionLanguages.insert(language.id)
//                            } else {
//                                discussionLanguages.remove(language.id)
//                            }
//                            saveDiscussionLanguages()
//                        }
//                    )) {
//                        Text(language.name)
//                    }
//                }
            }
        }
        .fancyTabScrollCompatible()
        .hoistNavigation()
    }
    
    private func saveDiscussionLanguages() {
        let newValue = Array(discussionLanguages).sorted()
//        if newValue != siteInformation.myUserInfo?.discussionLanguages {
//            let oldValues = siteInformation.myUserInfo?.discussionLanguages ?? []
//            siteInformation.myUserInfo?.discussionLanguages = newValue
//            Task {
//                if let info = siteInformation.myUserInfo {
//                    do {
//                        // try await apiClient.saveUserSettings(myUserInfo: info)
//                    } catch {
//                        discussionLanguages = Set(oldValues)
//                        siteInformation.myUserInfo?.discussionLanguages = oldValues
//                        errorHandler.handle(error)
//                    }
//                }
//            }
//        }
    }
}
