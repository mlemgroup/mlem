//
//  Section.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-30.
//

import Foundation
import SwiftUI

extension Section {
    init(
        _ header: LocalizedStringResource,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) where Parent == Text {
        self.init(content: content, header: { Text(header) }, footer: footer)
    }
    
    @_disfavoredOverload
    init(
        _ header: some StringProtocol,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) where Parent == Text {
        self.init(content: content, header: { Text(header) }, footer: footer)
    }
}
