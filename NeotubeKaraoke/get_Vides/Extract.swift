//
//  Extract.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 10/10/23.
//

import Foundation

class Extract {
    func initial_player_response(watch_html: String) -> String {
        
        var patterns = [
            #"window\[['\"]ytInitialPlayerResponse['\"]]\s*=\s*"#,
            #"ytInitialPlayerResponse\s*=\s*"#
        ]
        
        for pattern in patterns {
            do {
                
            }
            catch {
                
            }
        }
        return ""
    }
}
