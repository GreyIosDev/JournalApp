import SwiftUI
import SlidingTabView
import AVFoundation

struct ContentView: View {
    @State private var tabIndex = 0 // This will tell us what tab we have currently selected

    var body: some View {
        VStack {
            SlidingTabView(selection: $tabIndex, tabs: ["Challenging", "Grateful", "Beautiful"], animation: .easeInOut, activeAccentColor: .black,selectionBarHeight: 5)
            
            Spacer() // This is so that it consumes all the space and pushes it to the top of the screen.
            
            if tabIndex == 0 {
                RecordView(tabTitle: "Challenging", color: LinearGradient(gradient: Gradient(colors: [.red, .black]), startPoint: .top, endPoint: .bottom))
            } else if tabIndex == 1 {
                RecordView(tabTitle: "Grateful", color: LinearGradient(gradient: Gradient(colors: [.orange, .pink]), startPoint: .top, endPoint: .bottom))
            } else if tabIndex == 2 {
                RecordView(tabTitle: "Beautiful", color: LinearGradient(gradient: Gradient(colors: [.blue, .white]), startPoint: .top, endPoint: .bottom))
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
