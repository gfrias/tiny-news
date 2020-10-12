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
    private var cancellableComments: AnyCancellable?
    private var cancellableItems: AnyCancellable?
    
    private var ids: [Int]?
    
    @Published var listItems: [Item]?
    
    @Published var comments: [Int: [Comment]] = [Int:[Comment]]()
    
    init () {}
    
    init (ids: [Int], listItems: [Item], comments: [Int: [Comment]]) {
        self.ids = ids
        self.listItems = listItems
        self.comments = comments
    }
    
    func loadTopStories() {
        let url = URL(string: "https://hacker-news.firebaseio.com/v0/topstories.json")!
        print(url)
        
        self.cancellableTop = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Int].self, decoder: JSONDecoder())
            .map { Array($0.prefix(20)) }
            .replaceError(with: [])
            .receive(on: RunLoop.main)
            .sink(receiveValue: { (ids) in
                self.ids = ids
                self.loadItems(ids: ids)
            })
    }
    
    private func loadItems(ids: [Int]) {
        let publisherOfPublishers = Publishers.MergeMany(ids.map { buildItemPublisher(id: $0 )})
        
        self.cancellableItems = publisherOfPublishers
                            .compactMap{ $0 }
                            .reduce([Int:Item](), { (itemsMap, item) -> [Int:Item] in
                                var itemsMap = itemsMap
                                itemsMap[item.id] = item
                                return itemsMap
                            })
                            .receive(on: RunLoop.main)
                            .sink(receiveValue: { itemsMap in
                                self.listItems = ids.compactMap { itemsMap[$0] }
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
    
    func loadComments(itemId:Int, kids: [Int]) {
        if self.comments[itemId] != nil || kids.count == 0 {
            return
        }
        
        let publisherOfPublishers = Publishers.MergeMany(kids.map { buildCommentPublisher(id: $0 )})
        
        self.cancellableComments = publisherOfPublishers
                            .compactMap{ $0 }
                            .reduce([Int:Comment](), { (commsMap, comment) -> [Int:Comment] in
                                var commsMap = commsMap
                                commsMap[comment.id] = comment
                                return commsMap
                            })
                            .receive(on: RunLoop.main)
                            .sink(receiveValue: { commsMap in
                                self.comments[itemId] = kids.compactMap { commsMap[$0] }.filter { !($0.deleted ?? false) }
                                self.objectWillChange.send()
                            })
    }
    
    private func buildCommentPublisher(id: Int) -> AnyPublisher<Comment?, Never> {
        let url = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json")!

        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: Comment.self, decoder: JSONDecoder())
            .map {
                var comment = $0
                if let text = comment.text {
                    comment.text = text.htmlToPlainStr()
                }
                
                return Optional(comment)
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    public static func makeSampleStore() -> Store {
        let item = Item(by: "jgneff", descendants: 0, id: 1, kids: [10], score: 157, time: 1602345198, title: "Cameras and secret trackers reveal where Amazon returns end up", type: "story", url: "https://www.cbc.ca/news/canada/marketplace-amazon-returns-1.5753714")
        
        let item2 = Item(by: "swazzy", descendants: 155, id: 2, kids: [20, 21], score: 354, time: 1602326111, title: "They\'re Made Out of Meat (1991)", type: "story", url: "https://www.mit.edu/people/dpolicar/writing/prose/text/thinkingMeat.html")
        
        let lstItems = [item, item2]
        let ids = lstItems.map {$0.id }
        
        return Store(ids: ids, listItems: lstItems, comments: buildSampleComments())
    }
    
    private static func buildSampleComments() -> [Int:[Comment]] {
        return [1: [Comment(by: "gfrias", id: 10, kids: [], parent: 0, text: "This is the first comment the quick brown fox lorem ipsum", time: 0, type: "comment", deleted: false)],
                2: [Comment(by: "jdoe", id: 20, kids: [200], parent: 0, text: "Test 1 comment", time: 0, type: "comment", deleted: false),
                    Comment(by: "abort", id: 21, kids: [], parent: 0, text: "Test 2 comment", time: 0, type: "comment", deleted: false)
                ],
                20: [Comment(by: "tpuente", id: 200, kids: [], parent: 0, text: "Nested comment", time: 0, type: "comment", deleted: false)]
        ]
    }
}



