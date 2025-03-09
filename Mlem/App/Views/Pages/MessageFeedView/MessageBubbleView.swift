//
//  MessageBubbleView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-22.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct MessageBubbleView: View {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.palette) var palette
    
    let message: any Message
    var editCallback: @MainActor () -> Void
    
    var body: some View {
        Group {
            let blocks: [BlockNode] = .init(message.content)
            if blocks.isSimpleParagraphs {
                MarkdownText(
                    blocks, configuration: message.isOwnMessage ? .inverted(palette: palette) : .default(palette: palette)
                )
            } else {
                Markdown(
                    blocks, configuration: message.isOwnMessage ? .inverted(palette: palette) : .default(palette: palette)
                )
            }
        }
        .tint(message.isOwnMessage ? palette.contrastingLabel.opacity(0.6) : palette.accent)
        .padding(Constants.main.standardSpacing)
        .padding(message.isOwnMessage ? .trailing : .leading, 7)
        .padding(message.isOwnMessage ? .leading : .trailing, 2)
        .background(
            message.isOwnMessage ? .themedAccent : .themedSecondaryGroupedBackground,
            in: BubbleShape(myMessage: message.isOwnMessage)
        )
        .contentShape(.contextMenuPreview, BubbleShape(myMessage: message.isOwnMessage))
        .contextMenu {
            message.allMenuActions(appState: appState, isInMessageFeed: true, editCallback: editCallback, navigation: navigation)
        }
    }
}

private struct BubbleShape: Shape {
    var myMessage: Bool
    
    // swiftlint:disable:next function_body_length
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        
        let bezierPath = UIBezierPath()
        if !myMessage {
            bezierPath.move(to: CGPoint(x: 20, y: height))
            bezierPath.addLine(to: CGPoint(x: width - 15, y: height))
            bezierPath.addCurve(
                to: CGPoint(x: width, y: height - 15),
                controlPoint1: CGPoint(x: width - 8, y: height),
                controlPoint2: CGPoint(x: width, y: height - 8)
            )
            bezierPath.addLine(to: CGPoint(x: width, y: 15))
            bezierPath.addCurve(
                to: CGPoint(x: width - 15, y: 0),
                controlPoint1: CGPoint(x: width, y: 8),
                controlPoint2: CGPoint(x: width - 8, y: 0)
            )
            bezierPath.addLine(to: CGPoint(x: 20, y: 0))
            bezierPath.addCurve(
                to: CGPoint(x: 5, y: 15),
                controlPoint1: CGPoint(x: 12, y: 0),
                controlPoint2: CGPoint(x: 5, y: 8)
            )
            bezierPath.addLine(to: CGPoint(x: 5, y: height - 10))
            bezierPath.addCurve(
                to: CGPoint(x: 0, y: height),
                controlPoint1: CGPoint(x: 5, y: height - 1),
                controlPoint2: CGPoint(x: 0, y: height)
            )
            bezierPath.addLine(to: CGPoint(x: -1, y: height))
            bezierPath.addCurve(
                to: CGPoint(x: 12, y: height - 4),
                controlPoint1: CGPoint(x: 4, y: height + 1),
                controlPoint2: CGPoint(x: 8, y: height - 1)
            )
            bezierPath.addCurve(
                to: CGPoint(x: 20, y: height),
                controlPoint1: CGPoint(x: 15, y: height),
                controlPoint2: CGPoint(x: 20, y: height)
            )
        } else {
            bezierPath.move(to: CGPoint(x: width - 20, y: height))
            bezierPath.addLine(to: CGPoint(x: 15, y: height))
            bezierPath.addCurve(
                to: CGPoint(x: 0, y: height - 15),
                controlPoint1: CGPoint(x: 8, y: height),
                controlPoint2: CGPoint(x: 0, y: height - 8)
            )
            bezierPath.addLine(to: CGPoint(x: 0, y: 15))
            bezierPath.addCurve(
                to: CGPoint(x: 15, y: 0),
                controlPoint1: CGPoint(x: 0, y: 8),
                controlPoint2: CGPoint(x: 8, y: 0)
            )
            bezierPath.addLine(to: CGPoint(x: width - 20, y: 0))
            bezierPath.addCurve(
                to: CGPoint(x: width - 5, y: 15),
                controlPoint1: CGPoint(x: width - 12, y: 0),
                controlPoint2: CGPoint(x: width - 5, y: 8)
            )
            bezierPath.addLine(to: CGPoint(x: width - 5, y: height - 12))
            bezierPath.addCurve(
                to: CGPoint(x: width, y: height),
                controlPoint1: CGPoint(x: width - 5, y: height - 1),
                controlPoint2: CGPoint(x: width, y: height)
            )
            bezierPath.addLine(to: CGPoint(x: width + 1, y: height))
            bezierPath.addCurve(
                to: CGPoint(x: width - 12, y: height - 4),
                controlPoint1: CGPoint(x: width - 4, y: height + 1),
                controlPoint2: CGPoint(x: width - 8, y: height - 1)
            )
            bezierPath.addCurve(
                to: CGPoint(x: width - 20, y: height),
                controlPoint1: CGPoint(x: width - 15, y: height),
                controlPoint2: CGPoint(x: width - 20, y: height)
            )
        }
        return Path(bezierPath.cgPath)
    }
}
