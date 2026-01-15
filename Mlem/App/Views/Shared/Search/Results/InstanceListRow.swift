//
//  InstanceListRow.swift
//  Mlem
//
//  Created by Sjmarf on 06/07/2024.
//

import ComponentViews
import MlemMiddleware
import SwiftUI

struct InstanceListRow<Content2: View>: View {
    typealias Content = InstanceListRowBody<Content2>
    
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    
    let instance: (any Instance)?
    let summary: InstanceSummary?
    let content: Content
    let visitContext: VisitHistory.VisitContext

    init(
        _ instance: any Instance,
        @ViewBuilder content: @escaping () -> Content2 = { EmptyView() },
        showBlockStatus: Bool = true,
        readout: Content.Readout? = nil,
        visitContext: VisitHistory.VisitContext = .other
    ) {
        self.instance = instance
        self.summary = nil
        self.content = .init(instance, content: content, showBlockStatus: showBlockStatus, readout: readout)
        self.visitContext = visitContext
    }
    
    init(
        _ summary: InstanceSummary,
        @ViewBuilder content: @escaping () -> Content2 = { EmptyView() },
        showBlockStatus: Bool = true,
        readout: Content.Readout? = nil,
        visitContext: VisitHistory.VisitContext = .other
    ) where Content2 == EmptyView {
        self.summary = summary
        self.instance = nil
        self.content = .init(summary, content: content, showBlockStatus: showBlockStatus, readout: readout)
        self.visitContext = visitContext
    }
    
    private var instanceStub: (any InstanceStubProviding)? {
        instance ?? summary?.instanceStub
    }
    
    var body: some View {
        Button {
            if let instanceStub {
                navigation.push(.instance(instanceStub, visitContext: visitContext))
            }
        } label: {
            FormChevron { content }
                .padding(.trailing)
        }
        .buttonStyle(.empty)
        .padding(.vertical, 6)
        .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
        .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
        .contextMenu(instance: instanceStub)
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
    }
}
