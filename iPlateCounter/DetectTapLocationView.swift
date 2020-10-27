// Code is based on
// https://stackoverflow.com/a/56518293 by Epaga, CC BY-SA 4.0

import SwiftUI

struct DetectTapLocationView: UIViewRepresentable {
    var tappedCallback: ((CGPoint) -> Void)

    func makeUIView(context: UIViewRepresentableContext<DetectTapLocationView>) -> UIView {
        let view = UIView(frame: .zero)
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped))
        )
        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<DetectTapLocationView>) { }
    
    func makeCoordinator() -> DetectTapLocationView.Coordinator {
        return Coordinator(tappedCallback:self.tappedCallback)
    }
    
    class Coordinator: NSObject {
        var tappedCallback: ((CGPoint) -> Void)
        
        init(tappedCallback: @escaping ((CGPoint) -> Void)) {
            self.tappedCallback = tappedCallback
        }
        
        @objc func tapped(gesture: UITapGestureRecognizer) {
            let point = gesture.location(in: gesture.view)
            self.tappedCallback(point)
        }
    }
}
