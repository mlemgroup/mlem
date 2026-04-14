//
//  ContextMenu+Instance.swift
//  Mlem
//
//  Created by Sjmarf on 2026-01-15.
//

import Actions
import MlemMiddleware
import SwiftUI
import MlemBackend

private let seeds: [ActionSeed] = [
    .visit,
    .logIn,
    .signUp,
    .openInBrowser,
    .share,
    .block
]

extension View {
    @ViewBuilder
    func contextMenu(instance: (any InstanceActionProviding)?) -> some View {
        if let instance {
            contextMenu {
                ActionButtons { _ in
                    seeds.compactMap { $0.createAction(instance) }
                }
            }
        } else {
            self
        }
    }
}

extension ToolbarEllipsisMenu {
    init(instance: any InstanceActionProviding) where Content == ActionButtons {
        self.init {
            ActionButtons { _ in
                seeds.compactMap { $0.createAction(instance) }
            }
        }
    }
}

extension View {
    @ViewBuilder
    func contextMenu(instance: any InstanceActionProviding) -> some View {
        contextMenu {
            ActionButtons { _ in
                seeds.compactMap { $0.createAction(instance) }
            }
        }
    }
}

// MARK: - InstanceActionProviding

public protocol InstanceActionProviding {
    var actorId: ActorIdentifier { get }
    var host: String { get }
    var instanceStub: InstanceStub { get }
}

extension Instance: InstanceActionProviding {
    public var instanceStub: InstanceStub { .init(api: api, actorId: actorId) }
}

extension InstanceSummary: InstanceActionProviding {
    public var actorId: ActorIdentifier { instanceStub.actorId }
}
