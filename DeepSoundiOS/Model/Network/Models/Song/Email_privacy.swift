/* 
Copyright (c) 2023 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation

class Email_privacy : Codable {
    
    let email_on_follow_user : MultipleValues?
    let email_on_liked_track : MultipleValues?
    let email_on_liked_comment : MultipleValues?
    let email_on_artist_status_changed : MultipleValues?
    let email_on_receipt_status_changed : MultipleValues?
    let email_on_new_track : MultipleValues?
    let email_on_reviewed_track : MultipleValues?
    let email_on_comment_replay_mention : MultipleValues?
    let email_on_comment_mention : MultipleValues?
    
    enum CodingKeys: String, CodingKey {
        
        case email_on_follow_user = "email_on_follow_user"
        case email_on_liked_track = "email_on_liked_track"
        case email_on_liked_comment = "email_on_liked_comment"
        case email_on_artist_status_changed = "email_on_artist_status_changed"
        case email_on_receipt_status_changed = "email_on_receipt_status_changed"
        case email_on_new_track = "email_on_new_track"
        case email_on_reviewed_track = "email_on_reviewed_track"
        case email_on_comment_replay_mention = "email_on_comment_replay_mention"
        case email_on_comment_mention = "email_on_comment_mention"
    }
    
}
