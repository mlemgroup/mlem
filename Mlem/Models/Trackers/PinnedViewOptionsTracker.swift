//
//  PinnedSortOptionsTracker.swift
//  Mlem
//
//  Created by Sjmarf on 17/09/2023.
//

import SwiftUI
import Dependencies

enum PostViewOption: Codable {
    case showRead, blurNSFW, postSize
    
    static var allCases: [PostViewOption] = [.postSize, .blurNSFW, .showRead]
    
    var label: String {
        switch self {
        case .showRead:
            return "Show Read"
        case .blurNSFW:
            return "Blur NSFW"
        case .postSize:
            return "Post Size"
        }
    }
    
    var iconName: String {
        switch self {
        case .showRead:
            return "book"
        case .blurNSFW:
            return "eye.trianglebadge.exclamationmark"
        case .postSize:
            return  AppConstants.postSizeSettingsSymbolName
        }
    }
}

struct PinnedViewOptions: Codable {
    var sortTypes: Set<PostSortType>
    var topSortTypes: Set<PostSortType>
    var options: Set<PostViewOption>
}

extension PinnedViewOptions {
    init() {
        self.sortTypes = .init([.hot, .new])
        self.topSortTypes = .init([.topDay, .topWeek, .topMonth, .topYear, .topAll])
        self.options = .init([.postSize, .showRead])
    }
}

@MainActor
class PinnedViewOptionsTracker: ObservableObject {
    @Dependency(\.persistenceRepository) var persistenceRepository
    
    @Published var pinned: PinnedViewOptions = .init()
    
    init() {
        self.pinned = persistenceRepository.loadPinnedSortOptions()
    }
    
    func save() {
        Task(priority: .background) {
            try await persistenceRepository.savePinnedSortOptions(pinned)
        }
    }
}
