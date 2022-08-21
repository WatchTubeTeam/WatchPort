//
//  ColorPicker.swift
//  WatchPort
//
//  Created by Lakhan Lothiyi on 21/08/2022.
//

import SwiftUI

@available(watchOS 8.0, *)
public struct ColorPicker<Label: View>: View {
    
    @Binding var selection: CGColor
    @ViewBuilder var label: Label
    var supportsOpacity: Bool
    
    public init(selection: Binding<CGColor>, supportsOpacity: Bool, @ViewBuilder label: () -> Label) {
        self._selection = selection
        self.supportsOpacity = supportsOpacity
        self.label = label()
    }
    
    public var body: some View {
        HStack {
            label
            Spacer()
            button
        }
    }
    
    @State private var editSheetShown = false
    @State private var colorEdited: CGColor? = nil
    @ViewBuilder
    private var button: some View {
        Button {
            colorEdited = selection
            editSheetShown.toggle()
        } label: {
            let size: CGFloat = 25
            Circle()
                .strokeBorder(
                    AngularGradient(gradient: Gradient(colors: [.red, .purple, .blue, .green, .yellow, .red]), center: .center, startAngle: .zero, endAngle: .degrees(360)),
                    lineWidth: 3
                )
                .overlay(content: {
                    Circle()
                        .strokeBorder(.black, lineWidth: 1)
                        .background(Circle().fill(Color(cgColor: selection)))
                        .padding(4)
                })
                .frame(maxWidth: size, maxHeight: size)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $editSheetShown) { // on close
            selection = colorEdited!
            colorEdited = nil
        } content: {
            editSheet
        }

    }
    
    @State var tab: String = "Sliders"
    
    @ViewBuilder
    private var editSheet: some View {
        TabView(selection: $tab) {
            editorGrid
                .tag("Grid")
            editorSliders
                .tag("Sliders")
        }
        .navigationTitle(tab)
    }
    
    @ViewBuilder
    private var editorGrid: some View {
        ScrollView {
            VStack {
                Text("eta s0n")
                
                Button("Done") {
                    editSheetShown.toggle()
                }
                .clipShape(Capsule())
            }
        }
    }
    
    @State private var r: CGFloat = 0
    @State private var g: CGFloat = 0
    @State private var b: CGFloat = 0
    @State private var a: CGFloat = 1
    
    @ViewBuilder
    private var editorSliders: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("RED")
                    .padding(.leading)
                    .font(.footnote.bold())
                Slider(value: $r.animation(.easeInOut), in: 0...1)
                    .tint(.red)
                Text("GREEN")
                    .padding(.leading)
                    .font(.footnote.bold())
                Slider(value: $g.animation(.easeInOut), in: 0...1)
                    .tint(.green)
                Text("BLUE")
                    .padding(.leading)
                    .font(.footnote.bold())
                Slider(value: $b.animation(.easeInOut), in: 0...1)
                    .tint(.blue)
                
                Button("Done") {
                    editSheetShown.toggle()
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background{
                    Rectangle()
                        .foregroundColor(Color(cgColor: CGColor(red: r, green: g, blue: b, alpha: a)))
                }
                .clipShape(Capsule())
            }
        }
        .onAppear {
            let color = UIColor(cgColor: selection)
            r = color.rgba.red
            g = color.rgba.green
            b = color.rgba.blue
        }
        .onDisappear {
            selection = CGColor(red: r, green: g, blue: b, alpha: a)
        }
    }
}

fileprivate extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
}

@available(watchOS 8.0, *)
internal struct ColorPickerPreview: View {
    @State var color = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
    var body: some View {
        ColorPicker(selection: $color, supportsOpacity: true) {
            Text("Label")
        }
    }
}

@available(watchOS 8.0, *)
internal struct _ColorPickerPreview: PreviewProvider {
    static var previews: some View {
        ColorPickerPreview()
    }
}
