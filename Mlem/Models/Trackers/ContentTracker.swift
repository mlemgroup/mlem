//
//  ContentTracker.swift
//  Mlem
//
//  Created by Sjmarf on 21/09/2023.
//

import SwiftUI
import Dependencies
import Nuke

class ContentTracker<Content: ContentModel>: ObservableObject {
    // dependencies
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.hapticManager) var hapticManager
    
    // behavior governors
    private let internetSpeed: InternetSpeed
    var loadItems: (_ page: Int) async throws -> [Content]
    
    // state drivers
    @Published var items: [Content]
    
    // utility
    private(set) var page: Int = 1
    private(set) var isLoading: Bool = false
    private var currentTask: Task<Void, Never>?
    
    init(
        _ loadItems: @escaping (_ page: Int) async throws -> [Content] = {_ in []},
        internetSpeed: InternetSpeed = .fast,
        initialItems: [Content] = .init()
    ) {
        self.loadItems = loadItems
        self.internetSpeed = internetSpeed
        self.items = initialItems
    }
    
    func refresh(with loadItems: ((_ page: Int) async throws -> [Content])?) {
        if let task = currentTask {
            if !task.isCancelled {
                task.cancel()
                currentTask = nil
            }
        }
        if let loadItems = loadItems {
            self.loadItems = loadItems
        }
        
        page = 1
        
        currentTask = Task(priority: .userInitiated) { [self] in
            do {
                let items = try await self.loadItems(page)
                RunLoop.main.perform { [self] in
                    self.items = items
                    preloadImages(for: items)
                }
            } catch is CancellationError {
                print("Search cancelled")
            } catch {
                errorHandler.handle(error)
            }
        }
    }
    
    func loadNextPage() async throws {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        page += 1
        currentTask = Task(priority: .userInitiated) { [self] in
            do {
                let items = try await self.loadItems(page)
                RunLoop.main.perform { [self] in
                    self.items.append(contentsOf: items)
                    preloadImages(for: items)
                }
            } catch is CancellationError {
                print("Search cancelled")
            } catch {
                errorHandler.handle(error)
            }
        }
    }
    
    @MainActor
    func update(with updatedModel: Content) {
        guard let index = items.firstIndex(where: { $0.uid == updatedModel.uid }) else {
            return
        }
        items[index] = updatedModel
    }
    
    @MainActor
    func shouldLoadContentAfter(after item: Content) -> Bool {
        guard !isLoading else { return false }
        let thresholdIndex = max(0, items.index(items.endIndex, offsetBy: AppConstants.infiniteLoadThresholdOffset))
        if thresholdIndex >= 0,
           let itemIndex = items.firstIndex(where: { $0.uid == item.uid }),
           itemIndex >= thresholdIndex {
            return true
        }
        return false
    }
    
    private func preloadImages(for newItems: [Content]) {
        URLSession.shared.configuration.urlCache = AppConstants.urlCache
        for item in newItems {
            for url in item.imageUrls {
                ImageRequest(url: url)
            }
        }
    }
}
