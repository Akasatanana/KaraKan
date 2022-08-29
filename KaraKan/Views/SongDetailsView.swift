//
//  SongDetailsView.swift
//  KaraKan
//
//  Created by Akasatanana on 2022/08/19.
//

import SwiftUI
import SpotifyWebAPI
import WebKit

struct HTMLStringView: UIViewRepresentable {
    //htmlを表示するための構造体
    let htmlContent: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}

struct SongDetailsView: View {
    @State var track: Track
    @ObservedObject var model: GetLyricsModel = GetLyricsModel()
    var body: some View {
        ScrollView(showsIndicators: false){
            VStack{
                if let artists = track.artists {
                    VStack(alignment: .leading){
                        HStack(alignment: .top){
                            Text("アーティスト名：")
                            VStack(alignment: .leading){
                                ForEach(artists, id: \.self){artist in
                                    Text(artist.name)
                                }
                            }
                        }
                        HStack{
                            Text("曲名：")
                            Text(track.name)
                        }
                    }
                }
                LyricsView(model: model)
            }
        }
        .onAppear{
            let controller = GetLyricsController(model: model)
            if let artist = track.artists?.first?.name {
                controller.loadLyrics(artist: artist, song: track.name)
            }
        }
    }
}

struct SongDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        SongDetailsView(track: Track(name: "this is dummy", isLocal: true, isExplicit: true))
    }
}
