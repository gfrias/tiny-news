//
//  Image.swift
//  TinyNews WatchKit Extension
//
//  Created by Guillermo Frias on 10/10/2020.
//
import SwiftUI
import Combine


class ImageLoader: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }

    init(urlString:String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.data = data
            }
        }
        task.resume()
    }
}

struct ImageView: View {
    @ObservedObject var imageLoader:ImageLoader
    
    @State var image:UIImage?
    
    @State var scrollAmount = 1.0
    
    @State private var dragOffset = CGSize.zero
    
    private let url: String
    

    init(withURL url:String) {
        self.url = url
        //imageLoader = ImageLoader(urlString:"http://192.168.178.199:8000/img.png")
        let urlEncoded = url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        imageLoader = ImageLoader(urlString:"http://192.168.178.199:3000?url=" + urlEncoded)
    }

    var body: some View {
        if let image = image {
            return AnyView(
                GeometryReader { geometry in
                    Image(uiImage: image)
                    .resizable().scaleEffect(CGFloat(scrollAmount))
                    .aspectRatio(contentMode: .fill)
                    .focusable(true)
                    .gesture(
                        DragGesture()
                            .onChanged {
                                let trans = $0.translation
                                let width = dragOffset.width + trans.width
                                let height = dragOffset.height + trans.height
                                
//                                let deltaW = (scrollAmount-1.0)*3*31.0
//                                width = min(CGFloat(deltaW), width)
////                                width = max(width, -self.size.width*CGFloat(scrollAmount)+geometry.size.width)
//                                let deltaH = (Double(scrollAmount)-1.0)*Double(self.size.height)/2.0
//                                height = min(CGFloat(deltaH), height)
////                                height = max(height, -self.size.height*CGFloat(scrollAmount)+geometry.size.height+geometry.safeAreaInsets.bottom)
//
//                                print("\(scrollAmount) \(height) \(self.size.height) \(geometry.size.height) \(geometry.safeAreaInsets.top) \(geometry.safeAreaInsets.bottom)")
                                
                                self.dragOffset = CGSize(width: width, height: height)
                            }
                    )
                    .offset(self.dragOffset)
                    .digitalCrownRotation($scrollAmount,
                                          from: 1, through: 5,
                                          by: 0.1, sensitivity: .low,
                                          isContinuous: false,
                                          isHapticFeedbackEnabled: true)
                    .navigationTitle(url)
                })
        } else {
            return AnyView(ProgressView()
                            .onReceive(imageLoader.didChange){ data in
                                    self.image = UIImage(data: data)
                                })
        }
    }
    
    
}
