//
//  CommunityOrUserStub.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation
import SwiftUI

protocol CommunityOrPersonStub: ContentStub {
    static var identifierPrefix: String { get }
    
    var name: String { get }
}

extension CommunityOrPersonStub {
    var name: String { actorId.lastPathComponent }

    var fullName: String? {
        guard let host else { return nil }
        return "\(name)@\(host)"
    }
    
    var fullNameWithPrefix: String? {
        guard let host else { return nil }
        return "\(Self.identifierPrefix)\(name)@\(host)"
    }
    
    func copyFullNameWithPrefix(notifier: Notifier?) {
        let pasteboard = UIPasteboard.general
        if let fullNameWithPrefix {
            pasteboard.string = fullNameWithPrefix
            Task {
                await notifier?.add(.success("Name Copied"))
            }
        } else {
            Task {
                await notifier?.add(.failure("Failed to copy"))
            }
        }
    }
}
