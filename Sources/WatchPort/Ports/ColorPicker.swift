//
//  ColorPicker.swift
//  WatchPort
//
//  Created by Lakhan Lothiyi on 21/08/2022.
//  Co-authored by Arkadiusz Fal
//

import SwiftUI

#if os(watchOS)
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
    @State var r: CGFloat = 0
    @State var g: CGFloat = 0
    @State var b: CGFloat = 0
    @State var a: CGFloat = 1
    
    var body: some View {
        VStack {
            ColorSlider(r: $r, g: $g, b: $b, a: $a, controls: .r)
            ColorSlider(r: $r, g: $g, b: $b, a: $a, controls: .g)
            ColorSlider(r: $r, g: $g, b: $b, a: $a, controls: .b)
            ColorSlider(r: $r, g: $g, b: $b, a: $a, controls: .a)

            Rectangle()
                .border(.white, width: 1)
                .foregroundColor(Color(red: r, green: g, blue: b, opacity: a))
                .frame(maxWidth: 50)
        }
    }
}

@available(watchOS 8.0, *)
public struct ColorSlider: View {
    static let sliderSize = 25.0

    @State var width: CGFloat = 0
    @State var lastStoredOffset: CGFloat = 0

    @GestureState var dragging = false
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
                .strokeBorder(dragging ? .gray : .white, lineWidth: 2, antialiased: false)
                .frame(height: Self.sliderSize)
                .offset(x: thumbOffset)
            Text("\(thumbValue)")
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .onAppear(perform: setInitialValue)
        // putting gesture here so you can drag on entire width, not just the thumb
        .gesture(
            DragGesture()
                .updating($gestureOffset) { value, out, _ in
                    let offset = value.translation.width
                    let newOffset = lastStoredOffset + offset

                    // check if new offset does not go outside bounds of where you can drag
                    guard newOffset >= 0, newOffset <= maxOffset else { return }

                    // same for the value
                    let newValue = newOffset / maxOffset
                    guard (0.0...1.0).contains(newValue) else { return }

                    out = offset
                    updateControlledValue()
                }
                .updating($dragging) { _, state, _ in state = true }
                .onEnded(onEnd(value: ))
        )
    }

    func setInitialValue() {
        switch controls {
        case .r:
            lastStoredOffset = r * maxOffset
        case .g:
            lastStoredOffset = g * maxOffset
        case .b:
            lastStoredOffset = b * maxOffset
        case .a:
            lastStoredOffset = a * maxOffset
        }
    }

    func updateControlledValue() {
        switch controls {
          case .r:
              r = thumbValue
          case .g:
              g = thumbValue
          case .b:
              b = thumbValue
          case .a:
              a = thumbValue
          }
    }

    var thumbOffset: Double {
        (dragging ? lastStoredOffset + gestureOffset : lastStoredOffset) + thumbLeadingOffset
    }

    var thumbLeadingOffset: Double {
        -(width / 2) + (Self.sliderSize / 2)
    }

    var maxOffset: Double {
        width - Self.sliderSize
    }

    var thumbValue: Double {
        (thumbOffset - thumbLeadingOffset) / maxOffset
    }

    func onEnd(value: DragGesture.Value) {
        var newOffset = lastStoredOffset + value.translation.width

        newOffset = max(0, newOffset)
        newOffset = min(maxOffset, newOffset)

        lastStoredOffset = newOffset
    }
    
    var lineGradient: [Color] {
        switch controls {
        case .r:
            return [
                Color(cgColor: CGColor(red: 0, green: g, blue: b, alpha: a)),
                Color(cgColor: CGColor(red: 1, green: g, blue: b, alpha: a))
            ]
        case .g:
            return [
                Color(cgColor: CGColor(red: r, green: 0, blue: b, alpha: a)),
                Color(cgColor: CGColor(red: r, green: 1, blue: b, alpha: a))
            ]
        case .b:
            return [
                Color(cgColor: CGColor(red: r, green: g, blue: 0, alpha: a)),
                Color(cgColor: CGColor(red: r, green: g, blue: 1, alpha: a))
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
#endif
