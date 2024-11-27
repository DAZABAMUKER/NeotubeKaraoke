//
//  yt_main.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 10/10/23.
//

import Foundation

class Yt_main {
    
    var url: String
    var extract = Extract()
    
    init(url: String) {
        self.url = url
    }
    
    func streams() -> StreamQuary {
        check_availability()
        return StreamQuary()
    }
    
    func check_availability() {
           /*
         Check whether the video is available.
         Raises different exceptions based on why the video is unavailable,
         otherwise does nothing.
         */
//        let status, messages = Extract.playabilityStatus(video_id: "")
//
//                for reason in messages:
//                    if status == 'UNPLAYABLE':
//                        if reason == (
//                            'Join this channel to get access to members-only content '
//                            'like this video, and other exclusive perks.'
//                        ):
//                            raise exceptions.MembersOnly(video_id=self.video_id)
//                        elif reason == 'This live stream recording is not available.':
//                            raise exceptions.RecordingUnavailable(video_id=self.video_id)
//                        else:
//                            raise exceptions.VideoUnavailable(video_id=self.video_id)
//                    elif status == 'LOGIN_REQUIRED':
//                        if reason == (
//                            'This is a private video. '
//                            'Please sign in to verify that you may see it.'
//                        ):
//                            raise exceptions.VideoPrivate(video_id=self.video_id)
//                    elif status == 'ERROR':
//                        if reason == 'Video unavailable':
//                            raise exceptions.VideoUnavailable(video_id=self.video_id)
//                    elif status == 'LIVE_STREAM':
//                        raise exceptions.LiveStreamError(video_id=self.video_id)
    }
    
    func get_Parse() {
        
    }
}
