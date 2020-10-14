//
//  Item.swift
//  TinyNews WatchKit Extension
//
//  Created by Guillermo Frias on 10/10/2020.
//
import Foundation

struct Item: Identifiable, Codable {
    let id: Int
    let deleted: Bool?
    let type: String
    let by: String?
    let time: Int
    var text: String?
    let dead: Bool?
    let parent: Int?
    //poll    The pollopt's associated poll.
    let kids: [Int]?
    let url: String?
    let score: Int?
    let title: String?
    //parts    A list of related pollopts, in display order.
    let descendants: Int?
    
    func elapsedTime() -> String {
        let d = Date(timeIntervalSince1970:TimeInterval(self.time))
        return d.getElapsedInterval()
    }
}
