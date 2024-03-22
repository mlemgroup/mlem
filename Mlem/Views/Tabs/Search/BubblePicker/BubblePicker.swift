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
    let tabs: [Value]
    let dividers: Set<DividerPlacement>
    @ViewBuilder let labelBuilder: (Value) -> any View
    
    // currentTabIndex is used to drive the capsule animation; it is tracked separately from selected so that the capsule animations can be triggered independently of any animation (or lack thereof) that is desired on selected
    @State var currentTabIndex: Int
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
        self._currentTabIndex = .init(wrappedValue: 0)
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
                    buttonStack(scrollProxy: scrollProxy)
                        .foregroundStyle(.primary)
                        .background(Color.systemBackground)
                        .overlay {
                            buttonStack()
                                .foregroundStyle(.white)
                                .background(.blue)
                                .allowsHitTesting(false)
                                .mask(alignment: .leading) {
                                    Capsule()
                                        .offset(x: sizes[currentTabIndex].offset + AppConstants.standardSpacing)
                                        .frame(width: max(sizes[currentTabIndex].width - AppConstants.doubleSpacing, 0), height: 30)
                                }
                        }
                        .coordinateSpace(name: spaceName)
                }
                .scrollIndicators(.hidden)
                .onChange(of: selected) { newValue in
                    let newIndex = tabs.firstIndex(of: newValue) ?? 0
                    withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.8)) {
                        currentTabIndex = newIndex
                        scrollProxy.scrollTo(newIndex)
                    }
                }
            }
            
            if dividers.contains(.bottom) {
                Divider()
            }
        }
        .onChange(of: sizes) { newValue in
            print(newValue)
        }
    }
    
    /// Builds the HStack containing the actual buttons
    /// - Parameter scrollProxy: scrollProxy to handle scrolling horizontally to the selected view. If present, the stack will create buttons and apply a ChildSizeReader to them to populate the size information for the masking; otherwise the stack will use inert labels.
    @ViewBuilder
    func buttonStack(scrollProxy: ScrollViewProxy? = nil) -> some View {
        // Use negative spacing as well as padding the HStack's children so that scrollTo leaves extra space around each tab
        HStack(spacing: -AppConstants.doubleSpacing) {
            ForEach(Array(zip(tabs.indices, tabs)), id: \.0) { index, tab in
                if let scrollProxy {
                    ChildSizeReader(sizes: $sizes, index: index, spaceName: spaceName) {
                        bubbleButton(index: index, tab: tab, scrollProxy: scrollProxy)
                    }
                } else {
                    bubbleButtonLabel(tab: tab)
                }
            }
        }
    }
    
    @ViewBuilder
    func bubbleButton(index: Int, tab: Value, scrollProxy: ScrollViewProxy) -> some View {
        Button {
            selected = tab
            hapticManager.play(haptic: .gentleInfo, priority: .low)
        } label: {
            bubbleButtonLabel(tab: tab)
        }
        .buttonStyle(EmptyButtonStyle())
        .id(index)
    }
    
    @ViewBuilder
    func bubbleButtonLabel(tab: Value) -> some View {
        AnyView(labelBuilder(tab))
            .frame(minHeight: 50)
            .padding(.horizontal, 22)
            .font(.subheadline)
            .fontWeight(.semibold)
            .contentShape(Rectangle())
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
