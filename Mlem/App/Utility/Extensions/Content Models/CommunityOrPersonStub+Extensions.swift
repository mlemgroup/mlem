//
//  CommunityOrPersonStub+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 30/05/2024.
//

import MlemMiddleware
import UIKit

extension CommunityOrPersonStub {
    func copyFullNameWithPrefix() {
        UIPasteboard.general.string = fullNameWithPrefix
        ToastModel.main.add(.success("Copied"))
    }
}
