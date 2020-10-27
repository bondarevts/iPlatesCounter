import SwiftUI

struct MarkedPlateDocumentView: View {
    @ObservedObject var document = MarkedPlateDocument()
    @State var isPickerActive = false
    @State var marks: [CGPoint] = []
    
    var body: some View {
        VStack {
            if let image = document.images.first {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                    DetectTapLocationView { location in
                        print("\(location)")
                        marks.append(location)
                    }
                    ForEach(marks, id:\.self) { mark in
                        Circle()
                            .frame(width:30, height:30)
                            .offset(CGSize(width: mark.x, height: mark.y))
                            .foregroundColor(.red)
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
