//
//  ListeningExercise.swift
//  Accent
//
//  Created by Jack Cook on 6/10/17.
//  Copyright © 2017 Jack Cook. All rights reserved.
//

import Foundation

struct ListeningExercise {
    let id: Int
    let name: String
    let sentences: [String]
    
    init(id: Int, name: String, sentences: [String]) {
        self.id = id
        self.name = name
        self.sentences = sentences
    }
    
    func audioURL(for sentence: Int) -> URL {
        return URL(string: "http://localhost:4567/listening/\(id)/sentences/\(sentence)/audio")!
    }
}
