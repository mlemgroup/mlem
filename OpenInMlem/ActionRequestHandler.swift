//
//  ActionRequestHandler.swift
//  OpenInMlem
//
//  Created by Bedir Ekim on 2026-02-20.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {

    var extensionContext: NSExtensionContext?

    func beginRequest(with context: NSExtensionContext) {
        extensionContext = context

        guard let inputItems = context.inputItems as? [NSExtensionItem] else {
            done(nil)
            return
        }

        for item in inputItems {
            for provider in item.attachments ?? [] where provider.hasItemConformingToTypeIdentifier(UTType.propertyList.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.propertyList.identifier, options: nil) { item, _ in
                    guard let dictionary = item as? [String: Any],
                          let results = dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? [String: Any],
                          let urlString = results["url"] as? String,
                          var components = URLComponents(string: urlString) else {
                        self.done(nil)
                        return
                    }
                    components.scheme = "mlem"
                    guard let deeplink = components.url?.absoluteString else {
                        self.done(nil)
                        return
                    }
                    OperationQueue.main.addOperation {
                        self.done(["deeplink": deeplink])
                    }
                }
                return
            }
        }

        done(nil)
    }

    private func done(_ resultsForJS: [String: Any]?) {
        if let resultsForJS {
            let dictionary = [NSExtensionJavaScriptFinalizeArgumentKey: resultsForJS]
            let provider = NSItemProvider(item: dictionary as NSDictionary, typeIdentifier: UTType.propertyList.identifier)
            let item = NSExtensionItem()
            item.attachments = [provider]
            extensionContext?.completeRequest(returningItems: [item])
        } else {
            extensionContext?.completeRequest(returningItems: [])
        }
        extensionContext = nil
    }
}
