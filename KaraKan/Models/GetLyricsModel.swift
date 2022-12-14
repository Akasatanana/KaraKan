//
//  GetLyricsModel.swift
//  KaraKan
//
//  Created by Akasatanana on 2022/08/19.
//

import Foundation

class GetLyricsModel: ObservableObject {
    //GeniusAPIを使って，アーティスト名，曲名を利用して歌詞を取得するクラス
    //歌詞を表示するhtmlをpublishする
    @Published var lyrics: String?
    //任意のエラーはここに格納
    @Published var error: Error?
    //APIへのアクセスに必要なアクセストークン
    private let accessToken = "8fwXH2466xyOtqtvvJDccN_D5nTHngXUJt7sTcbR-k7Im9hy_OJKoHIj42L0cFA4"
    
    //APIから取得したJSONをparseするための構造体
    // MARK: - Welcome
    struct Welcome: Codable {
        let meta: Meta
        let response: Response
    }
    // MARK: - Meta
    struct Meta: Codable {
        let status: Int
    }

    // MARK: - Response
    struct Response: Codable {
        let hits: [Hit]
        
    }

    // MARK: - Hit
    struct Hit: Codable {
        let index, type: String
        let result: Result
    }

    // MARK: - Result
    struct Result: Codable {
        let artistNames, fullTitle: String
        let id: Int
        let lyricsState, path: String

        enum CodingKeys: String, CodingKey {
            case artistNames = "artist_names"
            case fullTitle = "full_title"
            case id
            case lyricsState = "lyrics_state"
            case path
        }
    }
    /*
     @param artist:アーティスト名
     @param song:曲名
     アーティスト名，曲名でGeniusAPIを叩く
     検索結果が取得できなければ，曲名だけでAPIを叩く
     */
    func fetchLyrics (artist:String, song:String) {
        Task {
            if let id = await getSongId(artist: artist, song: song){
                await getLyric(id: id)
            }else {
                if let id = await getSongId(song: song){
                    await getLyric(id: id)
                }else{
                    DispatchQueue.main.async {
                        self.error = myErrors.noIdError
                    }
                }
            }
        }
    }
    
    /*
     @param artist:アーティスト名
     @param song:曲名
     @return int: 曲のid
     
     アーティスト名，曲名でGeniusAPIを叩き，曲のidを所得
     */
    private func getSongId (artist:String, song:String) async -> Int? {
        //最初にアーティスト名，曲名から曲を検索し，idを得る関数
        //検索結果が得られなかった場合はnilを返す
        
        //URLを作成
        let endpoint = "https://api.genius.com/search?q="
        let accessTokenpoint = "&access_token=" + accessToken
        let urlstr = (endpoint + artist + " " + song + accessTokenpoint).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlstr)!
        //APIから曲の候補を取得
        var request = URLRequest(url:url)
        request.httpMethod = "GET"
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let welcome: Welcome = try JSONDecoder().decode(Welcome.self, from: data)
            var songCandidates: [Hit] = welcome.response.hits
            
            songCandidates = chooseCandidate(artist: artist, song: song, candidates: songCandidates)
            
            if let candidate = songCandidates.first {
                return candidate.result.id
            }else {
                return nil
            }
        }catch {
            //エラーの場合はプロパティに格納
            self.error = error
            return nil
        }
    }
    
    /*
     @param song:曲名
     @return int: 曲のid
     
     アーティスト名，曲名でGeniusAPIを叩き，曲のidを所得
     */
    private func getSongId(song:String) async -> Int? {
        //アーティスト名を含めた検索で検索結果が出なかった場合に使う関数
        
        //URLを作成
        let endpoint = "https://api.genius.com/search?q="
        let accessTokenpoint = "&access_token=" + accessToken
        let urlstr = (endpoint + song + accessTokenpoint).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlstr)!
        //APIから曲の候補を取得
        var request = URLRequest(url:url)
        request.httpMethod = "GET"
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let welcome: Welcome = try JSONDecoder().decode(Welcome.self, from: data)
            var songCandidates: [Hit] = welcome.response.hits
            
            songCandidates = chooseCandidate(song: song, candidates: songCandidates)
            
            if let candidate = songCandidates.first {
                return candidate.result.id
            }else {
                return nil
            }
        }catch {
            //エラーの場合はプロパティに格納
            self.error = error
            return nil
        }
        
    }
    
    /*
     @param id:曲のid
     曲のidから，プロパティlyricsに歌詞情報を格納する
     */
    private func getLyric (id: Int) async -> (){
        //曲のidから歌詞のhtmlを返す関数
        
        //urlの作成
        let endpoint = "https://genius.com/songs/ /embed.js"
        let separatedEndpoint = endpoint.components(separatedBy: " ")
        let urlStr = separatedEndpoint[0] + String(id) + separatedEndpoint[1]
        let url = URL(string: urlStr)!
        
        //リスエストを作成
        var request = URLRequest(url:url)
        request.httpMethod = "GET"
        //ヘッダとしてアクセストークンを渡す
        request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let jscode = String(data: data, encoding: .utf8)!
            //jscodeはjsコードなので，ここから歌詞のhtmlを抜き出す
            if let htmlcode = gethtmlFromjs(js: jscode){
                let escapedhtmlcode = deleteEscapeSequence(string: htmlcode)
                DispatchQueue.main.async {
                    self.lyrics = self.removeHtmlTag(string: escapedhtmlcode)
                }
            }
            
        }catch {
            //エラーの場合はプロパティに格納
            self.error = error
        }
    }
    
    
    private func gethtmlFromjs (js: String)-> String? {
        //jsコードから歌詞を表示する部分のhtmlを抜き出す関数
        //<p>タグのレンジを取得
        if let ptagStartRange = js.range(of: "<p>"){
            //<p>タグ以前の部分を排除
            let fromPtagjs = js[ptagStartRange.lowerBound...]
            //<\p>のレンジを取得
            if let ptagEndRange = fromPtagjs.range(of: "<\\/p>"){
                //<p><\p>に囲われた部分の内容を格納
                return String(fromPtagjs[..<(ptagEndRange.upperBound)])
            }else{return nil}
        }else{return nil}
    }
    
    private func deleteEscapeSequence (string: String) -> String {
        //javascriptのエスケープシーケンスを処理する関数
        var res = string
        while(res.contains("\\\\")){
            res = res.replacingOccurrences(of: "\\\\", with: "\\")
        }
        res = res.replacingOccurrences(of: "\\\"", with: "\"")
        res = res.replacingOccurrences(of: "\\\'", with: "\'")
        res = res.replacingOccurrences(of: #"\`"#, with: #"`"#)
        res = res.replacingOccurrences(of: "\\/", with: "/")
        res = res.replacingOccurrences(of: "\\n", with: "\n")
        return res
    }
    
    private func chooseCandidate (artist:String, song:String, candidates:[Hit]) -> [Hit] {
        //曲の検索結果の中から，候補を絞る
        //artist名が含まれていないものを削除
        //曲名が含まれていないものを削除
        //全角スペースと半角スペースを消して前処理
        
        var copiedCandidates: [Hit] = candidates, copiedartist:String, copiedsong:String
        
        copiedartist = artist.replacingOccurrences(of: " ", with: "")
        copiedartist = copiedartist.replacingOccurrences(of: "　", with: "")
        
        copiedsong = song.replacingOccurrences(of: " ", with: "")
        copiedsong = copiedsong.replacingOccurrences(of: "　", with: "")
        
        for copiedCandidate in copiedCandidates {
            print(copiedCandidate.result.fullTitle)
        }
        
        copiedCandidates.removeAll(where: {
            !$0.result.artistNames.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "　", with: "").contains(artist) ||
            !$0.result.fullTitle.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "　", with: "").contains(copiedsong) ||
            $0.result.fullTitle.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "　", with: "").contains("Instrumental")
        })
        
        for copiedCandidate in copiedCandidates {
            print(copiedCandidate.result.fullTitle)
        }
        
        return copiedCandidates
        
    }
    
    private func chooseCandidate (song:String, candidates:[Hit]) -> [Hit] {
        //曲名だけの場合の候補の絞り込み
        //曲の検索結果の中から，候補を絞る
        //曲名が含まれていないものを削除
        //アーティスト名にGeniusが含まれる，翻訳と思われるものを削除
        //全角スペースと半角スペースを消して前処理
        
        var copiedCandidates: [Hit] = candidates, copiedsong:String
        
        copiedsong = song.replacingOccurrences(of: " ", with: "")
        copiedsong = copiedsong.replacingOccurrences(of: "　", with: "")
        
        
        
        
        copiedCandidates.removeAll(where: {
            $0.result.artistNames.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "　", with: "").contains("Genius") ||
            !$0.result.fullTitle.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "　", with: "").contains(copiedsong) ||
            $0.result.fullTitle.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "　", with: "").contains("Instrumental")
        })
        
        return copiedCandidates
        
    }
    
    /*
      文字列のhtmlタグ(<>で囲まれた部分)を削除する再帰関数
        removeOne
      @param  string - htmlの文字列
      @return string - htmlタグを削除した文字列
    */
    private func removeHtmlTag(string: String) -> String {
        
        let removedString = removeOneHtmlTag(string: string)
        if(string == removedString){
            return removedString
        }else{
            return removeHtmlTag(string: removedString)
        }
    }
    /*
      文字列のhtmlタグ(<>で囲まれた部分)を一つだけ削除する関数
      @param  string - htmlの文字列
      @return string - htmlタグを削除した文字列
    */
    private func removeOneHtmlTag (string: String) -> String {
        var copiedString = string
        if let from = copiedString.firstIndex(of: "<"){
            if let to = copiedString.firstIndex(of: ">"){
                if(from.utf16Offset(in: copiedString) < to.utf16Offset(in: copiedString)){
                    copiedString.removeSubrange(from ... to)
                    return copiedString
                }else{
                    return string
                }
            }else {
                return string
            }
        }else {
            return string
        }
    }
    
    /*
     @param  artist - アーティスト名
     @param song - 曲名
     @return URL - googleで歌詞を検索するURL
     APIで歌詞情報が得られなかった場合 or 歌詞情報が誤っている場合に，google検索のURLを設置する
    */
    func googleLyrics (artist: String, song: String) -> URL? {
        let urlString = ("https://www.google.com/search?q=" + artist + "+" + song + "+歌詞").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return URL(string: urlString)
        
    }
    
    enum myErrors: Error, LocalizedError {
        case noIdError
        
        var errorDescription: String? {
                switch self {
                case .noIdError: return "曲情報が取得できませんでした．"
                }
            }
    }
}
