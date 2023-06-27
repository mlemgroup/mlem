//
//  Contributor.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation

struct Contributor: Identifiable {
    var id: UUID = UUID()

    let name: String
    let avatarLink: URL
    let reasonForAcknowledgement: String
    let websiteLink: URL
}
