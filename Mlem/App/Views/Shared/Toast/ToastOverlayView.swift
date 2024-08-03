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
    
    @State var activeToasts: [Toast] = []
    
    var toastModel: ToastModel { .main }
    
    var body: some View {
        VStack {
            ForEach(location == .top ? activeToasts : activeToasts.reversed(), id: \.id) { toast in
                ToastView(toast: toast)
                    .transition(
                        activeToasts.count <= 1 ? .move(edge: location.edge).combined(with: .opacity) : .opacity
                    )
                    .onAppear {
                        toast.startKillTask()
                    }
            }
        }
        .animation(.snappy(duration: 0.3, extraBounce: 0.2), value: activeToasts)
        .onChange(of: onChangeHash) {
            let toasts = toastModel.activeToasts(location: location)
            if shouldDisplayNewToasts || toasts.isEmpty {
                activeToasts = toasts
            }
        }
        .onChange(of: shouldDisplayNewToasts) { _, newValue in
            if !newValue {
                activeToasts.forEach { $0.kill() }
                activeToasts = []
            } else {
                Task {
                    try await Task.sleep(nanoseconds: UInt64(100_000_000))
                    Task { @MainActor in
                        addNewToasts(toastModel.activeToasts(location: location), startTimersAgain: true)
                    }
                }
            }
        }
        .onDisappear {
            activeToasts.forEach { $0.kill() }
        }
        .task {
            if shouldDisplayNewToasts, activeToasts.isEmpty {
                do {
                    try await Task.sleep(nanoseconds: UInt64(500_000_000))
                    addNewToasts(toastModel.activeToasts(location: location), startTimersAgain: true)
                } catch {}
            }
        }
    }
    
    func addNewToasts(_ toasts: [Toast], startTimersAgain: Bool = true) {
        for toast in toasts where startTimersAgain || !toast.killTaskStarted {
            toast.startKillTask()
        }
    }
    
    var onChangeHash: Int {
        var hasher = Hasher()
        hasher.combine(toastModel.activeToasts(location: location).map(\.id))
        hasher.combine(shouldDisplayNewToasts)
        return hasher.finalize()
    }
    
    var taskHash: Int {
        var hasher = Hasher()
        hasher.combine(activeToasts.map(\.id))
        hasher.combine(activeToasts.map(\.shouldTimeout))
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
                    "Unfavorited Community",
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
    .environment(Palette.main)
}
