//
//  EasterFlagsTracker.swift
//  Mlem
//
//  Created by tht7 on 13/07/2023.
//

import Combine
import Dependencies
import Foundation

@MainActor
class EasterFlagsTracker: ObservableObject {
    @Dependency(\.persistenceRepository) private var persistenceRepository
    @Dependency(\.notifier) private var notifier
    
    @Published var flags: Set<EasterFlag> = .init()
    private var updateObserver: AnyCancellable?
    
    init() {
        _flags = .init(initialValue: persistenceRepository.loadEasterFlags())
        self.updateObserver = $flags.sink { [weak self] value in
            Task {
                try await self?.persistenceRepository.saveEasterFlags(value)
            }
        }
    }
    
    func setEasterFlag(_ flag: EasterFlag) {
        let (isNew, _) = flags.insert(flag)
        guard isNew, let rewards = easterReward[flag] else { return }
        Task {
            await notifier.add(rewards)
        }
    }
}
