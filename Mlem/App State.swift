//
//  App State.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation
import SwiftUI
import AlertToast

class AppState: ObservableObject {

    @Published var currentActiveAccount: SavedAccount? {
        didSet {
            if let newAccount = currentActiveAccount {
                Task {
                    let request = GetSiteRequest(account: newAccount)
                    if let response = try? await APIClient().perform(request: request) {
                        await MainActor.run {
                            enableDownvote = response.siteView.localSite.enableDownvotes
                        }
                    }
                }
            }
        }
    }

    @Published var isShowingCommunitySearch: Bool = false

    @Published var isShowingOutdatedInstanceVersionAlert: Bool = false

    @Published var isShowingAlert: Bool = false
    @Published var alertTitle: LocalizedStringKey = ""
    @Published var alertMessage: LocalizedStringKey = ""

    // for those  messages that are less of a .alert ;)
    @Published var isShowingToast: Bool = false
    @Published var toast: AlertToast?

    @Published var criticalErrorType: CriticalError = .shittyInternet

    @Published var enableDownvote: Bool = true
    
}
