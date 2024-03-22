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

struct BubblePicker<Value: Identifiable & Equatable & Hashable>: View {
    @Dependency(\.hapticManager) var hapticManager
    
    @Namespace private var animation
    
    @Binding var selected: Value
    @State var currentIndex: Int = 0
    let tabs: [Value]
    let dividers: Set<DividerPlacement>
    @ViewBuilder let labelBuilder: (Value) -> any View
    
    init(
        _ tabs: [Value],
        selected: Binding<Value>,
        withDividers: Set<DividerPlacement> = .init(),
        @ViewBuilder labelBuilder: @escaping (Value) -> any View
    ) {
        self._selected = selected
        self.tabs = tabs
        self.dividers = withDividers
        self.labelBuilder = labelBuilder
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if dividers.contains(.top) {
                Divider()
            }
            
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal) {
                    ZStack {
                        // Use negative spacing as well as padding the HStack's children so that scrollTo leaves extra space around each tab
                        HStack(spacing: -AppConstants.doubleSpacing) {
                            ForEach(Array(zip(tabs.indices, tabs)), id: \.0) { index, tab in
                                bubbleButton(index: index, tab: tab, scrollProxy: scrollProxy)
                            }
                        }
                        
                        // Use negative spacing as well as padding the HStack's children so that scrollTo leaves extra space around each tab
                        HStack(spacing: -AppConstants.doubleSpacing) {
                            ForEach(Array(zip(tabs.indices, tabs)), id: \.0) { index, tab in
                                darkBubbleButton(index: index, tab: tab, scrollProxy: scrollProxy)
                            }
                        }
                    }
//                    .compositingGroup()
//                    .blendMode(.destinationOut)
                }
                .scrollIndicators(.hidden)
            }
            
            if dividers.contains(.bottom) {
                Divider()
            }
        }
    }
    
    @ViewBuilder
    func darkBubbleButton(index: Int, tab: Value, scrollProxy: ScrollViewProxy) -> some View {
        Button {
            selected = tab
            hapticManager.play(haptic: .gentleInfo, priority: .low)
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                currentIndex = index
                scrollProxy.scrollTo(index)
            }
        } label: {
            AnyView(labelBuilder(tab))
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(.blue)
                .font(.subheadline)
                .fontWeight(.semibold)
                .mask {
                    ZStack {
                        Rectangle()
                        
                        if currentIndex == index {
                            Capsule()
                        }
                    }
                    .blendMode(.destinationOut)
                }
                //                .mask(
//                    Group {
//                        if currentIndex == index {
//                            Capsule()
//                                .opacity(0)
//                                .matchedGeometryEffect(id: "bubbleBackground", in: animation)
//                        }
//                    }
//                )
                .padding(AppConstants.standardSpacing)
        }
        .buttonStyle(EmptyButtonStyle())
        .id(index)
    }
    
    @ViewBuilder
    func bubbleButton(index: Int, tab: Value, scrollProxy: ScrollViewProxy) -> some View {
        Button {
            selected = tab
            hapticManager.play(haptic: .gentleInfo, priority: .low)
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                currentIndex = index
                scrollProxy.scrollTo(index)
            }
        } label: {
            AnyView(labelBuilder(tab))
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(Color.systemBackground)
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(AppConstants.standardSpacing)
                .contentShape(Rectangle())
        }
        // .opacity(0.9)
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
