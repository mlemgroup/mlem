//
//  BlockPerson.swift
//  Mlem
//
//  Created by Weston Hanners on 7/10/23.
//

import Foundation

@MainActor
func blockPerson(
    account: SavedAccount,
    person: APIPerson,
    blocked: Bool) async throws -> Bool {
        do {
            let request = BlockPersonRequest(
                account: account,
                personId: person.id,
                block: blocked
            )
            let response = try await APIClient().perform(request: request)
            return response.blocked
        } catch {
            return false
        }
    }
