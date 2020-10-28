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
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                        DetectTapLocationView { location in
                            document.addMark(at: CGPoint(x: location.x - geometry.size.width / 2,
                                                         y: location.y - geometry.size.height / 2), size: markSize)
                        }
                        ForEach(self.document.marks) { mark in
                            Circle()
                                .frame(width: mark.s, height: mark.s)
                                .offset(CGSize(width: mark.location.x, height: mark.location.y))
                                .foregroundColor(markColor)
                        }
                    }
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
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

struct MarkedPlateDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        MarkedPlateDocumentView()
    }
}
