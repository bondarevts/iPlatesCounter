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
                Text("Total count: \(document.marks.count)")
                    .font(.largeTitle)
                    .padding(.horizontal)
                Spacer()
                Slider(value: $markSize, in: markSizeRange, step: 1)
                Text("\(Int(markSize))")
                Button("Undo") {
                    document.dropLastMark()
                }
                .font(.largeTitle)
                Button("Remove All") {
                    if !document.marks.isEmpty {
                        self.showingRemoveAllAlert = true
                    }
                }
                .font(.largeTitle)
                .padding(.horizontal)
                .alert(isPresented: $showingRemoveAllAlert) {
                    Alert(title: Text("Remove all marks?"), primaryButton: .destructive(Text("Remove All")) {
                        document.clearMarks()
                    }, secondaryButton: .cancel())
                }
            }
            if let image = document.images.first {
                GeometryReader { geometry in
                    ZStack {
                        Color.white.overlay(Image(uiImage: image)
                            .scaleEffect(zoomScale)
                            .offset(self.panOffset))
                        DetectTapLocationView { location in
                            let x: CGFloat = (location.x - geometry.size.width / 2) / zoomScale
                            let y: CGFloat = (location.y - geometry.size.height / 2) / zoomScale
                            document.addMark(at: CGPoint(x: x, y: y), size: markSize)
                        }
                        ForEach(self.document.marks) { mark in
                            Circle()
                                .frame(width: mark.s * zoomScale, height: mark.s * zoomScale)
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
        var location = mark.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width / 2, y: location.y + size.height / 2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        return location
    }
}

extension CGSize {
    static func +(size1: Self, size2: Self) -> CGSize {
        CGSize(width: size1.width + size2.width, height: size1.height + size2.height)
    }
    static func *(size: Self, value: CGFloat) -> CGSize {
        CGSize(width: size.width * value, height: size.height * value)
    }
    static func /(size: Self, value: CGFloat) -> CGSize {
        CGSize(width: size.width / value, height: size.height / value)
    }
}

struct MarkedPlateDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        MarkedPlateDocumentView()
    }
}
