//
//  SearchTracksModel.swift
//  KaraKan
//
//  Created by Akasatanana on 2022/08/15.
//

import Foundation
import SpotifyWebAPI
import Combine

class SearchTracksModel : ObservableObject{
    //曲を検索するクラス
    //クラスはviewでインスタンスが持たれ，プロパティを参照されるので，UIの監視対象にするためにPublish
    @Published var searchResults: [SpotifyWebAPI.Track] = []
    @Published var cancellables: Set<AnyCancellable> = []
    
    //アクセストークンをまとめて管理
    enum spotifyAccessTokens {
        case testToken
        
        var tokenvalues: [String: String] {
            switch self {
            case .testToken:
                return ["clientId": "d67151c1c83f496a91c7fe30f8241096",
                        "clientSecret": "13358806f6c1448794419ad5d9828991"]
            }
        }
    }
    
    // クライアントidとシークレットを指定してspotifyのインスタンスを作る
    let spotify = SpotifyAPI(
        authorizationManager: ClientCredentialsFlowManager(
            clientId: spotifyAccessTokens.testToken.tokenvalues["clientId"]!,
            clientSecret: spotifyAccessTokens.testToken.tokenvalues["clientSecret"]!
        )
        )
    
    private func authorizeApp () {
        //作成したインスタンスでauthrize
        spotify.authorizationManager.authorize()
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        print("successfully authorized application")
                    case .failure(let error):
                        print("could not authorize application: \(error)")
                }
            })
            .store(in: &cancellables)
    }
    
    func fetchtracks (keyword: String) {
        //アプリのauthorize
        authorizeApp()
        //検索
        spotify.search(query: keyword, categories: [.track])
            .sink(
                receiveCompletion: { completion in
                    //print(completion)
                },
                receiveValue: { results in
                    DispatchQueue.main.async {
                        self.searchResults = results.tracks!.items
                    }
                }
            )
            .store(in: &cancellables)
    }
    
}
