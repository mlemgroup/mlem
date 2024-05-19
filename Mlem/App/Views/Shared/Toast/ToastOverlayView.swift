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
    @State var shouldTimeout: Bool = true
    
    var toastModel: ToastModel { .main }
    
    var body: some View {
        VStack {
            if let activeToast {
                ToastView(
                    toast: activeToast,
                    shouldTimeout: $shouldTimeout
                )
                .id(activeToast)
                .transition(
                    .move(edge: location.edge)
                        .combined(with: .opacity)
                )
            }
        }
        .animation(.snappy(duration: 0.3, extraBounce: 0.2), value: activeToast)
        .onChange(of: onChangeHash) {
            let toast = toastModel.activeToast(location: location)
            if shouldDisplayNewToasts || toast == nil {
                activeToast = toast
            }
            shouldTimeout = true
        }
        .task(id: taskHash) {
            do {
                try await Task.sleep(
                    nanoseconds: UInt64(1_000_000_000 * (activeToast?.type.duration ?? 1.0))
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
            if shouldDisplayNewToasts, activeToast == nil {
                do {
                    try await Task.sleep(nanoseconds: UInt64(500_000_000))
                    activeToast = toastModel.activeToast(location: location)
                } catch {}
            }
        }
    }
    
    func removeToast() {
        if activeToast != nil {
            toastModel.removeFirst(location: location)
            activeToast = nil
        }
    }
    
    var onChangeHash: Int {
        var hasher = Hasher()
        hasher.combine(toastModel.activeToast(location: location))
        hasher.combine(shouldDisplayNewToasts)
        return hasher.finalize()
    }
    
    var taskHash: Int {
        var hasher = Hasher()
        hasher.combine(activeToast)
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
