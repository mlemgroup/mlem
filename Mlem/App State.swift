//
//  App State.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation
import SwiftUI
import AlertToast

class AppState: ObservableObject
{
    
    @Published var currentActiveInstance: String = ""
    @Published var currentActiveAccount: SavedAccount?
    
    @Published var isShowingCommunitySearch: Bool = false
    
    @Published var isShowingOutdatedInstanceVersionAlert: Bool = false
    
    @Published var isShowingAlert: Bool = false
    @Published var alertTitle: LocalizedStringKey = ""
    @Published var alertMessage: LocalizedStringKey = ""
    
    // for those  messages that are less of a .alert ;)
    @Published var isShowingToast: Bool = false
    @Published var toast: AlertToast?
    
    @Published var criticalErrorType: CriticalError = .shittyInternet
}
