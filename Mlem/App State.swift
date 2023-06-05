//
//  App State.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation

class AppState: ObservableObject
{
    
    enum ActiveAlert
    {
        case generalError, connectionToLemmyError, customError(title: String, message: String)
    }
    
    @Published var currentActiveInstance: String = ""
    
    @Published var isShowingAlert: Bool = false
    @Published var alertType: ActiveAlert?
    
    @Published var criticalErrorType: CriticalError = .shittyInternet
}
