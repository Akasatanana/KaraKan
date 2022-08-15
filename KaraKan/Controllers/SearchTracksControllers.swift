//
//  SearchTracksControllers.swift
//  KaraKan
//
//  Created by Akasatanana on 2022/08/15.
//

import Foundation

struct SearchTracksController {
    // この構造体を読んでモデルを動作させる
    let model: SearchTracksModel
    
    func loadResults (keyword: String) {
        model.fetchtracks(keyword: keyword)
    }
}
