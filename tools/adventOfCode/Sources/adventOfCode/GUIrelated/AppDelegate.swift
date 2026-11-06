//         FILE: AppDelegate.swift
//  DESCRIPTION: mng - ---
//        NOTES: ---
//       AUTHOR: Mark T. Johnson, markj@matzsoft.com
//    COPYRIGHT: © 2026 MATZ Software & Consulting. All rights reserved.
//      VERSION: 1.0
//      CREATED: 7/15/26 2:10 PM

import Foundation
import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var window: NSWindow!
    let data: SolutionDisplayResults

    init( data: SolutionDisplayResults ) {
        self.data = data
        super.init()
    }

    func applicationDidFinishLaunching( _ notification: Notification ) {
        // Create the hosting container first so we can read its parameters
        let hostingView = NSHostingView( rootView: ResultsView( data: data ) )
        
        // 💡 Inform the hosting controller to push its ideal SwiftUI size limits up to AppKit
        hostingView.sizingOptions = [NSHostingSizingOptions.intrinsicContentSize, .minSize, .maxSize]
        
        // 💡 Calculate the ideal window size needed by the child SwiftUI content layout
        let idealSize = hostingView.fittingSize
        
        // Create the window matching the layout size calculated above
        window = NSWindow(
            contentRect: NSRect( origin: .zero, size: idealSize ),
            styleMask: [.titled, .closable, .miniaturizable], // Removed resizable to clamp dimensions to content
            backing: .buffered,
            defer: false
        )
        
        window.title = "Advent of Code Status for \(data.year)"
        window.delegate = self
        window.contentView = hostingView
        
        // Finalize layout constraints
        window.layoutIfNeeded()

        // Bring the window to the front and focus it
        window.center()
        window.makeKeyAndOrderFront( nil )
        NSApp.activate( ignoringOtherApps: true )
    }
    
    // Ensure the command line tool exits completely when the window is closed
    func windowWillClose( _ notification: Notification ) {
        NSApp.terminate( nil )
    }
}
