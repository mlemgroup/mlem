//
//  App State.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation
import SwiftUI

class AppState: ObservableObject
{
    
    @Published var currentActiveInstance: String = ""
    @Published var currentActiveAccount: SavedAccount?
    
    @Published var isShowingCommunitySearch: Bool = false
    
    @Published var isShowingOutdatedInstanceVersionAlert: Bool = false
    
    @Published var isShowingAlert: Bool = false
    @Published var alertTitle: LocalizedStringKey = ""
    @Published var alertMessage: LocalizedStringKey = ""
    
    @Published var criticalErrorType: CriticalError = .shittyInternet
}
