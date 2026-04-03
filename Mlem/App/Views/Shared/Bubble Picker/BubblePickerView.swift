//
//  BubblePickerView.swift
//  Mlem
//
//  Created by Sjmarf on 18/09/2023.
//

import Dependencies
import Haptics
import SwiftUI

enum DividerPlacement {
    case top, bottom
}

struct BubblePickerItemFrame: Hashable {
    let width: CGFloat
    let offset: CGFloat
    
    static var zero: Self {
        .init(width: 0, offset: 0)
    }
}

struct BubblePicker<Value: Identifiable & Equatable & Hashable>: View {
    @Environment(HapticManager.self) var hapticManager
    @Binding var selected: Value
    
    // currentTabIndex is used to drive the capsule animation; it is tracked separately from selected so that the capsule animations can be triggered independently of any animation (or lack thereof) that is desired on selected
    @State var currentTabIndex: Int
    @State var selectedTabFrame: BubblePickerItemFrame?
    
    let tabs: [Value]
    let dividers: Set<DividerPlacement>
    let label: (Value) -> LocalizedStringResource
    let value: (Value) -> Int?
    let spaceName: String = UUID().uuidString
    
    let animation: Animation = .interactiveSpring(response: 0.2, dampingFraction: 0.8)

    init(
        _ tabs: [Value],
        selected: Binding<Value>,
        withDividers: Set<DividerPlacement> = .init(),
        label: @escaping (Value) -> LocalizedStringResource,
        value: @escaping (Value) -> Int? = { _ in nil }
    ) {
        let initialIndex = tabs.firstIndex(of: selected.wrappedValue)
        
        self._selected = selected
        self._currentTabIndex = .init(wrappedValue: initialIndex ?? 0)
        self.tabs = tabs
        self.dividers = withDividers
        self.label = label
        self.value = value
        
        // gracefully handle cases where selected tab is not found
        if initialIndex == nil {
            Task { @MainActor in
                selected.wrappedValue = tabs[0]
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if dividers.contains(.top) {
                Divider()
            }
            
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal) {
                    buttonStack(scrollProxy: scrollProxy, isSelectionIndicator: false)
                        .overlay {
                            buttonStack(isSelectionIndicator: true)
                                .background(.themedAccent)
                                .allowsHitTesting(false)
                                .mask(alignment: .leading) {
                                    if let selectedTabFrame {
                                        Capsule()
                                            .offset(x: selectedTabFrame.offset + Constants.main.standardSpacing)
                                            .frame(width: max(selectedTabFrame.width - Constants.main.doubleSpacing, 0), height: 30)
                                            .animation(animation, value: selectedTabFrame)
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
                    currentTabIndex = newIndex
                    withAnimation(animation) {
                        scrollProxy.scrollTo(newIndex)
                    }
                }
                .id(tabs.hashValue)
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
        isSelectionIndicator: Bool
    ) -> some View {
        // Use negative spacing as well as padding the HStack's children so that scrollTo leaves extra space around each tab
        HStack(spacing: -Constants.main.doubleSpacing) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                if let scrollProxy {
                    ChildSizeReader(
                        size: tab == selected ? Binding(
                            get: { selectedTabFrame ?? .zero },
                            set: { selectedTabFrame = $0 }
                        ) : nil,
                        spaceName: spaceName
                    ) {
                        bubbleButton(
                            index: index,
                            tab: tab,
                            scrollProxy: scrollProxy,
                            isSelectionIndicator: isSelectionIndicator
                        )
                    }
                    .id("\(isSelectionIndicator)\(value(tab) ?? -1)")
                } else {
                    bubbleButtonLabel(tab: tab, isSelectionIndicator: isSelectionIndicator)
                }
            }
        }
    }
    
    @ViewBuilder
    func bubbleButton(
        index: Int,
        tab: Value,
        scrollProxy: ScrollViewProxy,
        isSelectionIndicator: Bool
    ) -> some View {
        Button {
            selected = tab
            hapticManager.play(haptic: .gentleInfo, tier: .low)
        } label: {
            bubbleButtonLabel(tab: tab, isSelectionIndicator: isSelectionIndicator)
        }
        .buttonStyle(.empty)
        .id(index)
    }
    
    @ViewBuilder
    func bubbleButtonLabel(
        tab: Value,
        isSelectionIndicator: Bool
    ) -> some View {
        AnyView(HStack(spacing: 8) {
            let value = value(tab)
            Text(label(tab))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(isSelectionIndicator ? .themedContrastingLabel : .themedPrimary)
            if let value {
                Text(value.abbreviated)
                    .monospacedDigit()
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(isSelectionIndicator ? .themedContrastingLabel : .themedSecondary)
                    .opacity(isSelectionIndicator ? 0.8 : 1)
            }
        })
        .padding(.horizontal, 22)
        .frame(minHeight: 50)
        .contentShape(.rect)
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
