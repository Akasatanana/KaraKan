//
//  LyricsView.swift
//  KaraKan
//
//  Created by Akasatanana on 2022/08/29.
//

import SwiftUI

struct LyricsView: View {
    @ObservedObject var model: GetLyricsModel
    var body: some View {
        VStack(alignment: .center){
            VStack(alignment: .center){
            if let error = model.error {
                Text(error.localizedDescription)
            }else {
                if let lyrics = model.lyrics {
                    Text(lyrics)
                        .font(.callout)
                }else {
                    Text("サーバと通信中")
                }
            }
            }
            .padding()
        }
        .frame(minWidth: screenWidth * 0.75, maxWidth: screenWidth * 0.75, minHeight: screenHeight, maxHeight: .infinity, alignment: .center)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                .shadow(color: .white.opacity(0.5), radius: 10, x: 0, y: 0)
                    )
        
        
    }
}

struct LyricsView_Previews: PreviewProvider {
    static var previews: some View {
        LyricsView(model: GetLyricsModel())
    }
}
