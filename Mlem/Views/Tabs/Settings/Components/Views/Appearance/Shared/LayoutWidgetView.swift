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
                icon(Icons.plainUpvoteSymbolName)
            case .downvote:
                icon(Icons.plainDownvoteSymbolName)
            case .save:
                icon(Icons.emptySaveSymbolName)
            case .reply:
                icon(Icons.emptyReplySymbolName)
            case .share:
                icon(Icons.shareSymbolName)
            case .upvoteCounter:
                icon(Icons.plainUpvoteSymbolName)
                Text("9")
            case .downvoteCounter:
                icon(Icons.plainDownvoteSymbolName)
                Text("2")
            case .scoreCounter:
                icon(Icons.plainUpvoteSymbolName)
                Text("7")
                icon(Icons.plainDownvoteSymbolName)
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
