//
//  BookModel.swift
//  HeadWayTestApp
//

import Foundation

struct BookModel: Equatable {
    let title: String
    let imageUrl: URL
    let keyPoints: [KeyPoint]
}

struct KeyPoint: Equatable {
    let title: String
    let url: URL
}

extension BookModel {
    static let testBookModel = BookModel(
        title: "The Letters of Robert Browning and Elizabeth Barrett Barrett, Part 2", 
        imageUrl: .init(string: "https://ia601301.us.archive.org/34/items/lettersofrbandebb_2401_librivox/lettersrbandebb2_2401.jpg")!,
        keyPoints: [
            KeyPoint(
                title: "E.B.B. to R.B. January 1, 1845 [1846]",
                url: .init(string: "https://ia801301.us.archive.org/34/items/lettersofrbandebb_2401_librivox/lettersbrowning2_001_browning_128kb.mp3")!
            ),
            KeyPoint(
                title: "R.B. to E.B.B. Sunday Night. [Post-mark, January 5, 1846]",
                url: .init(string: "https://ia601301.us.archive.org/34/items/lettersofrbandebb_2401_librivox/lettersbrowning2_002_browning_128kb.mp3")!
            ),
            KeyPoint(
                title: "E.B.B. to R.B. Sunday. [Post-mark, January 6, 1846]",
                url: .init(string: "https://ia801301.us.archive.org/34/items/lettersofrbandebb_2401_librivox/lettersbrowning2_003_browning_128kb.mp3")!
            ),
            KeyPoint(
                title: "R.B. to E.B.B. Tuesday Morning",
                url: .init(string: "https://ia601301.us.archive.org/34/items/lettersofrbandebb_2401_librivox/lettersbrowning2_004_browning_128kb.mp3")!
            ),
            KeyPoint(
                title: "R.B. to E.B.B. Tuesday Night. [Post-mark, January 7, 1846]",
                url: .init(string: "https://ia601301.us.archive.org/34/items/lettersofrbandebb_2401_librivox/lettersbrowning2_005_browning_128kb.mp3")!
            )
            
        ]
    )

}
