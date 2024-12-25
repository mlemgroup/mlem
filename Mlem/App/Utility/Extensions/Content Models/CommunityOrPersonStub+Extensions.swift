//
//  CommunityOrPersonStub+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 30/05/2024.
//

import MlemMiddleware
import SwiftUI

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
            appearance: .init(
                label: "Copy Name",
                color: .gray,
                icon: Icons.copy,
                swipeIcon2: Icons.copyFill
            ),
            callback: { self.copyFullNameWithPrefix(feedback: feedback) }
        )
    }
    
    func attributedName(
        showInstance: Bool = true,
        font: Font = .body,
        nameColor: Color? = nil,
        instanceColor: Color? = nil
    ) -> AttributedString? {
        guard let host else { return nil }
        var outputString = AttributedString(name)
        outputString.foregroundColor = nameColor ?? Palette.main.secondary
        outputString.font = font.bold()
        
        if showInstance {
            var instanceString = AttributedString("@\(host)")
            instanceString.foregroundColor = instanceColor ?? Palette.main.tertiary
            instanceString.font = font
            outputString += instanceString
        }
        
        outputString.link = actorId
        return outputString
    }
    
    func nameTextView(
        showFlairs: Bool,
        showInstance: Bool = true,
        communityContext: (any Community)? = nil,
        font: Font = .body,
        nameColor: Color? = nil,
        instanceColor: Color? = nil
    ) -> Text {
        let attributedName = attributedName(
            showInstance: showInstance,
            font: font,
            nameColor: nameColor,
            instanceColor: instanceColor
        )
        if showFlairs, let flairs = (self as? any Person)?.flairs(communityContext: communityContext) {
            return flairs.textView.font(font) + Text(attributedName ?? "")
        } else {
            return Text(attributedName ?? "")
        }
    }
}
