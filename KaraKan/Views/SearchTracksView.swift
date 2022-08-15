//
//  SearchTracksView.swift
//  KaraKan
//
//  Created by Akasatanana on 2022/08/15.
//曲検索全体のView

import SwiftUI

struct SearchTracksView: View {
    @State var keyword: String = ""
    @ObservedObject var model : SearchTracksModel = SearchTracksModel()
    var body: some View {
        ScrollView(showsIndicators: false){
            VStack{
                HStack {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: UIScreen.main.bounds.height * 0.035)
                    
                    Spacer()
                    
                    TextField("曲を検索", text: $keyword)
                        .onChange(of: keyword){_ in
                            SearchTracksController(model: model).loadResults(keyword: keyword)
                        }
                }
                .font(.title2)
                .frame(height: (UIScreen.main.bounds.height * 0.05))
                .padding(.vertical, UIScreen.main.bounds.height * 0.05)
                
                TrackGridView(tracks: model.searchResults)
            }
        }
    }
}

struct SearchTracksView_Previews: PreviewProvider {
    static var previews: some View {
        SearchTracksView()
    }
}
