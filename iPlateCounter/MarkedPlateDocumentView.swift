import SwiftUI

struct MarkedPlateDocumentView: View {
    @ObservedObject var document = MarkedPlateDocument()
    @State var isPickerActive = false
    @State var marks: [CGPoint] = []
    @State var showingRemoveAllAlert = false
    let markSize: CGFloat = 30
    let markColor: Color = Color(red:0.0, green: 0.0, blue: 1.0, opacity: 0.4)
    
    var body: some View {
        VStack {
            HStack {
                Text("Total count: \(marks.count)")
                    .font(.largeTitle)
                    .padding(.horizontal)
                Spacer()
                Button("Undo") {
                    _ = marks.popLast()
                }
                .font(.largeTitle)
                Button("Remove All") {
                    if !marks.isEmpty {
                        self.showingRemoveAllAlert = true
                    }
                }
                .font(.largeTitle)
                .padding(.horizontal)
                .alert(isPresented: $showingRemoveAllAlert) {
                    Alert(title: Text("Remove all marks?"), primaryButton: .destructive(Text("Remove All")) {
                        marks.removeAll()
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
                            marks.append(CGPoint(x: location.x - geometry.size.width / 2,
                                                 y: location.y - geometry.size.height / 2))
                        }
                        ForEach(marks, id:\.self) { mark in
                            Circle()
                                .frame(width: markSize, height: markSize)
                                .offset(CGSize(width: mark.x, height: mark.y))
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
