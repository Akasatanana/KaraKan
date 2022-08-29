//
//  LyricsView.swift
//  KaraKan
//
//  Created by Akasatanana on 2022/08/29.
//

import SwiftUI
import SpotifyWebAPI

struct LyricsView: View {
    let track: Track
    @ObservedObject var model: GetLyricsModel
    var body: some View {
        VStack(alignment: .center){
            VStack(alignment: .center){
            if let error = model.error {
                Text(error.localizedDescription)
                
                if let artist = track.artists?.first {
                    if let url = model.googleLyrics(artist: artist.name, song: track.name){
                        Link("Googleで歌詞を検索", destination: url)
                    }
                }
            }else {
                if let lyrics = model.lyrics {
                    Text(lyrics)
                        .font(.callout)
                    
                    Divider()
                    
                    if let artist = track.artists?.first {
                        if let url = model.googleLyrics(artist: artist.name, song: track.name){
                            Text("歌詞情報が間違っていますか？")
                            Link("Googleで歌詞を検索", destination: url)
                        }
                    }
                }else {
                    Text("サーバと通信中・・・")
                }
            }
            }
            .padding()
        }
        .frame(minWidth: screenWidth * 0.8, maxWidth: screenWidth * 0.8, minHeight: screenHeight, maxHeight: .infinity, alignment: .center)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                .shadow(color: .white.opacity(0.5), radius: 10, x: 0, y: 0)
                    )
        
        
    }
}

struct LyricsView_Previews: PreviewProvider {
    static var previews: some View {
        LyricsView(track: Track(name: "あいみょん", isLocal: false, isExplicit: false), model: GetLyricsModel())
    }
}
