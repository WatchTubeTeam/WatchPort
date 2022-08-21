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
        sliderTest()
    }
}

@available(watchOS 8.0, *)
struct sliderTest: View {
    @State var r: CGFloat = 1
    @State var g: CGFloat = 0.2
    @State var b: CGFloat = 0.9
    @State var a: CGFloat = 1
    
    var body: some View {
        VStack {
            ColorSlider(r: $r, g: $g, b: $b, a: $a, controls: .r)
            ColorSlider(r: $r, g: $g, b: $b, a: $a, controls: .g)
            ColorSlider(r: $r, g: $g, b: $b, a: $a, controls: .b)
            ColorSlider(r: $r, g: $g, b: $b, a: $a, controls: .a)
        }
    }
}

@available(watchOS 8.0, *)
public struct ColorSlider: View {
    @State var width: CGFloat = 0
    @State var offset: CGFloat = 0
    @State var lastStoredOffset: CGFloat = 0
    
    @GestureState var gestureOffset: CGFloat = 0
    
    @Binding var r: CGFloat
    @Binding var g: CGFloat
    @Binding var b: CGFloat
    @Binding var a: CGFloat
    var controls: rgba
    
    public var body: some View {
        ZStack {
            GeometryReader { geo in
                Capsule()
                    .fill(
                        LinearGradient(gradient: Gradient(colors: lineGradient), startPoint: .leading, endPoint: .trailing)
                    )
                    .onAppear {
                        width = geo.size.width
                    }
            }
            Circle()
                .strokeBorder(.white, lineWidth: 2, antialiased: false)
                .padding(2)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .updating($gestureOffset,
                                  body: { value, out, _ in
                                      out = value.translation.width
                                  }
                                 )
                        .onEnded(onEnd(value: ))
                )
                .onChange(of: gestureOffset) { newValue in
                    onChange()
                }
            Text("\(offset)")
        }
        .frame(maxWidth: .infinity, maxHeight: 40)
    }
    
    func onChange() {
        let idk = width / 2.5
        offset = (gestureOffset != 0) ? (gestureOffset + lastStoredOffset < idk ? gestureOffset + lastStoredOffset : offset) : (gestureOffset + lastStoredOffset > -idk ? gestureOffset + lastStoredOffset : offset)
    }
    
    func onEnd(value: DragGesture.Value) {
        lastStoredOffset = offset
    }
    
    var lineGradient: [Color] {
        switch controls {
        case .r:
            return [
                Color(cgColor: CGColor(red: 0, green: g, blue: b, alpha: 1)),
                Color(cgColor: CGColor(red: 1, green: g, blue: b, alpha: 1))
            ]
        case .g:
            return [
                Color(cgColor: CGColor(red: r, green: 0, blue: b, alpha: 1)),
                Color(cgColor: CGColor(red: r, green: 1, blue: b, alpha: 1))
            ]
        case .b:
            return [
                Color(cgColor: CGColor(red: r, green: g, blue: 0, alpha: 1)),
                Color(cgColor: CGColor(red: r, green: g, blue: 1, alpha: 1))
            ]
        case .a:
            return [
                Color(cgColor: CGColor(red: r, green: g, blue: b, alpha: 0)),
                Color(cgColor: CGColor(red: r, green: g, blue: b, alpha: 1))
            ]
        }
    }
}

enum rgba {
    case r
    case g
    case b
    case a
}

func getBounds() -> CGRect { return WKInterfaceDevice.current().screenBounds }
