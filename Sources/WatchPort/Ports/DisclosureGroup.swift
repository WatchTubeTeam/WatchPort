//
//  DisclosureGroup.swift
//  WatchPort
//
//  Created by Lakhan Lothiyi on 21/08/2022.
//

import SwiftUI

#if os(watchOS)
@available(watchOS 7.0, *)
public struct DisclosureGroup<Label: View, Content: View>: View {
    @State private var privateIsExpanded: Bool = false
    var isExpanded: Binding<Bool>?
    @ViewBuilder var content: () -> Content
    @ViewBuilder var label: Label

    /// Creates a disclosure group with the given label and content views.
    ///
    /// - Parameters:
    ///   - content: The content shown when the disclosure group expands.
    ///   - label: A view that describes the content of the disclosure group.
    public init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: () -> Label
    ) {
        self.init(isExpanded: nil, content: content, label: label)
    }

    /// Creates a disclosure group with the given label and content views, and
    /// a binding to the expansion state (expanded or collapsed).
    ///
    /// - Parameters:
    ///   - isExpanded: A binding to a Boolean value that determines the group's
    ///    expansion state (expanded or collapsed).
    ///   - content: The content shown when the disclosure group expands.
    ///   - label: A view that describes the content of the disclosure group.
    public init(
        isExpanded: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: () -> Label
    ) {
        self.init(isExpanded: .some(isExpanded), content: content, label: label)
    }

    private init(
        isExpanded: Binding<Bool>? = nil,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: () -> Label
    ) {
        self.isExpanded = isExpanded
        self.content = content
        self.label = label()
    }

    public var body: some View {
        VStack {
            _DisclosureGroup(
                isExpandedBinding: isExpanded ?? $privateIsExpanded,
                content: content
            ) {
                label
            }
        }
    }
}

private struct _DisclosureGroup<Label: View, Content: View>: View {
    @Binding var isExpandedBinding: Bool
    @State var isExpanded: Bool = false
    @State var isExpandedAnim: Bool = false
    @ViewBuilder var content: () -> Content
    @ViewBuilder var label: Label

    @State private var timer: Timer? = nil
    
    var animTime = 0.3
    
    @ViewBuilder
    var body: some View {
        Button {
            isExpandedBinding.toggle()
        } label: {
            HStack {
                label
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isExpandedAnim ? 0 : 90))
            }
        }
        .buttonStyle(.plain)
        .onChange(of: isExpandedBinding) { newValue in
            setState(newValue)
        }
        if isExpanded {
            content()
                .opacity(isExpandedAnim ? 1 : 0)
                .offset(y: isExpandedAnim ? 0 : -20)
        }
    }
    
    func setState(_ state: Bool) {
        if isExpanded {
            withAnimation(.easeInOut(duration: animTime)) {
                isExpandedAnim = state
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
                withAnimation(.easeInOut(duration: animTime)) {
                    isExpanded = isExpandedAnim
                }
            })
        } else {
            withAnimation(.easeInOut(duration: animTime)) {
                isExpanded = state
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
                withAnimation(.easeInOut(duration: animTime)) {
                    isExpandedAnim = isExpanded
                }
            })
        }
    }
}

@available(watchOS 7.0, *)
public extension DisclosureGroup where Label == Text {

    /// Creates a disclosure group, using a provided localized string key to
    /// create a text view for the label.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized label of `self` that describes
    ///     the content of the disclosure group.
    ///   - content: The content shown when the disclosure group expands.
    init(_ titleKey: LocalizedStringKey, @ViewBuilder content: @escaping () -> Content) {
        self.init(content: content) {
            Text(titleKey)
        }
    }

    /// Creates a disclosure group, using a provided localized string key to
    /// create a text view for the label, and a binding to the expansion state
    /// (expanded or collapsed).
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized label of `self` that describes
    ///     the content of the disclosure group.
    ///   - isExpanded: A binding to a Boolean value that determines the group's
    ///    expansion state (expanded or collapsed).
    ///   - content: The content shown when the disclosure group expands.
    init(_ titleKey: LocalizedStringKey, isExpanded: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self.init(isExpanded: isExpanded, content: content) {
            Text(titleKey)
        }
    }

    /// Creates a disclosure group, using a provided string to create a
    /// text view for the label.
    ///
    /// - Parameters:
    ///   - label: A description of the content of the disclosure group.
    ///   - content: The content shown when the disclosure group expands.
    init<S>(_ label: S, @ViewBuilder content: @escaping () -> Content) where S : StringProtocol {
        self.init(content: content) {
            Text(label)
        }
    }

    /// Creates a disclosure group, using a provided string to create a
    /// text view for the label, and a binding to the expansion state (expanded
    /// or collapsed).
    ///
    /// - Parameters:
    ///   - label: A description of the content of the disclosure group.
    ///   - isExpanded: A binding to a Boolean value that determines the group's
    ///    expansion state (expanded or collapsed).
    ///   - content: The content shown when the disclosure group expands.
    init<S>(_ label: S, isExpanded: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) where S : StringProtocol {
        self.init(isExpanded: isExpanded, content: content) {
            Text(label)
        }
    }
}

internal struct DisclosureGroupPreview: View {
    var body: some View {
        DisclosureGroup("Label") {
            Text("Content")
        }
        .foregroundColor(.blue)
    }
}

internal struct _DisclosureGroupPreview: PreviewProvider {
    static var previews: some View {
        DisclosureGroupPreview()
    }
}
#endif
