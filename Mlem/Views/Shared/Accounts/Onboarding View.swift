//
//  Onboarding View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-15.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
    enum OnboardingTab {
        case welcome, about, instances, addAccount
    }
    
    @Binding var flow: AppFlow
    
    @State var selectedTab: OnboardingTab = .welcome
    @State var hideNav: Bool = true
    
    @State var selectedInstance: InstanceMetadata?
    
    var body: some View {
        TabView(selection: $selectedTab) {
            onboardingTab
                .tag(OnboardingTab.welcome)
            
            aboutTab
                .tag(OnboardingTab.about)
            
            instancesTab
                .tag(OnboardingTab.instances)
            
            AddSavedInstanceView(onboarding: true, givenInstance: selectedInstance?.url.absoluteString)
                .tag(OnboardingTab.addAccount)
        }
        .onChange(of: selectedInstance) { _ in
            selectedTab = .addAccount
        }
        .animation(.spring(response: 0.5), value: selectedTab)
        .tabViewStyle(PageTabViewStyle())
    }
    
    // MARK: - Onboarding Tab
    
    @ViewBuilder
    var onboardingTab: some View {
        VStack(spacing: 40) {
            Text("Welcome to Mlem!")
                .bold()
            
            LogoView()
            
            VStack {
                newUserButton
                existingUserButton
            }
        }
        .padding(.horizontal)
        .frame(maxHeight: .infinity)
    }
    
    @ViewBuilder
    var newUserButton: some View {
        Button {
            selectedTab = .about
        } label: {
            Text("I'm new here")
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
    }
    
    @ViewBuilder
    var existingUserButton: some View {
        Button {
            selectedTab = .addAccount
        } label: {
            Text("I have a Lemmy account")
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
    }
    
    // MARK: - About Tab
    
    @ViewBuilder
    var aboutTab: some View {
        ScrollView {
            VStack(spacing: 40) {
                Group {
                    Text("What is Lemmy?")
                        .bold()
                    
                    Text(.init(whatIsLemmy))
                }
                .padding()
                
                VStack(spacing: 0) {
                    Divider()
                    
                    CollapsibleTextItem(
                        titleText: "About Lemmy",
                        bodyText: aboutLemmy
                    )
                    .padding(.horizontal)
                    
                    Divider()
                    
                    CollapsibleTextItem(
                        titleText: "About Instances and Federation",
                        bodyText: aboutInstances
                    )
                    .padding(.horizontal)
                    
                    Divider()
                }
                
                Spacer()
                
                onboardingNextButton
                    .padding()
                
                // add a little space for the tab selection indicator
                Spacer()
                    .frame(height: 20)
            }
        }
    }
    
    @ViewBuilder
    var onboardingNextButton: some View {
        Button {
            selectedTab = .instances
        } label: {
            Text("Next")
                .padding(5)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
    }
    
    // MARK: - Instances Tab
    
    var instancesTab: some View {
        InstancePickerView(selectedInstance: $selectedInstance, onboarding: true)
    }
}
