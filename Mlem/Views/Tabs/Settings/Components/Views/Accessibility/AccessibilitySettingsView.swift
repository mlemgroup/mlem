//
//  AccessibilitySettingsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-02.
//

import Foundation
import SwiftUI

struct AccessibilitySettingsView: View {
    @AppStorage("reakMarkStyle") var readMarkStyle: ReadMarkStyle = .bar
    @AppStorage("readBarThickness") var readBarThickness: Int = 3
    @AppStorage("hasTranslucentInsets") var hasTranslucentInsets: Bool = true
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var readBarThicknessSlider: CGFloat = 3.0
    
    var body: some View {
        List {
            Section {
                SelectableSettingsItem(
                    settingIconSystemName: "book",
                    settingName: "Read Post Indicator",
                    currentValue: $readMarkStyle,
                    options: ReadMarkStyle.allCases
                )
                
                VStack(alignment: .leading) {
                    HStack {
                        Label {
                            Text("Bar Thickness")
                        } icon: {
                            Image(systemName: "rectangle.leftthird.inset.filled")
                                .foregroundColor(.pink)
                                .opacity(readMarkStyle == .bar ? 1 : 0.4)
                        }
                        
                        Spacer()
                        
                        Text(String(format: "%.0f", readBarThicknessSlider))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Slider(
                        value: $readBarThicknessSlider,
                        in: 1 ... 5,
                        step: 1
                    ) {
                        Text("Bar Thickness")
                    } minimumValueLabel: {
                        Text("1")
                    } maximumValueLabel: {
                        Text("5")
                    } onEditingChanged: { editing in
                        if !editing {
                            readBarThickness = Int(readBarThicknessSlider)
                        }
                    }
                    .disabled(readMarkStyle != .bar)
                }
                .foregroundColor(readMarkStyle == .bar ? .primary : .secondary)
            } header: {
                Text("Differentiate Without Color")
            } footer: {
                Text("Configure how this app behaves when the system \"differentiate without color\" option is on.")
            }
            
            Section {
                SwitchableSettingsItem(
                    settingPictureSystemName: AppConstants.transparencySymbolName,
                    settingName: "Translucent Insets",
                    isTicked: $hasTranslucentInsets
                )
            } header: {
                Text("Transparency")
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Accessibility")
        .navigationBarColor()
        .hoistNavigation(dismiss: dismiss)
    }
}
