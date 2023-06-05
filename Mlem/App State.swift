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
    
    enum ActiveAlert
    {
        case generalError, connectionToLemmyError, customError(title: String, message: String)
    }
    
    @Published var currentActiveInstance: String = ""
    
    @Published var isShowingAlert: Bool = false
    @Published var alertTitle: LocalizedStringKey = ""
    @Published var alertMessage: LocalizedStringKey = ""
    
    @Published var criticalErrorType: CriticalError = .shittyInternet
}
