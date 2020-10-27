import SwiftUI

struct MarkedPlateDocumentView: View {
    var body: some View {
        Image(systemName: "photo")
            .resizable()
            .padding()
            .scaledToFit()
            .foregroundColor(.gray)
    }
}

struct MarkedPlateDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        MarkedPlateDocumentView()
    }
}
