//
// This code taken from the open-source SwiftUIX library. https://github.com/SwiftUIX/SwiftUIX/blob/master/Sources/Intramodular/Search%20Bar/SearchBar%2BNavigationView.swift
//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if (os(iOS) && canImport(CoreTelephony)) || targetEnvironment(macCatalyst)

    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    private struct _NavigationSearchBarConfigurator<SearchResultsContent: View>: UIViewControllerRepresentable {
        let searchBar: SearchBar
        let searchResultsContent: () -> SearchResultsContent
    
        @Environment(\._hidesNavigationSearchBarWhenScrolling) var hidesSearchBarWhenScrolling: Bool?
    
        var automaticallyShowSearchBar: Bool? = true
        var hideNavigationBarDuringPresentation: Bool?
        var obscuresBackgroundDuringPresentation: Bool?
    
        func makeUIViewController(context: Context) -> UIViewControllerType {
            UIViewControllerType(coordinator: context.coordinator)
        }
    
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            context.coordinator.base = self
            context.coordinator.searchBarCoordinator.base = searchBar

            searchBar._updateUISearchBar(context.coordinator.searchController.searchBar, environment: context.environment)
        }
    
        func makeCoordinator() -> Coordinator {
            Coordinator(base: self, searchBarCoordinator: .init(base: searchBar))
        }
    }

    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    extension _NavigationSearchBarConfigurator {
        fileprivate class SearchController: UISearchController {
            private var customSearchBar: UISearchBar?
        
            override var searchBar: UISearchBar {
                if let customSearchBar {
                    return customSearchBar
                } else {
                    customSearchBar = UISearchBar(frame: .zero)
                    return customSearchBar!
                }
            }
        
            override init(
                searchResultsController: UIViewController?
            ) {
                super.init(searchResultsController: searchResultsController)
            }
        
            @available(*, unavailable)
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
    
        class Coordinator: NSObject, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
            fileprivate var base: _NavigationSearchBarConfigurator
            fileprivate var searchBarCoordinator: SearchBar.Coordinator
            fileprivate var searchController: SearchController!
        
            fileprivate weak var uiViewController: UIViewController? {
                didSet {
                    if uiViewController == nil || uiViewController != oldValue {
                        if oldValue?.searchController != nil {
                            oldValue?.searchController = nil
                        }
                    }
                
                    updateSearchController()
                }
            }
        
            fileprivate init(
                base: _NavigationSearchBarConfigurator,
                searchBarCoordinator: SearchBar.Coordinator
            ) {
                self.base = base
                self.searchBarCoordinator = searchBarCoordinator
            
                super.init()
            
                initializeSearchController()
                updateSearchController()
            }
        
            private func initializeSearchController() {
                let searchResultsController: UIViewController?
                let searchResultsContent = base.searchResultsContent()
            
                if searchResultsContent is EmptyView {
                    searchResultsController = nil
                } else {
                    searchResultsController = UIHostingController<SearchResultsContent>(rootView: base.searchResultsContent())
                }
            
                searchController = SearchController(
                    searchResultsController: searchResultsController
                )
                searchController.definesPresentationContext = true
                searchController.obscuresBackgroundDuringPresentation = false
                searchController.searchBar.delegate = self
                searchController.searchResultsUpdater = self
            }
        
            private func updateSearchController() {
                guard let uiViewController else {
                    return
                }
            
                if uiViewController.searchController !== searchController {
                    uiViewController.searchController = searchController
                }
            
                if let obscuresBackgroundDuringPresentation = base.obscuresBackgroundDuringPresentation {
                    searchController.obscuresBackgroundDuringPresentation = obscuresBackgroundDuringPresentation
                } else {
                    searchController.obscuresBackgroundDuringPresentation = false
                }
            
                if let hideNavigationBarDuringPresentation = base.hideNavigationBarDuringPresentation {
                    searchController.hidesNavigationBarDuringPresentation = hideNavigationBarDuringPresentation
                }
            
                (
                    searchController.searchResultsController as? UIHostingController<SearchResultsContent>
                )?.rootView = base.searchResultsContent()
            
                if let hidesSearchBarWhenScrolling = base.hidesSearchBarWhenScrolling {
                    uiViewController.hidesSearchBarWhenScrolling = hidesSearchBarWhenScrolling
                }
            
                if let automaticallyShowSearchBar = base.automaticallyShowSearchBar, automaticallyShowSearchBar {
                    uiViewController.sizeToFitSearchBar()
                }
            }
        
            // MARK: - UISearchBarDelegate
        
            public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
                searchBarCoordinator.searchBarTextDidBeginEditing(searchBar)
            }
        
            public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
                searchBarCoordinator.searchBar(searchBar, textDidChange: searchText)
            }
        
            public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
                searchBarCoordinator.searchBarTextDidEndEditing(searchBar)
            }
        
            public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
                searchController.isActive = false

                searchBarCoordinator.searchBarCancelButtonClicked(searchBar)
            }
        
            public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
                searchBarCoordinator.searchBarSearchButtonClicked(searchBar)
            }
        
            // MARK: UISearchControllerDelegate
        
            func willPresentSearchController(_ searchController: UISearchController) {}
        
            func didPresentSearchController(_ searchController: UISearchController) {}
        
            func willDismissSearchController(_ searchController: UISearchController) {}
        
            func didDismissSearchController(_ searchController: UISearchController) {}
        
            // MARK: UISearchResultsUpdating
        
            func updateSearchResults(for searchController: UISearchController) {}
        }
    
        class UIViewControllerType: UIViewController {
            weak var coordinator: Coordinator?
        
            init(coordinator: Coordinator?) {
                self.coordinator = coordinator
            
                super.init(nibName: nil, bundle: nil)
            }
        
            @available(*, unavailable)
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        
            override func willMove(toParent parent: UIViewController?) {
                super.willMove(toParent: parent)
            
                coordinator?.uiViewController = navigationController?.viewControllers.first
            }
        
            override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
            
                coordinator?.uiViewController = navigationController?.viewControllers.first
            }
        }
    }

    // MARK: - API

    public extension View {
        /// Sets the navigation search bar for this view.
        @available(macCatalystApplicationExtension, unavailable)
        @available(iOSApplicationExtension, unavailable)
        @available(tvOSApplicationExtension, unavailable)
        func navigationSearchBar(_ searchBar: () -> SearchBar) -> some View {
            background(_NavigationSearchBarConfigurator(searchBar: searchBar(), searchResultsContent: { EmptyView() }))
        }
    
        /// Hides the integrated search bar when scrolling any underlying content.
        func navigationSearchBarHiddenWhenScrolling(_ hidesSearchBarWhenScrolling: Bool) -> some View {
            environment(\._hidesNavigationSearchBarWhenScrolling, hidesSearchBarWhenScrolling)
        }
    }

    private class DefaultEnvironmentKey<Value>: EnvironmentKey {
        public static var defaultValue: Value? {
            nil
        }
    }

    // MARK: - Auxiliary

    extension EnvironmentValues {
        private class _HidesNavigationSearchBarWhenScrolling: DefaultEnvironmentKey<Bool> {}
    
        var _hidesNavigationSearchBarWhenScrolling: Bool? {
            get {
                self[_HidesNavigationSearchBarWhenScrolling.self]
            } set {
                self[_HidesNavigationSearchBarWhenScrolling.self] = newValue
            }
        }
    }

    // MARK: - Helpers

    private extension UIViewController {
        var searchController: UISearchController? {
            get {
                navigationItem.searchController
            } set {
                navigationItem.searchController = newValue
            }
        }
    
        var hidesSearchBarWhenScrolling: Bool {
            get {
                navigationItem.hidesSearchBarWhenScrolling
            } set {
                navigationItem.hidesSearchBarWhenScrolling = newValue
            }
        }
    
        func sizeToFitSearchBar() {
            navigationController?.navigationBar.sizeToFit()
        }
    }

#endif
