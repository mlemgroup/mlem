//
//  ToastOverlayView.swift
//  Mlem
//
//  Created by Sjmarf on 17/05/2024.
//

import SwiftUI

struct ToastOverlayView: View {
    let shouldDisplayNewToasts: Bool
    let location: ToastLocation
    
    @State var activeToast: Toast?
    @State var activeId: UUID?
    @State var shouldTimeout: Bool = true
    
    var toastModel: ToastModel { .main }
    
    var body: some View {
        VStack {
            if let activeToast {
                ToastView(
                    toast: activeToast,
                    location: location,
                    shouldTimeout: $shouldTimeout
                )
                .id(activeId)
                .transition(
                    .move(edge: location.edge)
                        .combined(with: .opacity)
                )
            }
        }
        .animation(.snappy(duration: 0.3, extraBounce: 0.2), value: activeId)
        .onChange(of: onChangeHash) {
            let activeGroup = toastModel.activeGroup(location: location)
            if shouldDisplayNewToasts || activeGroup?.activeToast == nil {
                activeId = activeGroup?.activeId
                activeToast = activeGroup?.activeToast
            }
            shouldTimeout = true
        }
        .task(id: taskHash) {
            do {
                try await Task.sleep(
                    nanoseconds: UInt64(1_000_000_000 * (activeToast?.duration ?? 1.0))
                )
                if shouldTimeout, activeToast != nil {
                    toastModel.removeFirst(location: location)
                }
            } catch {}
        }
        // When sheet moves to background, remove toast
        .onChange(of: shouldDisplayNewToasts) { _, newValue in
            if !newValue {
                removeToast()
            }
        }
        // When sheet disappears, remove toast
        .onDisappear(perform: removeToast)
        .task {
            if shouldDisplayNewToasts, activeId == nil {
                do {
                    try await Task.sleep(nanoseconds: UInt64(500_000_000))
                    let activeGroup = toastModel.activeGroup(location: location)
                    activeId = activeGroup?.activeId
                    activeToast = activeGroup?.activeToast
                } catch {}
            }
        }
    }
    
    func removeToast() {
        if activeToast != nil {
            toastModel.removeFirst(location: location)
            activeId = nil
            activeToast = nil
        }
    }
    
    var onChangeHash: Int {
        var hasher = Hasher()
        hasher.combine(toastModel.activeGroup(location: location)?.activeId)
        hasher.combine(shouldDisplayNewToasts)
        return hasher.finalize()
    }
    
    var taskHash: Int {
        var hasher = Hasher()
        hasher.combine(activeId)
        hasher.combine(shouldTimeout)
        return hasher.finalize()
    }
}

#Preview {
    VStack {
        Button("Test") {
            ToastModel.main.add(.success())
        }
        Button("Test Long") {
            ToastModel.main.add(
                .basic(
                    title: "Unfavorited Community",
                    systemImage: "star.slash.fill",
                    color: .blue,
                    duration: 5
                )
            )
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .overlay(alignment: .top) {
        ToastOverlayView(shouldDisplayNewToasts: true, location: .top)
    }
    .overlay(alignment: .bottom) {
        ToastOverlayView(shouldDisplayNewToasts: true, location: .bottom)
    }
}
