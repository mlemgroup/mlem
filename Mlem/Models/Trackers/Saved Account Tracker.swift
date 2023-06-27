//
//  Saved Community Tracker.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Foundation

class SavedAccountTracker: ObservableObject {
    @Published var savedAccounts: [SavedAccount] = .init()
}
