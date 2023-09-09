//
//  DismissAction.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-09-08.
//

import Foundation
import SwiftUI

final class Navigation: ObservableObject {
    var dismiss: DismissAction?
}

extension View {
    
    func hoistNavigation(dismiss: DismissAction) -> some View {
        modifier(NavigationDismissHoisting(dismiss: dismiss))
    }
}

struct NavigationDismissHoisting: ViewModifier {
    
    @EnvironmentObject private var navigation: Navigation
    
    /// - Note: Unfortunately, we can't access the dismiss action via View.environment...doing so causes SwiftUI to enter into infinite loop. [2023.09]
    let dismiss: DismissAction
    
    func body(content: Content) -> some View {
        content.onAppear {
            print("onAppear: navigate dismiss")
            navigation.dismiss = dismiss
        }
    }
}
