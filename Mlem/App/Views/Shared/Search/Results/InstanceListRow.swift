//
//  InstanceListRow.swift
//  Mlem
//
//  Created by Sjmarf on 06/07/2024.
//

import MlemMiddleware
import SwiftUI

struct InstanceListRow<Content2: View>: View {
    typealias Content = InstanceListRowBody<Content2>
    
    @Environment(Palette.self) var palette
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    
    let instance: (any Instance)?
    let summary: InstanceSummary?
    let content: Content

    init(
        _ instance: any Instance,
        @ViewBuilder content: @escaping () -> Content2 = { EmptyView() }
    ) {
        self.instance = instance
        self.summary = nil
        self.content = .init(instance, content: content)
    }
    
    init(
        _ summary: InstanceSummary,
        @ViewBuilder content: @escaping () -> Content2 = { EmptyView() }
    ) where Content2 == EmptyView {
        self.summary = summary
        self.instance = nil
        self.content = .init(summary, content: content)
    }
    
    private var instanceStub: (any InstanceStubProviding)? {
        instance ?? summary?.instanceStub
    }
    
    var body: some View {
        HStack(spacing: 0) {
            content
            Image(systemName: Icons.forward)
                .imageScale(.small)
                .foregroundStyle(palette.tertiary)
        }
        .padding(.trailing)
        .padding(.vertical, 6)
        .onTapGesture {
            if let instanceStub {
                navigation.push(.instance(instanceStub))
            }
        }
        .background(palette.background)
        .contextMenu(
            actions: instanceStub?.menuActions(allowExternalBlocking: true) ?? []
        )
    }
}
