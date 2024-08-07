//
//  BubblePickerView.swift
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
    @Environment(Palette.self) var palette
    
    @Binding var selected: Value
    
    // currentTabIndex is used to drive the capsule animation; it is tracked separately from selected so that the capsule animations can be triggered independently of any animation (or lack thereof) that is desired on selected
    @State var currentTabIndex: Int
    @State var sizes: [BubblePickerItemFrame]
    
    let tabs: [Value]
    let dividers: Set<DividerPlacement>
    let label: (Value) -> LocalizedStringResource
    let value: (Value) -> Int?
    let spaceName: String = UUID().uuidString
    
    init(
        _ tabs: [Value],
        selected: Binding<Value>,
        withDividers: Set<DividerPlacement> = .init(),
        label: @escaping (Value) -> LocalizedStringResource,
        value: @escaping (Value) -> Int? = { _ in nil }
    ) {
        let initialIndex = tabs.firstIndex(of: selected.wrappedValue)
        
        assert(initialIndex != nil, "Selected tab \(selected.wrappedValue) not in tabs \(tabs)!")
        
        self._selected = selected
        self._currentTabIndex = .init(wrappedValue: initialIndex ?? 0)
        self.tabs = tabs
        self.dividers = withDividers
        self.label = label
        self.value = value
        self._sizes = .init(wrappedValue: .init(repeating: .init(width: .zero, offset: .zero), count: tabs.indices.count))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if dividers.contains(.top) {
                Divider()
            }
            
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal) {
                    buttonStack(scrollProxy: scrollProxy, isSelected: false)
                        .overlay {
                            buttonStack(isSelected: true)
                                .background(palette.accent)
                                .allowsHitTesting(false)
                                .mask(alignment: .leading) {
                                    // This `if` statement prevents the size of the capsule animating from 0 to `width` when transitioning in
                                    if sizes[currentTabIndex].width != 0 {
                                        Capsule()
                                            .offset(x: sizes[currentTabIndex].offset + Constants.main.standardSpacing)
                                            .frame(width: max(sizes[currentTabIndex].width - AppConstants.doubleSpacing, 0), height: 30)
                                    } else {
                                        Color.clear
                                    }
                                }
                        }
                        .coordinateSpace(name: spaceName)
                }
                .scrollIndicators(.hidden)
                .onChange(of: selected) {
                    let newIndex = tabs.firstIndex(of: selected) ?? 0
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
    }
    
    /// Builds the HStack containing the actual buttons
    /// - Parameter scrollProxy: scrollProxy to handle scrolling horizontally to the selected view. If present, the stack will create buttons and apply a ChildSizeReader to them to populate the size information for the masking; otherwise the stack will use inert labels.
    @ViewBuilder
    func buttonStack(
        scrollProxy: ScrollViewProxy? = nil,
        isSelected: Bool
    ) -> some View {
        // Use negative spacing as well as padding the HStack's children so that scrollTo leaves extra space around each tab
        HStack(spacing: -AppConstants.doubleSpacing) {
            ForEach(Array(zip(tabs.indices, tabs)), id: \.0) { index, tab in
                if let scrollProxy {
                    ChildSizeReader(sizes: $sizes, index: index, spaceName: spaceName) {
                        bubbleButton(
                            index: index,
                            tab: tab,
                            scrollProxy: scrollProxy,
                            isSelected: isSelected
                        )
                    }
                } else {
                    bubbleButtonLabel(tab: tab, isSelected: isSelected)
                }
            }
        }
    }
    
    @ViewBuilder
    func bubbleButton(
        index: Int,
        tab: Value,
        scrollProxy: ScrollViewProxy,
        isSelected: Bool
    ) -> some View {
        Button {
            selected = tab
            HapticManager.main.play(haptic: .gentleInfo, priority: .low)
        } label: {
            bubbleButtonLabel(tab: tab, isSelected: isSelected)
        }
        .buttonStyle(EmptyButtonStyle())
        .id(index)
    }
    
    @ViewBuilder
    func bubbleButtonLabel(
        tab: Value,
        isSelected: Bool
    ) -> some View {
        AnyView(HStack(spacing: 8) {
            let value = value(tab)
            Text(label(tab))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? palette.selectedInteractionBarItem : palette.primary)
            if let value {
                Text(value.abbreviated)
                    .monospacedDigit()
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? palette.selectedInteractionBarItem.opacity(0.8) : palette.secondary)
            }
        })
        .padding(.horizontal, 22)
        .frame(minHeight: 50)
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    func bubbleButtonLabel2(
        tab: Value,
        isSelected: Bool
    ) -> some View {
        AnyView(HStack {
            let value = value(tab)
            Text(label(tab))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : palette.primary)
            if let value {
                Text(value.abbreviated)
                    .monospacedDigit()
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : palette.secondary)
                    .padding(.horizontal, 5)
                    .frame(minWidth: 22)
                    .frame(height: 22)
                    .background(
                        Group {
                            if value < 10 {
                                Circle()
                            } else {
                                Capsule()
                            }
                        }
                        .foregroundStyle(
                            isSelected ? palette.background.opacity(0.3) : palette.secondaryBackground
                        )
                    )
            }
        })
        .padding(.horizontal, 22)
        .frame(minHeight: 50)
        .contentShape(Rectangle())
    }
}

// #Preview {
//    @State var selected: InstanceViewTab = .administration
//    return BubblePicker(
//        InstanceViewTab.allCases,
//        selected: $selected,
//        label: { $0.label },
//        value: { item in
//            switch item {
//            case .about:
//                0
//            case .administration:
//                5
//            case .details:
//                9_950_000
//            case .uptime:
//                10_000_000
//            default:
//                nil
//            }
//        }
//    )
// }
