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
                icon(AppConstants.plainUpvoteSymbolName)
            case .downvote:
                icon(AppConstants.plainDownvoteSymbolName)
            case .save:
                icon(AppConstants.emptySaveSymbolName)
            case .reply:
                icon(AppConstants.emptyReplySymbolName)
            case .share:
                icon(AppConstants.shareSymbolName)
            case .upvoteCounter:
                icon(AppConstants.plainUpvoteSymbolName)
                Text("9")
            case .downvoteCounter:
                icon(AppConstants.plainDownvoteSymbolName)
                Text("2")
            case .scoreCounter:
                icon(AppConstants.plainUpvoteSymbolName)
                Text("7")
                icon(AppConstants.plainDownvoteSymbolName)
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
