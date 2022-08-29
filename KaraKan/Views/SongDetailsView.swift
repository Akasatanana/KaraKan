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
            VStack(alignment: .center){
                AsyncImage(url: track.album?.images?.first?.url){image in
                    image
                        .resizable()
                        .scaledToFit()
                        .opacity(0.8)
                }placeholder: {
                    ZStack{
                        Rectangle()
                            .foregroundColor(.gray)
                            .scaledToFit()
                            .opacity(0.8)
                        
                        Text("準備中")
                            .foregroundColor(.black)
                        
                    }
                }
                Text(track.name)
                    .font(.largeTitle)
                    .bold()
                
                if let artists = track.artists {
                    ForEach(artists, id: \.self){artist in
                        Text(artist.name)
                            .font(.title2)
                            .foregroundColor(.gray.opacity(0.8))
                            
                    
                    }
                }
                    
                LyricsView(track: track, model: model)
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
