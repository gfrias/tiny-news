//
//  Image.swift
//  TinyNews WatchKit Extension
//
//  Created by Guillermo Frias on 10/10/2020.
//
import SwiftUI
import Combine
import UIKit


class ImageLoader: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }

    init(urlString:String, mock:Bool) {
        if mock {
            guard let bundleURL = Bundle.main.url(forResource: "Pictures", withExtension: "bundle") else { return }
            guard let bundle = Bundle(url: bundleURL) else { return }
            guard let imageURL = bundle.url(forResource: "img", withExtension: "png") else { return }

            let image = UIImage(contentsOfFile: imageURL.path)
            
            DispatchQueue.main.async {
                self.data = image?.pngData() ?? Data()
            }
            return
        }
        
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

class ImageViewModel: ObservableObject {
    @Published var offset = CGSize.zero
    var offsetDrag = CGSize.zero
    
    var zoomLevelDrag: CGFloat = 1.0
    
    let size: CGSize
    
    init(width: CGFloat, height: CGFloat) {
        self.size = CGSize(width: width, height: height)
    }
    
    @Published var zoomLevel: CGFloat = 1.0 {
        didSet {
            let delta = zoomLevelDrag - zoomLevel
            
            let x = size.width*delta/2 + offsetDrag.width*zoomLevel
            let y = size.height*delta/2 + offsetDrag.height*zoomLevel
            
            self.offset = CGSize(width: x, height: y)
        }
    }
    
    func updateOffset(translation:CGSize) {
        let x = offset.width + translation.width
        let y = offset.height + translation.height
        
        self.zoomLevelDrag = self.zoomLevel

        self.offsetDrag = CGSize(width: x/zoomLevel, height: y/zoomLevel)
        self.offset =  CGSize(width: x, height: y)
    }
}

struct ImageView: View {
    @ObservedObject var imageLoader:ImageLoader

    @ObservedObject var model: ImageViewModel
    
    @State var image:UIImage?
    
    private let url: String
    
    init(withURL url:String, size: CGSize, mock:Bool = false) {
        self.url = url
        self.model = ImageViewModel(width: size.width, height: size.height)
        
        let urlEncoded = url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        self.imageLoader = ImageLoader(urlString:"http://192.168.178.199:3000?url=" + urlEncoded, mock: mock)
        
        self.image = UIImage(named: "Mock")
    }

    var body: some View {
        if let image = image {
            return AnyView(
                Image(uiImage: image)
                .resizable()
                .scaleEffect(CGFloat(model.zoomLevel), anchor: .topLeading)
                .aspectRatio(contentMode: .fill)
                .focusable(true)
                .gesture(
                    DragGesture()
                        .onChanged {
                            model.updateOffset(translation: $0.translation)
                        }
                )
                .offset(model.offset)
                .digitalCrownRotation($model.zoomLevel,
                                  from: 1, through: 5,
                                  by: 1, sensitivity: .low,
                                  isContinuous: false,
                                  isHapticFeedbackEnabled: true)
                .navigationTitle(url)
            )
        } else {
            return AnyView(
                    ProgressView()
                            .onReceive(imageLoader.didChange){ data in
                                self.image = UIImage(data: data)
                            }
            )
        }
    }
}

struct WebView: View {
    let url: String

    var body: some View {
        GeometryReader() { geo in
            ImageView(withURL: url, size: geo.size, mock: true)
        }
    }

}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(url: "")
    }
}
