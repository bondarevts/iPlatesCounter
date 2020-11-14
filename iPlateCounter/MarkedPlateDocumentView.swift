import SwiftUI

struct MarkedPlateDocumentView: View {
    @ObservedObject var document = MarkedPlateDocument()
    @State var isPickerActive = false
    @State var markSize: CGFloat = 30
    @State var removeOnTap: Bool = false
    
    var body: some View {
        VStack {
            ControlPanel(
                document: document,
                isPickerActive: $isPickerActive,
                markSize: $markSize,
                removeOnTap: $removeOnTap
            )
            if document.image != nil {
                PlatesView(document: document, markSize: $markSize, removeOnTap: $removeOnTap)
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
    private let markColor: Color = Color(red: 0.0, green: 0.0, blue: 1.0, opacity: 0.4)
    @ObservedObject var document: MarkedPlateDocument
    @Binding var markSize: CGFloat
    @Binding var removeOnTap: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(uiImage: document.image!)
                    .onLocatableTapGesture { tap in
                        document.addMark(at: tap, diameter: markSize)
                    }
                    .scaleEffect(zoomScale)  // scale should be applied before position
                    .position(CGPoint(from: panOffset + geometry.size / 2))
                ForEach(document.marks) { mark in
                    Circle()
                        .foregroundColor(markColor)
                        .onLocatableTapGesture {tap in
                            if removeOnTap {
                                document.removeMark(mark)
                            } else {
                                document.addMark(at: mark.location + tap - mark.size / 2, diameter: markSize)
                            }
                        }
                        .frame(width: mark.size, height: mark.size)
                        .scaleEffect(zoomScale)  // scale should be applied before position
                        .position(self.screenPosition(for: mark, in: geometry.size))
                }
            }
        }
        .zIndex(-1)
        .gesture(self.panGesture())
        .gesture(self.zoomGesture())
    }

    private func screenPosition(for mark: MarkedPlate.Mark, in size: CGSize) -> CGPoint {
        return (mark.location.offset(with: -document.image!.size / 2) * zoomScale).offset(with: size / 2 + panOffset)
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
            .frame(width: geometry.size.width * widthScaleFactor)
            .position(CGPoint(from: geometry.size / 2))
        }
    }

    private let widthScaleFactor: CGFloat = 0.75
}

struct ControlPanel: View {
    @ObservedObject var document: MarkedPlateDocument
    @Binding var isPickerActive: Bool
    @Binding var markSize: CGFloat
    @Binding var removeOnTap: Bool
    @State var showingRemoveAllAlert = false
    @State var showingPreferences = false

    var body: some View {
        VStack(spacing: verticalBarsSpacing) {
            HStack(spacing: horizontalElementsSpacing) {
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
                    label: { Image(systemName: "ellipsis")
                        .imageScale(.large)
                        .padding()
                    }
                )
                .popover(isPresented: $showingPreferences) {
                    PreferencesView(markSize: $markSize, removeOnTap: $removeOnTap)
                        .frame(size: preferencesPopoverSize)
                }
            }
            Divider()
            HStack(spacing: horizontalElementsSpacing) {
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
            Divider()
        }
        .padding(.horizontal)
        .padding(.bottom, -verticalBarsSpacing)
        .font(.largeTitle)
    }

    func marksToString() -> String {
        Array.joined(document.marks.map { "\($0.x),\($0.y),\(Int($0.diameter))" })(separator: "\n")
    }

    private let verticalBarsSpacing: CGFloat = 10
    private let horizontalElementsSpacing: CGFloat = 20
    private let preferencesPopoverSize = CGSize(width: 300, height: 145)
}

struct PreferencesView: View {
    private let markSizeRange: ClosedRange<CGFloat> = 1...100
    @Binding var markSize: CGFloat
    @Binding var removeOnTap: Bool

    var body: some View {
        List {
            VStack(alignment: .leading) {
                Text("Mark Diameter")
                HStack {
                    Text("\(Int(markSize))")
                        .frame(minWidth: minMarkSizeTextWidth, alignment: .leading)
                    Slider(value: $markSize, in: markSizeRange, step: 1)
                        .frame(minWidth: minSliderLength)
                }
            }
            Toggle(isOn: $removeOnTap) {
                Text("Remove mark on click")
            }
        }
        .font(.subheadline)
        .padding()
    }

    private let minMarkSizeTextWidth: CGFloat = 30
    private let minSliderLength: CGFloat = 200
}

struct MarkedPlateDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        MarkedPlateDocumentView()

        PreferencesView(markSize: .constant(10), removeOnTap: .constant(true))
            .previewLayout(.fixed(width: 300, height: 145))
    }
}
