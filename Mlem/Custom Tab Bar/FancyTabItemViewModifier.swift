//
//  FancyTabItemViewModifier.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-17.
//

import Foundation
import SwiftUI

struct FancyTabItem<Selection: Hashable, V: View>: ViewModifier {
    
    @Environment(\.tabSelectionHashValue) private var selectedTagHashValue
    private let tagHashValue: Int
    private let tag: Selection
    @ViewBuilder private let label: () -> V
    
    init(tag: Selection, @ViewBuilder label: @escaping () -> V) {
        self.tagHashValue = tag.hashValue
        self.tag = tag
        self.label = label
    }
    
    func body(content: Content) -> some View {
        Group {
            if selectedTagHashValue == tagHashValue {
                content
            } else {
                Color.clear
            }
        }
        // this little preference tells the parent bar that this tab item exists
        .preference(key: FancyTabItemPreferenceKey<Selection>.self, value: [tag])
        // and this big ugly one adds its label builder to the dictionary
        .preference(key: FancyTabItemLabelBuilderPreferenceKey<Selection>.self,
                    value: [tag: FancyTabItemLabelBuilder(tag: tag,
                                                          label: { AnyView(Group(content: label)) })]
        )
    }
}

extension View {
    @ViewBuilder
    func fancyTabItem<Selection: Hashable, V: View>(tag: Selection,
                                                    @ViewBuilder label: @escaping () -> V) -> some View {
        modifier(FancyTabItem(tag: tag, label: label))
    }
}
