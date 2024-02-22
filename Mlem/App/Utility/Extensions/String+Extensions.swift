//
//  String+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-12-10.
//

import Foundation

extension String {
    func parseLinks() -> [LinkType] {
        // regex to match raw links not embedded in Markdown
        // (^|[^(\]\()]) ignores anything after a markdown link format (preceded by start of string or anything but '](')
        // (?'link'(http:|https:)+[^\s]+[\w]) matches anything starting with http: or https: and captures it as link
        let rawLinks: [LinkType] = matches(of: /(^|[^(\]\()])(?'link'(http:|https:)+[^\s\[\]]+[\w])/)
            .compactMap { match in
                if let url = URL(string: String(match.link)) {
                    return .website(
                        self.distance(from: self.startIndex, to: match.range.lowerBound),
                        String(url.host() ?? "Website"),
                        url
                    )
                }
                return nil
            }
        
        // regex to match markdown links
        // ([^\!]|^) ensures we ignore image links (matches start of string or anything but !)
        // \[(?'title'[^\[]*)\] matches '[title]' and captures 'title' as title
        // \((?'url'[^\s\)]*)\) matches '(url)' and captures 'url' as url
        let markdownLinks: [LinkType] = matches(of: /(^|[^\!])\[(?'title'[^\[]*)\]\((?'link'[^\s\)]*)\)/)
            .compactMap { match in
                if let url = URL(string: String(match.link)) {
                    // if the label is just the URL that the link points to, ignore it--the raw link parser will capture the same link and display it with the host as url, and this one would be duplicate. If the label URL is different from the target URL, display with label URL as label and target URL as target
                    if let labelUrl = URL(string: String(match.title)), labelUrl == url {
                        return nil
                    }
                    return .website(
                        self.distance(from: self.startIndex, to: match.range.lowerBound),
                        String(match.title), url
                    )
                }
                return nil
            }
        
        // regex to match user links
        // \!(?'name'[^\s]+) matches '!user' and captures 'user' as name
        // \@(?'instance'[^\s(\]\()]+)\] matches '@instance' and captures 'instance' as instance, excluding cases where instance is followed by '](' (suggesting a username embedded in a link)
        // \]?(\s|$) ensures that usernames wrapped in [] that are not part of links get appropriately parsed
        let userLinks: [LinkType] = matches(of: /\@(?'name'[^\s]+)\@(?'instance'[^\s(\]\()]+)\]?(\s|$)/)
            .compactMap { match in
                if let url = URL(string: String(match.output.0)) {
                    return .user(
                        self.distance(from: self.startIndex, to: match.range.lowerBound),
                        String(match.name),
                        String(match.instance),
                        url
                    )
                }
                return nil
            }
        
        // same as above but with \! at the start
        let communityLinks: [LinkType] = matches(of: /\!(?'name'[^\s]+)\@(?'instance'[^\s(\]\()]+)\]?(\s|$)/)
            .compactMap { match in
                if let url = URL(string: String(match.output.0)) {
                    return .community(
                        self.distance(from: self.startIndex, to: match.range.lowerBound),
                        String(match.name),
                        String(match.instance),
                        url
                    )
                }
                return nil
            }
        
        // sort links by position in body and return
        return (rawLinks + markdownLinks + userLinks + communityLinks).sorted { $0.position < $1.position }
    }
}

extension String {
    func contains(_ strings: [String]) -> Bool {
        strings.contains { contains($0) }
    }
}
