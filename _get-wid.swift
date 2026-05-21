// Helper: print the CGWindow ID of the MAIN editor window for a given app
// owner. JUCE Standalones spawn several invisible 1728×33 stub windows
// alongside the real editor — we filter those out by minimum size.
//
// Usage:   swift _get-wid.swift "Stupid Simple Delay"
//          → prints the window ID, e.g. "6703"

import Cocoa

guard CommandLine.arguments.count > 1 else {
    FileHandle.standardError.write("usage: _get-wid.swift <owner-name>\n".data(using: .utf8)!)
    exit(2)
}
let target = CommandLine.arguments[1]

guard let infos = CGWindowListCopyWindowInfo([.optionAll, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] else {
    exit(1)
}

// Score each candidate: matching name with the owner is the strongest
// signal, then largest area wins among the rest.
var best: (id: Int, score: Int)? = nil

for w in infos {
    let owner = (w[kCGWindowOwnerName as String] as? String) ?? ""
    guard owner == target else { continue }

    let layer = (w[kCGWindowLayer as String] as? Int) ?? 1
    guard layer == 0 else { continue }

    guard let bounds = w[kCGWindowBounds as String] as? [String: Any],
          let h = bounds["Height"] as? CGFloat,
          let width = bounds["Width"] as? CGFloat else { continue }

    // JUCE plugin editors are typically 400+ wide and 300+ tall. Stub windows are 1728×33.
    guard h > 200, width > 300 else { continue }

    guard let wid = w[kCGWindowNumber as String] as? Int else { continue }

    let name = (w[kCGWindowName as String] as? String) ?? ""
    let nameMatchBonus = (name == target) ? 1_000_000 : 0
    let area = Int(h * width)
    let score = nameMatchBonus + area

    if best == nil || score > best!.score {
        best = (wid, score)
    }
}

if let b = best {
    print(b.id)
    exit(0)
}
exit(1)
