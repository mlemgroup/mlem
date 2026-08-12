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
import QuickSwipes

extension View {
    @ViewBuilder
    func contextMenu(instance: (any InstanceActionProviding)?) -> some View {
        if let instance {
            contextMenu {
                CustomizableActionMenu(
                    entity: instance,
                    configuration: \.interactionBar_instance,
                    customizable: true
                )
            }
        } else {
            self
        }
    }

    @ViewBuilder
    func quickSwipes(
        instance: (any InstanceActionProviding)?,
        configuration: InstanceActionConfiguration,
        leadingBuffer: SwipeBuffer
    ) -> some View {
        if let instance {
            quickSwipes(
                leading: configuration.swipes.leading.compactMap { $0.createAction(instance) },
                trailing: configuration.swipes.trailing.compactMap { $0.createAction(instance) },
                leadingBuffer: leadingBuffer
            )
        } else {
            quickSwipes(.init())
        }
    }
}

extension ToolbarEllipsisMenu {
    init(instance: any InstanceActionProviding) where Content == ActionButtons {
        self.init {
            ActionButtons { _ in
                InstanceActionConfiguration.availableActions.all.compactMap { $0.createAction(instance) }
            }
        }
    }
}

// MARK: - InstanceActionProviding

public protocol InstanceActionProviding: Sharable, Blockable {
    var instanceStub: InstanceStub { get }
}

extension Instance: InstanceActionProviding {
    public var instanceStub: InstanceStub { .init(api: api, actorId: actorId) }
}

extension InstanceSummary: @retroactive Sharable {}
extension InstanceSummary: @retroactive ActorIdentifiable {}
extension InstanceSummary: @retroactive Blockable {}
extension InstanceSummary: InstanceActionProviding {
    public var actorId: ActorIdentifier { instanceStub.actorId }
    public func url() -> URL { actorId.url }
    public var blocked: any RealizedValueProviding<Bool> {
        let value = AppState.main.firstSession.api.blocks?.contains(instanceActorId: actorId) ?? false
        return RealizedValue(value)
    }
    public var updateBlocked: ((Bool, ((Bool) -> Void)?) -> Void)? { nil }
}

extension InstanceStub: @retroactive Blockable {}
extension InstanceStub: InstanceActionProviding {
    public var instanceStub: InstanceStub { self }
    public var blocked: any RealizedValueProviding<Bool> {
        let value = AppState.main.firstSession.api.blocks?.contains(instanceActorId: actorId) ?? false
        return RealizedValue(value)
    }
    public var updateBlocked: ((Bool, ((Bool) -> Void)?) -> Void)? { nil }
}
