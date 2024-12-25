//
//  AccessibilitySettingsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-25.
//

import SwiftUI

struct AccessibilitySettingsView: View {
    
    @Setting(\.readPostIndicator) var readPostIndicator
    @Setting(\.readOutlineThickness) var readOutlineThickness
    
    @State var readBarThicknessSlider: Double
    
    init() {
        @Setting(\.readOutlineThickness) var readOutlineThickness
        self._readBarThicknessSlider = .init(wrappedValue: Double(readOutlineThickness))
    }
    
    var body: some View {
        List {
            Section("Differentiate Without Color") {
                Picker("Read Post Indicator", selection: $readPostIndicator) {
                    ForEach(ReadPostIndicator.allCases, id: \.self) { item in
                        Text(item.label)
                    }
                }
                
                if readPostIndicator == .outline {
                    VStack(alignment: .leading) {
                        Text("Outline Thickness")
                        
                        Slider(
                            value: $readBarThicknessSlider,
                            in: 1 ... 5,
                            step: 1
                        ) {
                            Text("Outline Thickness")
                        } minimumValueLabel: {
                            Text("1")
                        } maximumValueLabel: {
                            Text("5")
                        } onEditingChanged: { editing in
                            if !editing {
                                readOutlineThickness = Int(readBarThicknessSlider)
                            }
                        }
                    }
                }
            }
        }
    }
}
