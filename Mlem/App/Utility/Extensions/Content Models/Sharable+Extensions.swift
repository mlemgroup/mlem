//
//  Sharable+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-09.
//

import Actions
import Foundation
import MlemMiddleware
import SwiftUI

extension Sharable {
    var lemmyverseUrl: URL? {
        (URL(string: "https://lemmyverse.link/")?
            .appendingPathComponent(actorId.host)
            .appendingPathComponent(actorId.url.path()))
    }
    
    func shareSheetActions() -> [Actions.Action] {
        var shareActions: [Actions.Action] = [SendLinkInMessageAction(url: self.actorId.url)]
        if let post = self as? Post {
            shareActions.prepend(CrosspostAction(entity: post))
        }
        return shareActions
    }
}
