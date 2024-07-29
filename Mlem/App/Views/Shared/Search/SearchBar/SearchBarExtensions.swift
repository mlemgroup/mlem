//
// Modified version of code taken from the open-source SwiftUIX library.
//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public extension View {
    @inlinable
    func then(_ body: (inout Self) -> Void) -> Self {
        var result = self
        
        body(&result)
        
        return result
    }
}

public extension Binding {
    func removeDuplicates() -> Self where Value: Equatable {
        .init(
            get: { self.wrappedValue },
            set: { newValue in
                let oldValue = self.wrappedValue
                
                guard newValue != oldValue else {
                    return
                }
                
                self.wrappedValue = newValue
            }
        )
    }
}
