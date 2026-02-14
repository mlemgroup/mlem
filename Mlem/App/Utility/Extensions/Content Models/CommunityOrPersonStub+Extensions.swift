//
//  CommunityOrPersonStub+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 30/05/2024.
//

import MlemMiddleware
import SwiftUI
import Theming

extension CommunityOrPerson {
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
                color: .themedNeutralAccent,
                icon: Icons.copy,
                swipeIcon2: Icons.copyFill
            ),
            callback: { self.copyFullNameWithPrefix(feedback: feedback) }
        )
    }
    
    func attributedName(
        showInstance: Bool = true,
        font: Font = .body,
        palette: Theming.Palette,
        nameColor: ThemedColor = .themedSecondary,
        instanceColor: ThemedColor = .themedTertiary
    ) -> AttributedString? {
        var outputString = AttributedString(name)
        outputString.foregroundColor = nameColor.resolve(with: palette)
        outputString.font = font.bold()
        
        if showInstance {
            var instanceString = AttributedString("@\(host)")
            instanceString.foregroundColor = instanceColor.resolve(with: palette)
            instanceString.font = font
            outputString += instanceString
        }
        
        outputString.link = actorId.url
        return outputString
    }
    
    func nameTextView(
        showFlairs: Bool,
        showInstance: Bool = true,
        communityContext: (any DeprecatedCommunity)? = nil,
        font: Font = .body,
        palette: Theming.Palette,
        nameColor: ThemedColor = .themedSecondary,
        instanceColor: ThemedColor = .themedTertiary
    ) -> Text {
        let attributedName = attributedName(
            showInstance: showInstance,
            font: font,
            palette: palette,
            nameColor: nameColor,
            instanceColor: instanceColor
        )
        if showFlairs, let flairs = (self as? Person)?.flairs(communityContext: communityContext) {
            return flairs.textView.font(font) + Text(attributedName ?? "")
        } else {
            return Text(attributedName ?? "")
        }
    }
}
