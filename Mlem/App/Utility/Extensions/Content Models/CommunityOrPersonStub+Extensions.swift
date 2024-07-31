//
//  CommunityOrPersonStub+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 30/05/2024.
//

import MlemMiddleware
import UIKit

extension CommunityOrPersonStub {
    func copyFullNameWithPrefix(feedback: Set<FeedbackType> = [.toast]) {
        if feedback.contains(.toast) {
            ToastModel.main.add(.success("Copied"))
        }
        UIPasteboard.general.string = fullNameWithPrefix
    }
    
    func copyNameAction(feedback: Set<FeedbackType> = [.toast]) -> BasicAction {
        .init(
            id: "copyName\(actorId)",
            isOn: false,
            label: "Copy Name",
            color: .gray,
            icon: Icons.copy,
            swipeIcon2: Icons.copyFill,
            callback: { self.copyFullNameWithPrefix(feedback: feedback) }
        )
    }
}
