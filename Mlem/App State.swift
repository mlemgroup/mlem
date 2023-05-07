//
//  App State.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation

class AppState: ObservableObject
{
    @Published var currentActiveInstance: String = ""
    
    @Published var isShowingCriticalError: Bool = false
    
    @Published var criticalErrorType: CriticalError = .shittyInternet
}
