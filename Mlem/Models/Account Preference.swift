//
//  Account Preference.swift
//  Mlem
//
//  Created by tht7 on 24/06/2023.
//

import Foundation
import SwiftUI

struct AccountPreference: Decodable, Identifiable, Hashable, Equatable, Encodable {
    var id: Int { self.hashValue }

    var requiresSecurity: Bool?

    func hash(into hasher: inout Hasher) {
        hasher.combine(requiresSecurity)
    }

}
