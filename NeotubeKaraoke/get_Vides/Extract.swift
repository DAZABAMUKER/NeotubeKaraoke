//
//  Extract.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 10/10/23.
//

import Foundation

class Extract {
    func initial_player_response(watch_html: String) -> String {
        /*Extract the ytInitialPlayerResponse json from the watch_html page.

            This mostly contains metadata necessary for rendering the page on-load,
            such as video information, copyright notices, etc.

            @param watch_html: Html of the watch page
            @return:
            */
        let patterns = [
            //#"window\[['\"]ytInitialPlayerResponse['\"]]\s*=\s*"#,
            //#"window\[['"]ytInitialPlayerResponse['"]\]\s*=\s*"#,
            //#"ytInitialPlayerResponse\s*=\s*"#,
            #"jsUrl":"(.*?)"#,
            #"ytInitialPlayerResponse\s*=\s*"#
        ]
        for pattern in patterns {
            do {
                Parse().parse_for_object(html: watch_html, preceding_regex: pattern)
            } catch {
                return "HTML could not be parsed"
            }
        }
//            do {
//                
//            }
//            catch {
//                
//            }
//        }
        return ""
    }
    
    func get_ytplayer_config(watch_html: String){
        /*
         Get the YouTube player configuration data from the watch html.

            Extract the ``ytplayer_config``, which is json data embedded within the
            watch html and serves as the primary source of obtaining the stream
            manifest data.

            :param str html:
                The html contents of the watch page.
            :rtype: str
            :returns:
                Substring of the html containing the encoded manifest data.
            */
        let patterns = [
            //#"window\[['\"]ytInitialPlayerResponse['\"]]\s*=\s*"#,
            //#"window\[['"]ytInitialPlayerResponse['"]\]\s*=\s*"#,
            //#"ytInitialPlayerResponse\s*=\s*"#,
            #"ytplayer\.config\s*=\s*"#,
            #"ytInitialPlayerResponse\s*=\s*"#
        ]
        for pattern in patterns {
            do {
                Parse().parse_for_object(html: watch_html, preceding_regex: pattern)
            } catch {
                print(#function, error)
                //return "HTML could not be parsed"
            }
        }
    }
    
    
    func playabilityStatus(video_id: String) {
        /*Return the playability status and status explanation of a video.

        For example, a video may have a status of LOGIN_REQUIRED, and an explanation
        of "This is a private video. Please sign in to verify that you may see it."

        This explanation is what gets incorporated into the media player overlay.

        :param str watch_html:
            The html contents of the watch page.
        :rtype: bool
        :returns:
            Playability status and reason of the video.
        */
        
        let PlayerResponse = initial_player_response(watch_html: "watch_html")
        
    }
    
}
