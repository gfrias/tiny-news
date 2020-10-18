//
//  Store.swift
//  TinyNews WatchKit Extension
//
//  Created by Guillermo Frias on 10/10/2020.
//
import SwiftUI
import Combine

class Store: ObservableObject {

    private var cancellableTop: AnyCancellable?
    private var cancellableItems: AnyCancellable?
    
    @Published var items: [Int: [Item]] = [Int:[Item]]()
    
    init(mock:Bool = false) {
        if mock {
            self.items = getSampleData()
        }
    }
    
    func loadTopStories() {
        let url = URL(string: "https://hacker-news.firebaseio.com/v0/topstories.json")!
//        print(">>> loading top stories: \(url)")

        self.items = [Int:[Item]]()
        
        self.cancellableTop = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Int].self, decoder: JSONDecoder())
            .map { Array($0.prefix(20)) }
            .replaceError(with: [])
            .receive(on: RunLoop.main)
            .sink(receiveValue: { (ids) in
//                print("<<< top stories loaded: \(ids)")
                self.loadItems(parent: 0, ids: ids)
            })
    }
    
    func loadItems(parent: Int, ids: [Int]) {
        if self.items[parent] != nil {
            return
        }
//        print(">>> loading items: \(ids) for parent \(parent)")
        
        let publisherOfPublishers = Publishers.MergeMany(ids.map { buildItemPublisher(id: $0 )})
        
        self.cancellableItems = publisherOfPublishers
                            .compactMap{ $0 }
                            .filter { !($0.deleted ?? false) }
                            .reduce([Int:Item](), { (dict, item) -> [Int:Item] in
//                                print("reducing items for parent \(parent) item \(item.id)")
                                var dict = dict, item = item
                                item.text = item.text?.htmlToPlainStr()
                                dict[item.id] = item
                                return dict
                            })
                            .receive(on: RunLoop.main)
                            .sink(receiveValue: { items in
//                                print("mapping items for parent \(parent)")
                                self.items[parent] = ids.compactMap { items[$0] }
                                self.objectWillChange.send()
                            })
    }
    
    private func buildItemPublisher(id: Int) -> AnyPublisher<Item?, Never> {
        let url = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json")!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: Item.self, decoder: JSONDecoder())
            .map { $0 as Item? }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    func getSampleData() -> [Int: [Item]] {
        return [0:
                [Item(id: 1, deleted: false, type: "Story", by: "gfrias", time: 0, text: "Apple releases iPhone 12", dead: false, parent: 0, kids: [], url: "www.apple.com", score: 12, title: "Apple releases iPhone 12", descendants: 0),
                 Item(id: 2, deleted: false, type: "Story", by: "jdoe", time: 0, text: "Apple releases iPhone 12", dead: false, parent: 0, kids: [], url: "www.apple.com", score: 12, title: "Apple releases iPhone 12", descendants: 0)
                
                ]
        ]
    }
}



