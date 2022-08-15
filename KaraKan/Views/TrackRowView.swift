//
//  TrackRowView.swift
//  KaraKan
//
//  Created by Akasatanana on 2022/08/15.
//曲情報のまとめView

import SwiftUI
import SpotifyWebAPI

struct TrackRowView: View {
    @State var track: Track
    let imagesize: CGFloat = (UIScreen.main.bounds.width * 0.33)
    var body: some View {
        ZStack{
            AsyncImage(url: track.album?.images?.first?.url){image in
                image
                    .resizable()
                    .scaledToFit()
                    .opacity(0.8)
            }placeholder: {
                ZStack{
                    Rectangle()
                        .frame(width: imagesize, height: imagesize)
                        .foregroundColor(.gray)
                        .opacity(0.8)
                    
                    Text("準備中")
                        .foregroundColor(.black)
                    
                }
            }
            
            VStack(){
                Spacer()
                //背景色のためにグループ化
                Group{
                    Text(track.name)
                        .lineLimit(1)
                    if let artistname = track.artists?.first?.name{
                        Text(artistname)
                            .lineLimit(1)
                    }
                }
                .background(.black.opacity(0.2))
            }
        }
        .frame(width: imagesize, height: imagesize)
    }
}

struct TrackRowView_Previews: PreviewProvider {
    @ObservedObject static var model: SearchTracksModel = SearchTracksModel()
    static var previews: some View {
        let _ = model.fetchtracks(keyword: "米津玄師")
        TrackRowView(track: model.searchResults.first!)
    }
}

