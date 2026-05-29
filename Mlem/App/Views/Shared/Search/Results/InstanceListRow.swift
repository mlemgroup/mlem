//
//  InstanceListRow.swift
//  Mlem
//
//  Created by Sjmarf on 06/07/2024.
//

import ComponentViews
import MlemBackend
import MlemMiddleware
import SwiftUI

struct InstanceListRow<Content2: View>: View {
    typealias Content = InstanceListRowBody<Content2>
    
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Setting(\.interactionBar_instance) var instanceActionConfiguration
    
    let instance: any InstanceActionProviding
    let content: Content
    let visitContext: VisitHistory.VisitContext

    init(
        _ instance: Instance,
        @ViewBuilder content: @escaping () -> Content2 = { EmptyView() },
        showBlockStatus: Bool = true,
        readout: Content.Readout? = nil,
        visitContext: VisitHistory.VisitContext = .other
    ) {
        self.instance = instance
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
        self.instance = summary
        self.content = .init(summary, content: content, showBlockStatus: showBlockStatus, readout: readout)
        self.visitContext = visitContext
    }
    
    var body: some View {
        Button {
            if let instance = instance as? Instance {
                navigation.push(.instance(instance, visitContext: visitContext))
            } else {
                navigation.push(.instanceStub(instance.instanceStub, visitContext: visitContext))
            }
        } label: {
            FormChevron { content }
                .padding(.trailing)
        }
        .buttonStyle(.empty)
        .padding(.vertical, 6)
        .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
        .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
        .contextMenu(instance: instance)
        .quickSwipes(instance: instance, configuration: instanceActionConfiguration, leadingBuffer: .standard)
        .popupAnchor()
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
    }
}
