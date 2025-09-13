//
//  View+AccountSwitcherGesture.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-09-03.
//

import SwiftUI

struct AccountSwitcherGesture: ViewModifier {
    let tabReselectTracker: TabReselectTracker
    let navigationModel: NavigationModel
    
    @GestureState private var dragGestureActive: Bool = false
    @State var switcherOpened: Bool = false
    @State var dragCompleted: Bool = false
    
    func body(content: Content) -> some View {
        if #available(iOS 26, *), !UIDevice.isPad {
            content
                .simultaneousGesture(DragGesture()
                    .updating($dragGestureActive) { _, state, _ in
                        state = true
                    }
                    .onChanged { value in
                        if (UIScreen.main.bounds.height - value.startLocation.y) < 80,
                           value.translation.height < -100,
                           !switcherOpened {
                            switcherOpened = true
                            tabReselectTracker.blockTabSwitch = true
                            navigationModel.openSheet(.quickSwitcher)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                tabReselectTracker.blockTabSwitch = false
                            }
                        }
                    })
                .onChange(of: dragGestureActive) {
                    if !dragGestureActive {
                        switcherOpened = false
                    }
                }
        } else {
            content
        }
    }
}

extension View {
    func withAccountSwitcherGesture(tabReselectTracker: TabReselectTracker, navigationModel: NavigationModel) -> some View {
        modifier(AccountSwitcherGesture(tabReselectTracker: tabReselectTracker, navigationModel: navigationModel))
    }
}
