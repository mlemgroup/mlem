//
//  SearchTabPicker.swift
//  Mlem
//
//  Created by Sjmarf on 18/09/2023.
//

import Dependencies
import SwiftUI

enum DividerPlacement {
    case top, bottom
}

struct BubblePickerItemFrame: Equatable {
    let width: CGFloat
    let offset: CGFloat
}

struct BubblePicker<Value: Identifiable & Equatable & Hashable>: View {
    @Dependency(\.hapticManager) var hapticManager
    
    @Binding var selected: Value
    @State var selectedTabIndex: Int
    let tabs: [Value]
    let dividers: Set<DividerPlacement>
    @ViewBuilder let labelBuilder: (Value) -> any View
    
    @State var sizes: [BubblePickerItemFrame]
    let spaceName: String = UUID().uuidString
    
    init(
        _ tabs: [Value],
        selected: Binding<Value>,
        withDividers: Set<DividerPlacement> = .init(),
        @ViewBuilder labelBuilder: @escaping (Value) -> any View
    ) {
        assert(tabs.isNotEmpty, "Cannot create bubble picker with empty tabs!")
        
        self._selected = selected
        self._selectedTabIndex = .init(wrappedValue: 0)
        self.tabs = tabs
        self.dividers = withDividers
        self.labelBuilder = labelBuilder
        self._sizes = .init(wrappedValue: .init(repeating: .init(width: .zero, offset: .zero), count: tabs.indices.count))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if dividers.contains(.top) {
                Divider()
            }
            
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal) {
                    // Use negative spacing as well as padding the HStack's children so that scrollTo leaves extra space around each tab
                    // HStack(spacing: -AppConstants.doubleSpacing) {
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.blue)
                            .offset(x: sizes[selectedTabIndex].offset)
                            .frame(width: sizes[selectedTabIndex].width, height: 30)
                        
                        HStack {
                            ForEach(Array(zip(tabs.indices, tabs)), id: \.0) { index, tab in
                                ChildSizeReader(sizes: $sizes, index: index, spaceName: spaceName) {
                                    bubbleButton(index: index, tab: tab, scrollProxy: scrollProxy)
                                }
                            }
                        }
                    }
                    .coordinateSpace(name: spaceName)
                }
                .scrollIndicators(.hidden)
            }
            
            if dividers.contains(.bottom) {
                Divider()
            }
        }
        .onChange(of: sizes) { newValue in
            print(newValue)
        }
    }
    
    @ViewBuilder
    func bubbleButton(index: Int, tab: Value, scrollProxy: ScrollViewProxy) -> some View {
        Button {
            selected = tab
            hapticManager.play(haptic: .gentleInfo, priority: .low)
            withAnimation {
                selectedTabIndex = index
                scrollProxy.scrollTo(index)
            }
        } label: {
            AnyView(labelBuilder(tab))
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .foregroundStyle(selected == tab ? .white : .primary)
                .font(.subheadline)
                .fontWeight(.semibold)
//                .background(
//                    Group {
//                        if selected == tab {
//                            Capsule()
//                                .fill(.blue)
//                                .transition(.scale.combined(with: .opacity))
//                        }
//                    }
//                )
                .padding(AppConstants.standardSpacing)
                .animation(.spring(response: 0.15, dampingFraction: 0.7), value: selected)
                .contentShape(Rectangle())
        }
        .buttonStyle(EmptyButtonStyle())
        .id(index)
    }
}

#Preview {
    BubblePicker(
        InstanceViewTab.allCases,
        selected: .constant(.about)
    ) {
        Text($0.label)
    }
}
