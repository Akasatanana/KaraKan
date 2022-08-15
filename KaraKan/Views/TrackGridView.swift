//
//  TrackGridView.swift
//  KaraKan
//
//  Created by Akasatanana on 2022/08/15.
//曲のタイル表示

import SwiftUI
import SpotifyWebAPI

struct TrackGridView: View {
    let tracks: [Track]
    var body: some View {
        let chunkedTracks: [[Track]] = tracks.chunked(size: 3)
        VStack(spacing: 0){
            ForEach(chunkedTracks, id: \.self){chunk in
                HStack(spacing: 0){
                    ForEach(chunk, id: \.self){track in
                        TrackRowView(track: track)
                    }
                }
                .listRowInsets(EdgeInsets())
            }
        }
    }
}

struct TrackGridView_Previews: PreviewProvider {
    static var previews: some View {
        TrackGridView(tracks: [])
    }
}
