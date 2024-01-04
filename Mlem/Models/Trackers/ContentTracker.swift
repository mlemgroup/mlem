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
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.hapticManager) var hapticManager
    
    // behavior governors
    private let internetSpeed: InternetSpeed
    var loadItems: (_ page: Int) async throws -> [Content]
    
    // state drivers
    @Published var items: [Content]
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var page: Int = 1
    
    // utility
    private var ids: Set<ContentModelIdentifier> = .init(minimumCapacity: 1000)
    private(set) var hasReachedEnd: Bool = false
    private var currentTask: Task<Void, Never>?
    
    private let prefetcher = ImagePrefetcher(
        pipeline: ImagePipeline.shared,
        destination: .memoryCache,
        maxConcurrentRequestCount: 40
    )
    
    init(
        _ loadItems: @escaping (_ page: Int) async throws -> [Content] = {_ in []},
        internetSpeed: InternetSpeed = .fast,
        initialItems: [Content] = .init()
    ) {
        self.loadItems = loadItems
        self.internetSpeed = internetSpeed
        self.items = initialItems
    }
    
    /// Remove all items from the tracker and call the `loadItems` attribute to load the first page again.
    /// - Parameter loadItems: Optionally replace the `loadItems` callable with a new one.
    /// - Parameter clearImmediately: When true, clears the `items` array before performing the request. When false,
    /// replaces the `items` array when the new set of items is ready.
    func refresh(using loadItems: ((_ page: Int) async throws -> [Content])?, clearImmediately: Bool = false) {
        RunLoop.main.perform { [self] in
            page = 1
            isLoading = true
        }
        if clearImmediately {
            self.items.removeAll()
        }
        if let loadItems = loadItems {
            self.loadItems = loadItems
        }
        
        if let task = currentTask {
            if !task.isCancelled {
                task.cancel()
                currentTask = nil
            }
        }
        currentTask = Task(priority: .userInitiated) { [self] in
            do {
                let items = try await self.loadItems(page)
                RunLoop.main.perform { [self] in
                    self.replaceAll(with: items)
                }
            } catch is CancellationError {
                print("Search cancelled")
            } catch {
                errorHandler.handle(error)
            }
        }
    }
    
    func replaceAll(with items: [Content]) {
        page = 1
        ids.removeAll()
        isLoading = false
        hasReachedEnd = false
        self.items = self.loadItems(items)
    }
    
    /// Load the next page of results. Calls the `loadItems` attribute of the tracker, which returns an array of ContentType items.
    func loadNextPage() async throws {
        let newPage = self.page + 1
        RunLoop.main.perform { [self] in
            isLoading = true
        }
        currentTask = Task(priority: .userInitiated) { [self] in
            do {
                let newItems = try await self.loadItems(newPage)
                RunLoop.main.perform { [self] in
                    self.items.append(contentsOf: loadItems(newItems))
                    self.isLoading = false
                    if newItems.isEmpty {
                        hasReachedEnd = true
                    }
                    self.page = newPage
                }
            } catch is CancellationError {
                print("Page loading cancelled")
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
        guard !isLoading, !hasReachedEnd else { return false }
        let thresholdIndex = max(0, items.index(items.endIndex, offsetBy: -15))
        if thresholdIndex >= 0,
           let itemIndex = items.firstIndex(where: { $0.uid == item.uid }),
           itemIndex >= thresholdIndex {
            isLoading = true
            return true
        }
        return false
    }
    
    /// Prepares items to be added to the tracker by preloading images and removing duplicates
    func loadItems(_ items: [Content]) -> [Content] {
        let newItems = items.filter { ids.insert($0.uid).inserted }
        var imageRequests: [ImageRequest] = []
        URLSession.shared.configuration.urlCache = AppConstants.urlCache
        for item in newItems {
            for url in item.imageUrls {
                imageRequests.append(ImageRequest(url: url))
            }
        }
        prefetcher.startPrefetching(with: imageRequests)
        return newItems
    }
}
