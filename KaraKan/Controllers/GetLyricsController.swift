//
//  GetLyricsController.swift
//  KaraKan
//
//  Created by Akasatanana on 2022/08/19.
//

import Foundation

struct GetLyricsController {
    let model: GetLyricsModel
    func loadLyrics (artist:String, song:String) {
        model.fetchLyrics(artist: artist, song: song)
    }
}
