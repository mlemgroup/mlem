//
//  LayoutWidgetView.swift
//  Mlem
//
//  Created by Sjmarf on 02/08/2023.
//

import SwiftUI

struct LayoutWidgetView: View {
    var widget: LayoutWidget
    var isDragging: Bool = false
    
    var animation: Namespace.ID
    
    func icon(_ imageName: String) -> some View {
        Image(systemName: imageName)
            .resizable()
            .scaledToFit()
            .frame(width: AppConstants.barIconSize, height: AppConstants.barIconSize)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            switch widget.type {
            case .upvote:
                icon(Icons.upvote)
            case .downvote:
                icon(Icons.downvote)
            case .save:
                icon(Icons.save)
            case .reply:
                icon(Icons.reply)
            case .share:
                icon(Icons.share)
            case .upvoteCounter:
                icon(Icons.upvote)
                Text("9")
            case .downvoteCounter:
                icon(Icons.downvote)
                Text("2")
            case .scoreCounter:
                icon(Icons.upvote)
                Text("7")
                icon(Icons.downvote)
            default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 40)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .matchedGeometryEffect(id: "Widget\(widget.hashValue)", in: animation)
    }
}
