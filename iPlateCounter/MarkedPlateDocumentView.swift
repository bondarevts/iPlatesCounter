import SwiftUI

struct MarkedPlateDocumentView: View {
    @ObservedObject var document = MarkedPlateDocument()
    @State var isPickerActive = false
    @State var showingRemoveAllAlert = false
    @State var markSize: CGFloat = 30
    let markSizeRange: ClosedRange<CGFloat> = 1...100
    let markColor: Color = Color(red:0.0, green: 0.0, blue: 1.0, opacity: 0.4)
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    isPickerActive = true
                }) {
                    Image(systemName: "folder")
                }
                .padding(.horizontal)
                Text("Total: \(document.marks.count)")
                Spacer(minLength: 50)
                Slider(value: $markSize, in: markSizeRange, step: 1)
                Text("\(Int(markSize))")
                Button("Undo") {
                    document.dropLastMark()
                }
                Button("Remove All") {
                    if !document.marks.isEmpty {
                        self.showingRemoveAllAlert = true
                    }
                }
                .padding(.horizontal)
                .alert(isPresented: $showingRemoveAllAlert) {
                    Alert(title: Text("Remove all marks?"), primaryButton: .destructive(Text("Remove All")) {
                        document.clearMarks()
                    }, secondaryButton: .cancel())
                }

                Button(action: {
                    let center = document.image!.size / 2
                    let string = Array.joined(
                        document.marks
                            .map { mark in "\(Int(center.width + CGFloat(mark.x))),\(Int(center.height + CGFloat(mark.y))),\(Int(mark.diameter))" }
                    )(separator: "\n")
                    UIPasteboard.general.string = string
                }) {
                    Image(systemName: "doc.on.doc")
                }
                .padding(.horizontal)
            }
            .font(.largeTitle)
            .zIndex(1)
            if let image = document.image {
                GeometryReader { geometry in
                    ZStack {
                        Color.white.overlay(Image(uiImage: image))
                            .scaleEffect(zoomScale)
                            .position(CGPoint(from: panOffset + geometry.size / 2))
                        DetectTapLocationView { location in
                            document.addMark(at: markLocation(tap: location, size: geometry.size), diameter: markSize)
                        }
                        ForEach(self.document.marks) { mark in
                            Circle()
                                .frame(width: mark.s, height: mark.s)
                                .scaleEffect(zoomScale)
                                .position(self.position(for: mark, in: geometry.size))
                                .foregroundColor(markColor)
                        }
                    }
                    .clipped()
                    .gesture(self.panGesture())
                    .gesture(self.zoomGesture())
                    .edgesIgnoringSafeArea([.horizontal, .bottom])
                }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .padding()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .onTapGesture {
                        isPickerActive.toggle()
                    }
            }
        }
        .sheet(isPresented: $isPickerActive) {
            ImagePicker(images: self.$document.images, showPicker: $isPickerActive)
        }
    }
    
    @State private var steadyStateZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomState, _ in
                gestureZoomState = latestGestureScale
            }
            .onEnded { finalGestureScale in
                self.steadyStateZoomScale *= finalGestureScale
            }
    }

    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, _ in
                gesturePanOffset = latestDragGestureValue.translation / self.zoomScale
            }
            .onEnded { finalDragGestureValue in
                self.steadyStatePanOffset = self.steadyStatePanOffset + finalDragGestureValue.translation / zoomScale
            }
    }
    
    private func position(for mark: MarkedPlate.Mark, in size: CGSize) -> CGPoint {
        (mark.location * zoomScale).offset(with: panOffset + size / 2)
    }
    
    private func markLocation(tap location: CGPoint, size: CGSize) -> CGPoint {
        location.offset(with: -panOffset - size / 2) / zoomScale
    }
}

extension CGSize {
    static func +(size1: Self, size2: Self) -> CGSize {
        CGSize(width: size1.width + size2.width, height: size1.height + size2.height)
    }
    static func -(size1: Self, size2: Self) -> CGSize {
        CGSize(width: size1.width - size2.width, height: size1.height - size2.height)
    }
    static func *(size: Self, value: CGFloat) -> CGSize {
        CGSize(width: size.width * value, height: size.height * value)
    }
    static func /(size: Self, value: CGFloat) -> CGSize {
        CGSize(width: size.width / value, height: size.height / value)
    }
    static prefix func -(size: Self) -> CGSize {
        CGSize(width: -size.width, height: -size.height)
    }
}

extension CGPoint {
    static func *(point: Self, value: CGFloat) -> CGPoint {
        CGPoint(x: point.x * value, y: point.y * value)
    }
    static func /(point: Self, value: CGFloat) -> CGPoint {
        CGPoint(x: point.x / value, y: point.y / value)
    }
    func offset(with size: CGSize) -> CGPoint {
        CGPoint(x: x + size.width, y: y + size.height)
    }
    init(from size: CGSize) {
        self.init(x: size.width, y: size.height)
    }
}

extension View {
    func frame(size: CGSize, alignment: Alignment = .center) -> some View {
        self.frame(width: size.width, height: size.height, alignment: alignment)
    }
}

struct MarkedPlateDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        MarkedPlateDocumentView()
    }
}
