// Code is based on
// https://stackoverflow.com/a/56518293 by Epaga, CC BY-SA 4.0

import SwiftUI

struct DetectTapLocationView: UIViewRepresentable {
    var tappedCallback: ((CGPoint) -> Void)

    func makeUIView(context: UIViewRepresentableContext<DetectTapLocationView>) -> UIView {
        let view = UIView()
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped))
        )
        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<DetectTapLocationView>) { }
    
    func makeCoordinator() -> DetectTapLocationView.Coordinator {
        return Coordinator(tappedCallback: self.tappedCallback)
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

struct LocatableTapGesture: ViewModifier {
    let onTap: (CGPoint) -> Void

    func body(content: Content) -> some View {
        content
            .overlay(DetectTapLocationView(tappedCallback: onTap))
    }
}


extension View {
    func onLocatableTapGesture(action: @escaping (CGPoint) -> Void) -> some View {
        self.modifier(LocatableTapGesture(onTap: action))
    }
}
