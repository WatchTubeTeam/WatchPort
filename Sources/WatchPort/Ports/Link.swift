//
//  Link.swift
//  
//
//  Created by Lakhan Lothiyi on 15/10/2022.
//

import Foundation
import SwiftUI

#if os(watchOS)
public struct Link<Label> : View where Label : View {
    
    // Definitions
    var destination: URL
    var label: () -> Label
    
    @State private var isOpen = false
    
    /// Creates a control, consisting of a URL and a label, used to navigate
    /// to the given URL.
    ///
    /// - Parameters:
    ///     - destination: The URL for the link.
    ///     - label: A view that describes the destination of URL.
    public init(destination: URL, @ViewBuilder label: @escaping () -> Label) {
        self.destination = destination
        self.label = label
    }
    
    /// The content and behavior of the view.
    ///
    /// When you implement a custom view, you must implement a computed
    /// `body` property to provide the content for your view. Return a view
    /// that's composed of built-in views that SwiftUI provides, plus other
    /// composite views that you've already defined:
    ///
    ///     struct MyView: View {
    ///         var body: some View {
    ///             Text("Hello, World!")
    ///         }
    ///     }
    ///
    /// For more information about composing views and a view hierarchy,
    /// see <doc:Declaring-a-Custom-View>.
    @MainActor public var body: some View {
        Button {
            openPage()
        } label: {
            self.label()
        }
        .disabled(isOpen)
    }
    
    private func openPage() {
        Task {
            isOpen = true
            await WKExtension.shared().openURL(self.destination)
            isOpen = false
        }
    }
}

extension Link where Label == Text {
    
    /// Creates a control, consisting of a URL and a title key, used to
    /// navigate to a URL.
    ///
    /// Use ``Link`` to create a control that your app uses to navigate to a
    /// URL that you provide. The example below creates a link to
    /// `example.com` and uses `Visit Example Co` as the title key to
    /// generate a link-styled view in your app:
    ///
    ///     Link("Visit Example Co",
    ///           destination: URL(string: "https://www.example.com/")!)
    ///
    /// - Parameters:
    ///     - titleKey: The key for the localized title that describes the
    ///       purpose of this link.
    ///     - destination: The URL for the link.
    public init(_ titleKey: LocalizedStringKey, destination: URL) {
        self.init(destination: destination) {
            Text(titleKey)
        }
    }
    
    /// Creates a control, consisting of a URL and a title string, used to
    /// navigate to a URL.
    ///
    /// Use ``Link`` to create a control that your app uses to navigate to a
    /// URL that you provide. The example below creates a link to
    /// `example.com` and displays the title string you provide as a
    /// link-styled view in your app:
    ///
    ///     func marketingLink(_ callToAction: String) -> Link {
    ///         Link(callToAction,
    ///             destination: URL(string: "https://www.example.com/")!)
    ///     }
    ///
    /// - Parameters:
    ///     - title: A text string used as the title for describing the
    ///       underlying `destination` URL.
    ///     - destination: The URL for the link.
    public init<S>(_ title: S, destination: URL) where S : StringProtocol {
        self.init(destination: destination) {
            Text(title)
        }
    }
}

import AuthenticationServices
extension WKExtension {
    func openURL(_ url: URL) async {
        return await withCheckedContinuation({ (continuation: CheckedContinuation) in
            var session = ASWebAuthenticationSession(url: url, callbackURLScheme: "") { _, _ in
                continuation.resume(returning: ())
            }
            session.prefersEphemeralWebBrowserSession = true
            session.start()
        })
    }
}




struct linkTest: PreviewProvider {
    static var previews: some View {
        Link(destination: URL(string: "https://google.com")!) {
            Text("gm")
        }
    }
}
#endif
