import SwiftUI

struct MarkedPlateDocumentView: View {
    @ObservedObject var document = MarkedPlateDocument()
    @State var isPickerActive = false
    @State var markSize: CGFloat = 30
    
    var body: some View {
        VStack {
            ControlPanel(
                document: document,
                isPickerActive: $isPickerActive,
                markSize: $markSize
            )
            if let image = document.image {
                PlatesView(marks: document.marks, image: image) { tap in
                    document.addMark(at: tap, diameter: markSize)
                }
                .clipped()
                .edgesIgnoringSafeArea([.horizontal, .bottom])
            } else {
                NoImageView()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isPickerActive.toggle()
                    }
            }
        }
        .sheet(isPresented: $isPickerActive) {
            ImagePicker(images: self.$document.images, showPicker: $isPickerActive)
        }
    }
}


struct PlatesView: View {
    private let markColor: Color = Color(red:0.0, green: 0.0, blue: 1.0, opacity: 0.4)
    var marks: [MarkedPlate.Mark]
    let image: UIImage
    let onTap: (CGPoint) -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(uiImage: image)
                    .scaleEffect(zoomScale)
                    .position(CGPoint(from: panOffset + geometry.size / 2))
                DetectTapLocationView { tap in
                    onTap(markLocation(tap: tap, size: geometry.size))
                }
                ForEach(marks) { mark in
                    Circle()
                        .frame(width: mark.size, height: mark.size)
                        .scaleEffect(zoomScale)
                        .position(self.position(for: mark, in: geometry.size))
                        .foregroundColor(markColor)
                }
            }
        }
        .zIndex(-1)
        .gesture(self.panGesture())
        .gesture(self.zoomGesture())
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

struct NoImageView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack() {
                Text("Tap to open an image")
                    .font(.largeTitle)
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .foregroundColor(.gray)
            .frame(width: geometry.size.width * 0.75)
            .position(CGPoint(from: geometry.size / 2))
        }
    }
}

struct ControlPanel: View {
    @ObservedObject var document: MarkedPlateDocument
    @Binding var isPickerActive: Bool
    @Binding var markSize: CGFloat
    @State var showingRemoveAllAlert = false
    @State var showingPreferences = false

    var body: some View {
        VStack {
            HStack {
                Button(
                    action: { isPickerActive = true },
                    label: { Label("Open...", systemImage: "folder") }
                )
                Spacer()
                Button(
                    action: { UIPasteboard.general.string = marksToString() },
                    label: { Label("Copy marks...", systemImage: "arrow.up.doc.on.clipboard") }
                )
                Button(
                    action: { showingPreferences = true },
                    label: { Image(systemName: "ellipsis").imageScale(.large) }
                )
                .contentShape(Rectangle())
                .padding(.leading, 20)
                .popover(isPresented: $showingPreferences) {
                    PreferencesView(markSize: $markSize)
                        .frame(width: 300, height: 145)
                }
            }
            .padding(.bottom, 5)
            HStack(spacing: 20) {
                Button(
                    action: { document.dropLastMark() },
                    label: { Image(systemName: "arrowshape.turn.up.backward.fill") }
                )
                Button(
                    action: {
                        if !document.marks.isEmpty {
                            self.showingRemoveAllAlert = true
                        }
                    },
                    label: { Image(systemName: "arrowshape.turn.up.left.2.fill") }
                )
                .alert(isPresented: $showingRemoveAllAlert) {
                    Alert(title: Text("Remove all marks?"), primaryButton: .destructive(Text("Remove All")) {
                        document.clearMarks()
                    }, secondaryButton: .cancel())
                }
                Spacer()
                Text("Total: \(document.marks.count)")
            }
        }
        .padding(.horizontal)
        .font(.largeTitle)
    }

    func marksToString() -> String {
        let center = document.image!.size / 2
        return Array.joined(
            document.marks
                .map { mark in "\(Int(center.width + CGFloat(mark.x))),\(Int(center.height + CGFloat(mark.y))),\(Int(mark.diameter))" }
        )(separator: "\n")
    }
}

struct PreferencesView: View {
    private let markSizeRange: ClosedRange<CGFloat> = 1...100
    @Binding var markSize: CGFloat

    var body: some View {
        List {
            VStack(alignment: .leading) {
                Text("Mark Diameter")
                HStack {
                    Text("\(Int(markSize))")
                        .frame(minWidth: 30, alignment: .leading)
                    Slider(value: $markSize, in: markSizeRange, step: 1)
                        .frame(minWidth: 200)
                }
            }
        }
        .font(.subheadline)
        .padding()
    }
}

struct MarkedPlateDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        MarkedPlateDocumentView()

        PreferencesView(markSize: .constant(10))
            .previewLayout(.fixed(width: 300, height: 145))
    }
}
