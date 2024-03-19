import Foundation

struct OptionsData : Codable {
    
	let theme : String?
	let censored_words : String?
	let title : String?
	let name : String?
	let keyword : String?
	let email : String?
	let description : String?
	let validation : String?
	let recaptcha : String?
	let recaptcha_key : String?
	let language : String?
	let google_app_ID : String?
	let google_app_key : String?
	let facebook_app_ID : String?
	let facebook_app_key : String?
	let twitter_app_ID : String?
	let twitter_app_key : String?
	let smtp_or_mail : String?
	let smtp_host : String?
	let smtp_username : String?
	let smtp_password : String?
	let smtp_encryption : String?
	let smtp_port : String?
	let delete_account : String?
	let last_admin_collection : String?
	let user_statics : String?
	let audio_statics : String?
	let user_registration : String?
	let verification_badge : String?
	let fb_login : String?
	let tw_login : String?
	let plus_login : String?
	let wowonder_app_ID : String?
	let wowonder_app_key : String?
	let wowonder_domain_uri : String?
	let wowonder_login : String?
	let wowonder_img : String?
	let google : String?
	let last_created_sitemap : String?
	let is_ok : String?
	let go_pro : String?
	let paypal_id : String?
	let paypal_secret : String?
	let paypal_mode : String?
	let last_backup : String?
	let user_ads : String?
	let max_upload : String?
	let s3_upload : String?
	let s3_bucket_name : String?
	let amazone_s3_key : String?
	let amazone_s3_s_key : String?
	let region : String?
	let apps_api_key : String?
	let ffmpeg_system : String?
	let ffmpeg_binary_file : String?
	let user_max_upload : String?
	let convert_speed : String?
	let night_mode : String?
	let ftp_host : String?
	let ftp_port : String?
	let ftp_username : String?
	let ftp_password : String?
	let ftp_upload : String?
	let ftp_endpoint : String?
	let ftp_path : String?
	let currency : String?
	let commission : String?
	let pro_upload_limit : String?
	let pro_price : String?
	let server_key : String?
	let facebook_url : String?
	let twitter_url : String?
	let google_url : String?
	let currency_symbol : String?
	let maintenance_mode : String?
	let auto_friend_users : String?
	let waves_color : String?
	let total_songs : String?
	let total_albums : String?
	let total_plays : String?
	let total_sales : String?
	let total_users : String?
	let total_artists : String?
	let total_playlists : String?
	let total_unactive_users : String?
	let songs_statics : String?
	let version : String?
	let artist_sell : String?
	let stripe_version : String?
	let stripe_secret : String?
	let bank_payment : String?
	let bank_transfer_note : String?
	let who_can_download : String?
	let stripe_currency : String?
	let paypal_currency : String?
	let push : String?
	let android_push_native : String?
	let ios_push_native : String?
	let android_m_push_id : String?
	let android_m_push_key : String?
	let ios_m_push_id : String?
	let ios_m_push_key : String?
	let displaymode : String?
	let bank_description : String?
	let stripe_payment : String?
	let paypal_payment : String?
	let multiple_upload : String?
	let usr_v_mon : String?
	let stripe_id : String?
	let ad_v_price : String?
	let pub_price : String?
	let ad_c_price : String?
	let sound_cloud_client_id : String?
	let soundcloud_login : String?
	let sound_cloud_client_secret : String?
	let emailNotification : String?
	let login_auth : String?
	let two_factor : String?
	let two_factor_type : String?
	let sms_twilio_username : String?
	let sms_twilio_password : String?
	let sms_t_phone_number : String?
	let sms_phone_number : String?
	let rapidapi_key : String?
	let soundcloud_go : String?
	let soundcloud_import : String?
	let radio_station_import : String?
	let affiliate_system : String?
	let affiliate_type : String?
	let amount_ref : String?
	let amount_percent_ref : String?
	let discover_land : String?
	let itunes_import : String?
	let itunes_affiliate : String?
	let itunes_partner_token : String?
	let deezer_import : String?
	let audio_ads : String?
	let who_audio_ads : String?
	let who_can_upload : String?
	let android_n_push_id : String?
	let android_n_push_key : String?
	let ios_n_push_id : String?
	let ios_n_push_key : String?
	let web_push_id : String?
	let web_push_key : String?
	let allow_user_create_blog : String?
	let point_system : String?
	let point_system_comment_cost : String?
	let point_system_upload_cost : String?
	let point_system_replay_comment_cost : String?
	let point_system_like_track_cost : String?
	let point_system_dislike_track_cost : String?
	let point_system_like_comment_cost : String?
	let point_system_repost_cost : String?
	let point_system_track_download_cost : String?
	let point_system_like_blog_comment_cost : String?
	let point_system_unlike_comment_cost : String?
	let point_system_unlike_blog_comment_cost : String?
	let point_system_import_cost : String?
	let point_system_purchase_track_cost : String?
	let point_system_go_pro_cost : String?
	let point_system_review_track_cost : String?
	let point_system_report_track_cost : String?
	let point_system_report_comment_cost : String?
	let point_system_add_to_playlist_cost : String?
	let point_system_create_new_playlist_cost : String?
	let point_system_update_profile_picture_cost : String?
	let point_system_update_profile_cover_cost : String?
	let point_system_points_to_dollar : String?
	let prevent_system : String?
	let bad_login_limit : String?
	let lock_time : String?
	let fame_system : String?
	let views_count : String?
	let donate_system : String?
	let tag_artist_system : String?
	let maxCharacters : String?
	let cashfree_payment : String?
	let cashfree_mode : String?
	let cashfree_client_key : String?
	let cashfree_secret_key : String?
	let paystack_payment : String?
	let paystack_secret_key : String?
	let razorpay_payment : String?
	let razorpay_key_id : String?
	let razorpay_key_secret : String?
	let paysera_payment : String?
	let paysera_mode : String?
	let paysera_project_id : String?
	let paysera_sign_password : String?
	let checkout_payment : String?
	let checkout_mode : String?
	let checkout_currency : String?
	let checkout_seller_id : String?
	let checkout_publishable_key : String?
	let checkout_private_key : String?
	let iyzipay_payment : String?
	let iyzipay_mode : String?
	let iyzipay_key : String?
	let iyzipay_secret_key : String?
	let iyzipay_buyer_id : String?
	let iyzipay_buyer_name : String?
	let iyzipay_buyer_surname : String?
	let iyzipay_buyer_gsm_number : String?
	let iyzipay_buyer_email : String?
	let iyzipay_identity_number : String?
	let iyzipay_address : String?
	let iyzipay_city : String?
	let iyzipay_country : String?
	let iyzipay_zip : String?
	let payu_payment : String?
	let payu_mode : String?
	let payu_merchant_id : String?
	let payu_secret_key : String?
	let payu_buyer_name : String?
	let payu_buyer_surname : String?
	let payu_buyer_gsm_number : String?
	let payu_buyer_email : String?
	let securionpay_payment : String?
	let securionpay_public_key : String?
	let securionpay_secret_key : String?
	let authorize_payment : String?
	let authorize_test_mode : String?
	let authorize_login_id : String?
	let authorize_transaction_key : String?
	let invite_links_system : String?
	let user_links_limit : String?
	let expire_user_links : String?
	let event_system : String?
	let channel_trailer : String?
	let channel_trailer_upload : String?
	let story_system : String?
	let story_price : String?
	let store_system : String?
	let store_review_system : String?
	let store_commission : String?
	let linkedin_login : String?
	let vkontakte_login : String?
	let instagram_login : String?
	let qq_login : String?
	let wechat_login : String?
	let discord_login : String?
	let mailru_login : String?
	let linkedinAppId : String?
	let linkedinAppKey : String?
	let vkontakteAppId : String?
	let vkontakteAppKey : String?
	let instagramAppId : String?
	let instagramAppkey : String?
	let qqAppId : String?
	let qqAppkey : String?
	let weChatAppId : String?
	let weChatAppkey : String?
	let discordAppId : String?
	let discordAppkey : String?
	let mailruAppId : String?
	let mailruAppkey : String?
	let event_commission : String?
	let youtube_import : String?
	let youtube_video : String?
	let youtube_key : String?
	let spaces : String?
	let space_name : String?
	let spaces_key : String?
	let spaces_secret : String?
	let space_region : String?
	let size_issue : String?
	let seo : String?
	let points_to : String?
	let point_system_listen_to_song_cost : String?
	let currency_array : String?
	let currency_symbol_array : String?
	let google_refreshToken : String?
	let google_ClientId : String?
	let google_ClientSecret : String?
	let google_drive : String?
	let fortumo_payment : String?
	let fortumo_service_id : String?
	let aamarpay_payment : String?
	let aamarpay_mode : String?
	let aamarpay_store_id : String?
	let aamarpay_signature_key : String?
	let ngenius_payment : String?
	let ngenius_mode : String?
	let ngenius_api_key : String?
	let ngenius_outlet_id : String?
	let coinbase_payment : String?
	let coinbase_key : String?
	let coinpayments : String?
	let coinpayments_secret : String?
	let coinpayments_public_key : String?
	let coinpayments_coin : String?
	let coinpayments_coins : String?
	let password_complexity_system : String?
	let remember_device : String?
	let auto_username : String?
	let yoomoney_payment : String?
	let yoomoney_wallet_id : String?
	let yoomoney_notifications_secret : String?
    let withdrawal_payment_method : [String: IntString]?
	let custom_name : String?
	let who_can_sell : String?
	let who_can_multi_upload : String?
	let who_can_blog : String?
	let who_can_station_import : String?
	let who_can_soundcloud_import : String?
	let who_can_deezer_import : String?
	let who_can_itunes_import : String?
	let who_can_youtube_import : String?
	let who_can_user_ads : String?
	let who_can_event_system : String?
	let who_can_story_system : String?
	let who_can_store_system : String?
	let who_can_point_system : String?
	let who_can_donate_system : String?
	let developer_mode : String?
	let wasabi_storage : String?
	let wasabi_bucket_name : String?
	let wasabi_access_key : String?
	let wasabi_secret_key : String?
	let backblaze_storage : String?
	let backblaze_bucket_id : String?
	let backblaze_bucket_name : String?
	let backblaze_region : String?
	let backblaze_access_key_id : String?
	let backblaze_access_key : String?
	let amazon_endpoint : String?
	let spaces_endpoint : String?
	let backblaze_endpoint : String?
	let wasabi_endpoint : String?
	let cronjob_last_run : String?
	let logo_cache : String?
	let m_withdrawal : String?
	let wasabi_bucket_region : String?
	let fluttewave_payment : String?
	let fluttewave_secret_key : String?
	let point_system_admob_cost : String?
	let developers_page : String?
	let reserved_usernames_system : String?
	let reserved_usernames : String?
	let kkbox_import : String?
	let main_color : String?
	let second_color : String?
	let theme_url : String?
	let site_url : String?
	let ajax_url : String?
	let script_version : String?
    let blog_categories : [String: String]?
    let products_categories : ProductsCategoriesUnion?

	enum CodingKeys: String, CodingKey {

		case theme = "theme"
		case censored_words = "censored_words"
		case title = "title"
		case name = "name"
		case keyword = "keyword"
		case email = "email"
		case description = "description"
		case validation = "validation"
		case recaptcha = "recaptcha"
		case recaptcha_key = "recaptcha_key"
		case language = "language"
		case google_app_ID = "google_app_ID"
		case google_app_key = "google_app_key"
		case facebook_app_ID = "facebook_app_ID"
		case facebook_app_key = "facebook_app_key"
		case twitter_app_ID = "twitter_app_ID"
		case twitter_app_key = "twitter_app_key"
		case smtp_or_mail = "smtp_or_mail"
		case smtp_host = "smtp_host"
		case smtp_username = "smtp_username"
		case smtp_password = "smtp_password"
		case smtp_encryption = "smtp_encryption"
		case smtp_port = "smtp_port"
		case delete_account = "delete_account"
		case last_admin_collection = "last_admin_collection"
		case user_statics = "user_statics"
		case audio_statics = "audio_statics"
		case user_registration = "user_registration"
		case verification_badge = "verification_badge"
		case fb_login = "fb_login"
		case tw_login = "tw_login"
		case plus_login = "plus_login"
		case wowonder_app_ID = "wowonder_app_ID"
		case wowonder_app_key = "wowonder_app_key"
		case wowonder_domain_uri = "wowonder_domain_uri"
		case wowonder_login = "wowonder_login"
		case wowonder_img = "wowonder_img"
		case google = "google"
		case last_created_sitemap = "last_created_sitemap"
		case is_ok = "is_ok"
		case go_pro = "go_pro"
		case paypal_id = "paypal_id"
		case paypal_secret = "paypal_secret"
		case paypal_mode = "paypal_mode"
		case last_backup = "last_backup"
		case user_ads = "user_ads"
		case max_upload = "max_upload"
		case s3_upload = "s3_upload"
		case s3_bucket_name = "s3_bucket_name"
		case amazone_s3_key = "amazone_s3_key"
		case amazone_s3_s_key = "amazone_s3_s_key"
		case region = "region"
		case apps_api_key = "apps_api_key"
		case ffmpeg_system = "ffmpeg_system"
		case ffmpeg_binary_file = "ffmpeg_binary_file"
		case user_max_upload = "user_max_upload"
		case convert_speed = "convert_speed"
		case night_mode = "night_mode"
		case ftp_host = "ftp_host"
		case ftp_port = "ftp_port"
		case ftp_username = "ftp_username"
		case ftp_password = "ftp_password"
		case ftp_upload = "ftp_upload"
		case ftp_endpoint = "ftp_endpoint"
		case ftp_path = "ftp_path"
		case currency = "currency"
		case commission = "commission"
		case pro_upload_limit = "pro_upload_limit"
		case pro_price = "pro_price"
		case server_key = "server_key"
		case facebook_url = "facebook_url"
		case twitter_url = "twitter_url"
		case google_url = "google_url"
		case currency_symbol = "currency_symbol"
		case maintenance_mode = "maintenance_mode"
		case auto_friend_users = "auto_friend_users"
		case waves_color = "waves_color"
		case total_songs = "total_songs"
		case total_albums = "total_albums"
		case total_plays = "total_plays"
		case total_sales = "total_sales"
		case total_users = "total_users"
		case total_artists = "total_artists"
		case total_playlists = "total_playlists"
		case total_unactive_users = "total_unactive_users"
		case songs_statics = "songs_statics"
		case version = "version"
		case artist_sell = "artist_sell"
		case stripe_version = "stripe_version"
		case stripe_secret = "stripe_secret"
		case bank_payment = "bank_payment"
		case bank_transfer_note = "bank_transfer_note"
		case who_can_download = "who_can_download"
		case stripe_currency = "stripe_currency"
		case paypal_currency = "paypal_currency"
		case push = "push"
		case android_push_native = "android_push_native"
		case ios_push_native = "ios_push_native"
		case android_m_push_id = "android_m_push_id"
		case android_m_push_key = "android_m_push_key"
		case ios_m_push_id = "ios_m_push_id"
		case ios_m_push_key = "ios_m_push_key"
		case displaymode = "displaymode"
		case bank_description = "bank_description"
		case stripe_payment = "stripe_payment"
		case paypal_payment = "paypal_payment"
		case multiple_upload = "multiple_upload"
		case usr_v_mon = "usr_v_mon"
		case stripe_id = "stripe_id"
		case ad_v_price = "ad_v_price"
		case pub_price = "pub_price"
		case ad_c_price = "ad_c_price"
		case sound_cloud_client_id = "sound_cloud_client_id"
		case soundcloud_login = "soundcloud_login"
		case sound_cloud_client_secret = "sound_cloud_client_secret"
		case emailNotification = "emailNotification"
		case login_auth = "login_auth"
		case two_factor = "two_factor"
		case two_factor_type = "two_factor_type"
		case sms_twilio_username = "sms_twilio_username"
		case sms_twilio_password = "sms_twilio_password"
		case sms_t_phone_number = "sms_t_phone_number"
		case sms_phone_number = "sms_phone_number"
		case rapidapi_key = "rapidapi_key"
		case soundcloud_go = "soundcloud_go"
		case soundcloud_import = "soundcloud_import"
		case radio_station_import = "radio_station_import"
		case affiliate_system = "affiliate_system"
		case affiliate_type = "affiliate_type"
		case amount_ref = "amount_ref"
		case amount_percent_ref = "amount_percent_ref"
		case discover_land = "discover_land"
		case itunes_import = "itunes_import"
		case itunes_affiliate = "itunes_affiliate"
		case itunes_partner_token = "itunes_partner_token"
		case deezer_import = "deezer_import"
		case audio_ads = "audio_ads"
		case who_audio_ads = "who_audio_ads"
		case who_can_upload = "who_can_upload"
		case android_n_push_id = "android_n_push_id"
		case android_n_push_key = "android_n_push_key"
		case ios_n_push_id = "ios_n_push_id"
		case ios_n_push_key = "ios_n_push_key"
		case web_push_id = "web_push_id"
		case web_push_key = "web_push_key"
		case allow_user_create_blog = "allow_user_create_blog"
		case point_system = "point_system"
		case point_system_comment_cost = "point_system_comment_cost"
		case point_system_upload_cost = "point_system_upload_cost"
		case point_system_replay_comment_cost = "point_system_replay_comment_cost"
		case point_system_like_track_cost = "point_system_like_track_cost"
		case point_system_dislike_track_cost = "point_system_dislike_track_cost"
		case point_system_like_comment_cost = "point_system_like_comment_cost"
		case point_system_repost_cost = "point_system_repost_cost"
		case point_system_track_download_cost = "point_system_track_download_cost"
		case point_system_like_blog_comment_cost = "point_system_like_blog_comment_cost"
		case point_system_unlike_comment_cost = "point_system_unlike_comment_cost"
		case point_system_unlike_blog_comment_cost = "point_system_unlike_blog_comment_cost"
		case point_system_import_cost = "point_system_import_cost"
		case point_system_purchase_track_cost = "point_system_purchase_track_cost"
		case point_system_go_pro_cost = "point_system_go_pro_cost"
		case point_system_review_track_cost = "point_system_review_track_cost"
		case point_system_report_track_cost = "point_system_report_track_cost"
		case point_system_report_comment_cost = "point_system_report_comment_cost"
		case point_system_add_to_playlist_cost = "point_system_add_to_playlist_cost"
		case point_system_create_new_playlist_cost = "point_system_create_new_playlist_cost"
		case point_system_update_profile_picture_cost = "point_system_update_profile_picture_cost"
		case point_system_update_profile_cover_cost = "point_system_update_profile_cover_cost"
		case point_system_points_to_dollar = "point_system_points_to_dollar"
		case prevent_system = "prevent_system"
		case bad_login_limit = "bad_login_limit"
		case lock_time = "lock_time"
		case fame_system = "fame_system"
		case views_count = "views_count"
		case donate_system = "donate_system"
		case tag_artist_system = "tag_artist_system"
		case maxCharacters = "maxCharacters"
		case cashfree_payment = "cashfree_payment"
		case cashfree_mode = "cashfree_mode"
		case cashfree_client_key = "cashfree_client_key"
		case cashfree_secret_key = "cashfree_secret_key"
		case paystack_payment = "paystack_payment"
		case paystack_secret_key = "paystack_secret_key"
		case razorpay_payment = "razorpay_payment"
		case razorpay_key_id = "razorpay_key_id"
		case razorpay_key_secret = "razorpay_key_secret"
		case paysera_payment = "paysera_payment"
		case paysera_mode = "paysera_mode"
		case paysera_project_id = "paysera_project_id"
		case paysera_sign_password = "paysera_sign_password"
		case checkout_payment = "checkout_payment"
		case checkout_mode = "checkout_mode"
		case checkout_currency = "checkout_currency"
		case checkout_seller_id = "checkout_seller_id"
		case checkout_publishable_key = "checkout_publishable_key"
		case checkout_private_key = "checkout_private_key"
		case iyzipay_payment = "iyzipay_payment"
		case iyzipay_mode = "iyzipay_mode"
		case iyzipay_key = "iyzipay_key"
		case iyzipay_secret_key = "iyzipay_secret_key"
		case iyzipay_buyer_id = "iyzipay_buyer_id"
		case iyzipay_buyer_name = "iyzipay_buyer_name"
		case iyzipay_buyer_surname = "iyzipay_buyer_surname"
		case iyzipay_buyer_gsm_number = "iyzipay_buyer_gsm_number"
		case iyzipay_buyer_email = "iyzipay_buyer_email"
		case iyzipay_identity_number = "iyzipay_identity_number"
		case iyzipay_address = "iyzipay_address"
		case iyzipay_city = "iyzipay_city"
		case iyzipay_country = "iyzipay_country"
		case iyzipay_zip = "iyzipay_zip"
		case payu_payment = "payu_payment"
		case payu_mode = "payu_mode"
		case payu_merchant_id = "payu_merchant_id"
		case payu_secret_key = "payu_secret_key"
		case payu_buyer_name = "payu_buyer_name"
		case payu_buyer_surname = "payu_buyer_surname"
		case payu_buyer_gsm_number = "payu_buyer_gsm_number"
		case payu_buyer_email = "payu_buyer_email"
		case securionpay_payment = "securionpay_payment"
		case securionpay_public_key = "securionpay_public_key"
		case securionpay_secret_key = "securionpay_secret_key"
		case authorize_payment = "authorize_payment"
		case authorize_test_mode = "authorize_test_mode"
		case authorize_login_id = "authorize_login_id"
		case authorize_transaction_key = "authorize_transaction_key"
		case invite_links_system = "invite_links_system"
		case user_links_limit = "user_links_limit"
		case expire_user_links = "expire_user_links"
		case event_system = "event_system"
		case channel_trailer = "channel_trailer"
		case channel_trailer_upload = "channel_trailer_upload"
		case story_system = "story_system"
		case story_price = "story_price"
		case store_system = "store_system"
		case store_review_system = "store_review_system"
		case store_commission = "store_commission"
		case linkedin_login = "linkedin_login"
		case vkontakte_login = "vkontakte_login"
		case instagram_login = "instagram_login"
		case qq_login = "qq_login"
		case wechat_login = "wechat_login"
		case discord_login = "discord_login"
		case mailru_login = "mailru_login"
		case linkedinAppId = "linkedinAppId"
		case linkedinAppKey = "linkedinAppKey"
		case vkontakteAppId = "VkontakteAppId"
		case vkontakteAppKey = "VkontakteAppKey"
		case instagramAppId = "instagramAppId"
		case instagramAppkey = "instagramAppkey"
		case qqAppId = "qqAppId"
		case qqAppkey = "qqAppkey"
		case weChatAppId = "WeChatAppId"
		case weChatAppkey = "WeChatAppkey"
		case discordAppId = "DiscordAppId"
		case discordAppkey = "DiscordAppkey"
		case mailruAppId = "MailruAppId"
		case mailruAppkey = "MailruAppkey"
		case event_commission = "event_commission"
		case youtube_import = "youtube_import"
		case youtube_video = "youtube_video"
		case youtube_key = "youtube_key"
		case spaces = "spaces"
		case space_name = "space_name"
		case spaces_key = "spaces_key"
		case spaces_secret = "spaces_secret"
		case space_region = "space_region"
		case size_issue = "size_issue"
		case seo = "seo"
		case points_to = "points_to"
		case point_system_listen_to_song_cost = "point_system_listen_to_song_cost"
		case currency_array = "currency_array"
		case currency_symbol_array = "currency_symbol_array"
		case google_refreshToken = "google_refreshToken"
		case google_ClientId = "google_ClientId"
		case google_ClientSecret = "google_ClientSecret"
		case google_drive = "google_drive"
		case fortumo_payment = "fortumo_payment"
		case fortumo_service_id = "fortumo_service_id"
		case aamarpay_payment = "aamarpay_payment"
		case aamarpay_mode = "aamarpay_mode"
		case aamarpay_store_id = "aamarpay_store_id"
		case aamarpay_signature_key = "aamarpay_signature_key"
		case ngenius_payment = "ngenius_payment"
		case ngenius_mode = "ngenius_mode"
		case ngenius_api_key = "ngenius_api_key"
		case ngenius_outlet_id = "ngenius_outlet_id"
		case coinbase_payment = "coinbase_payment"
		case coinbase_key = "coinbase_key"
		case coinpayments = "coinpayments"
		case coinpayments_secret = "coinpayments_secret"
		case coinpayments_public_key = "coinpayments_public_key"
		case coinpayments_coin = "coinpayments_coin"
		case coinpayments_coins = "coinpayments_coins"
		case password_complexity_system = "password_complexity_system"
		case remember_device = "remember_device"
		case auto_username = "auto_username"
		case yoomoney_payment = "yoomoney_payment"
		case yoomoney_wallet_id = "yoomoney_wallet_id"
		case yoomoney_notifications_secret = "yoomoney_notifications_secret"
		case withdrawal_payment_method = "withdrawal_payment_method"
		case custom_name = "custom_name"
		case who_can_sell = "who_can_sell"
		case who_can_multi_upload = "who_can_multi_upload"
		case who_can_blog = "who_can_blog"
		case who_can_station_import = "who_can_station_import"
		case who_can_soundcloud_import = "who_can_soundcloud_import"
		case who_can_deezer_import = "who_can_deezer_import"
		case who_can_itunes_import = "who_can_itunes_import"
		case who_can_youtube_import = "who_can_youtube_import"
		case who_can_user_ads = "who_can_user_ads"
		case who_can_event_system = "who_can_event_system"
		case who_can_story_system = "who_can_story_system"
		case who_can_store_system = "who_can_store_system"
		case who_can_point_system = "who_can_point_system"
		case who_can_donate_system = "who_can_donate_system"
		case developer_mode = "developer_mode"
		case wasabi_storage = "wasabi_storage"
		case wasabi_bucket_name = "wasabi_bucket_name"
		case wasabi_access_key = "wasabi_access_key"
		case wasabi_secret_key = "wasabi_secret_key"
		case backblaze_storage = "backblaze_storage"
		case backblaze_bucket_id = "backblaze_bucket_id"
		case backblaze_bucket_name = "backblaze_bucket_name"
		case backblaze_region = "backblaze_region"
		case backblaze_access_key_id = "backblaze_access_key_id"
		case backblaze_access_key = "backblaze_access_key"
		case amazon_endpoint = "amazon_endpoint"
		case spaces_endpoint = "spaces_endpoint"
		case backblaze_endpoint = "backblaze_endpoint"
		case wasabi_endpoint = "wasabi_endpoint"
		case cronjob_last_run = "cronjob_last_run"
		case logo_cache = "logo_cache"
		case m_withdrawal = "m_withdrawal"
		case wasabi_bucket_region = "wasabi_bucket_region"
		case fluttewave_payment = "fluttewave_payment"
		case fluttewave_secret_key = "fluttewave_secret_key"
		case point_system_admob_cost = "point_system_admob_cost"
		case developers_page = "developers_page"
		case reserved_usernames_system = "reserved_usernames_system"
		case reserved_usernames = "reserved_usernames"
		case kkbox_import = "kkbox_import"
		case main_color = "main_color"
		case second_color = "second_color"
		case theme_url = "theme_url"
		case site_url = "site_url"
		case ajax_url = "ajax_url"
		case script_version = "script_version"
		case blog_categories = "blog_categories"
		case products_categories = "products_categories"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		theme = try values.decodeIfPresent(String.self, forKey: .theme)
		censored_words = try values.decodeIfPresent(String.self, forKey: .censored_words)
		title = try values.decodeIfPresent(String.self, forKey: .title)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		keyword = try values.decodeIfPresent(String.self, forKey: .keyword)
		email = try values.decodeIfPresent(String.self, forKey: .email)
		description = try values.decodeIfPresent(String.self, forKey: .description)
		validation = try values.decodeIfPresent(String.self, forKey: .validation)
		recaptcha = try values.decodeIfPresent(String.self, forKey: .recaptcha)
		recaptcha_key = try values.decodeIfPresent(String.self, forKey: .recaptcha_key)
		language = try values.decodeIfPresent(String.self, forKey: .language)
		google_app_ID = try values.decodeIfPresent(String.self, forKey: .google_app_ID)
		google_app_key = try values.decodeIfPresent(String.self, forKey: .google_app_key)
		facebook_app_ID = try values.decodeIfPresent(String.self, forKey: .facebook_app_ID)
		facebook_app_key = try values.decodeIfPresent(String.self, forKey: .facebook_app_key)
		twitter_app_ID = try values.decodeIfPresent(String.self, forKey: .twitter_app_ID)
		twitter_app_key = try values.decodeIfPresent(String.self, forKey: .twitter_app_key)
		smtp_or_mail = try values.decodeIfPresent(String.self, forKey: .smtp_or_mail)
		smtp_host = try values.decodeIfPresent(String.self, forKey: .smtp_host)
		smtp_username = try values.decodeIfPresent(String.self, forKey: .smtp_username)
		smtp_password = try values.decodeIfPresent(String.self, forKey: .smtp_password)
		smtp_encryption = try values.decodeIfPresent(String.self, forKey: .smtp_encryption)
		smtp_port = try values.decodeIfPresent(String.self, forKey: .smtp_port)
		delete_account = try values.decodeIfPresent(String.self, forKey: .delete_account)
		last_admin_collection = try values.decodeIfPresent(String.self, forKey: .last_admin_collection)
		user_statics = try values.decodeIfPresent(String.self, forKey: .user_statics)
		audio_statics = try values.decodeIfPresent(String.self, forKey: .audio_statics)
		user_registration = try values.decodeIfPresent(String.self, forKey: .user_registration)
		verification_badge = try values.decodeIfPresent(String.self, forKey: .verification_badge)
		fb_login = try values.decodeIfPresent(String.self, forKey: .fb_login)
		tw_login = try values.decodeIfPresent(String.self, forKey: .tw_login)
		plus_login = try values.decodeIfPresent(String.self, forKey: .plus_login)
		wowonder_app_ID = try values.decodeIfPresent(String.self, forKey: .wowonder_app_ID)
		wowonder_app_key = try values.decodeIfPresent(String.self, forKey: .wowonder_app_key)
		wowonder_domain_uri = try values.decodeIfPresent(String.self, forKey: .wowonder_domain_uri)
		wowonder_login = try values.decodeIfPresent(String.self, forKey: .wowonder_login)
		wowonder_img = try values.decodeIfPresent(String.self, forKey: .wowonder_img)
		google = try values.decodeIfPresent(String.self, forKey: .google)
		last_created_sitemap = try values.decodeIfPresent(String.self, forKey: .last_created_sitemap)
		is_ok = try values.decodeIfPresent(String.self, forKey: .is_ok)
		go_pro = try values.decodeIfPresent(String.self, forKey: .go_pro)
		paypal_id = try values.decodeIfPresent(String.self, forKey: .paypal_id)
		paypal_secret = try values.decodeIfPresent(String.self, forKey: .paypal_secret)
		paypal_mode = try values.decodeIfPresent(String.self, forKey: .paypal_mode)
		last_backup = try values.decodeIfPresent(String.self, forKey: .last_backup)
		user_ads = try values.decodeIfPresent(String.self, forKey: .user_ads)
		max_upload = try values.decodeIfPresent(String.self, forKey: .max_upload)
		s3_upload = try values.decodeIfPresent(String.self, forKey: .s3_upload)
		s3_bucket_name = try values.decodeIfPresent(String.self, forKey: .s3_bucket_name)
		amazone_s3_key = try values.decodeIfPresent(String.self, forKey: .amazone_s3_key)
		amazone_s3_s_key = try values.decodeIfPresent(String.self, forKey: .amazone_s3_s_key)
		region = try values.decodeIfPresent(String.self, forKey: .region)
		apps_api_key = try values.decodeIfPresent(String.self, forKey: .apps_api_key)
		ffmpeg_system = try values.decodeIfPresent(String.self, forKey: .ffmpeg_system)
		ffmpeg_binary_file = try values.decodeIfPresent(String.self, forKey: .ffmpeg_binary_file)
		user_max_upload = try values.decodeIfPresent(String.self, forKey: .user_max_upload)
		convert_speed = try values.decodeIfPresent(String.self, forKey: .convert_speed)
		night_mode = try values.decodeIfPresent(String.self, forKey: .night_mode)
		ftp_host = try values.decodeIfPresent(String.self, forKey: .ftp_host)
		ftp_port = try values.decodeIfPresent(String.self, forKey: .ftp_port)
		ftp_username = try values.decodeIfPresent(String.self, forKey: .ftp_username)
		ftp_password = try values.decodeIfPresent(String.self, forKey: .ftp_password)
		ftp_upload = try values.decodeIfPresent(String.self, forKey: .ftp_upload)
		ftp_endpoint = try values.decodeIfPresent(String.self, forKey: .ftp_endpoint)
		ftp_path = try values.decodeIfPresent(String.self, forKey: .ftp_path)
		currency = try values.decodeIfPresent(String.self, forKey: .currency)
		commission = try values.decodeIfPresent(String.self, forKey: .commission)
		pro_upload_limit = try values.decodeIfPresent(String.self, forKey: .pro_upload_limit)
		pro_price = try values.decodeIfPresent(String.self, forKey: .pro_price)
		server_key = try values.decodeIfPresent(String.self, forKey: .server_key)
		facebook_url = try values.decodeIfPresent(String.self, forKey: .facebook_url)
		twitter_url = try values.decodeIfPresent(String.self, forKey: .twitter_url)
		google_url = try values.decodeIfPresent(String.self, forKey: .google_url)
		currency_symbol = try values.decodeIfPresent(String.self, forKey: .currency_symbol)
		maintenance_mode = try values.decodeIfPresent(String.self, forKey: .maintenance_mode)
		auto_friend_users = try values.decodeIfPresent(String.self, forKey: .auto_friend_users)
		waves_color = try values.decodeIfPresent(String.self, forKey: .waves_color)
		total_songs = try values.decodeIfPresent(String.self, forKey: .total_songs)
		total_albums = try values.decodeIfPresent(String.self, forKey: .total_albums)
		total_plays = try values.decodeIfPresent(String.self, forKey: .total_plays)
		total_sales = try values.decodeIfPresent(String.self, forKey: .total_sales)
		total_users = try values.decodeIfPresent(String.self, forKey: .total_users)
		total_artists = try values.decodeIfPresent(String.self, forKey: .total_artists)
		total_playlists = try values.decodeIfPresent(String.self, forKey: .total_playlists)
		total_unactive_users = try values.decodeIfPresent(String.self, forKey: .total_unactive_users)
		songs_statics = try values.decodeIfPresent(String.self, forKey: .songs_statics)
		version = try values.decodeIfPresent(String.self, forKey: .version)
		artist_sell = try values.decodeIfPresent(String.self, forKey: .artist_sell)
		stripe_version = try values.decodeIfPresent(String.self, forKey: .stripe_version)
		stripe_secret = try values.decodeIfPresent(String.self, forKey: .stripe_secret)
		bank_payment = try values.decodeIfPresent(String.self, forKey: .bank_payment)
		bank_transfer_note = try values.decodeIfPresent(String.self, forKey: .bank_transfer_note)
		who_can_download = try values.decodeIfPresent(String.self, forKey: .who_can_download)
		stripe_currency = try values.decodeIfPresent(String.self, forKey: .stripe_currency)
		paypal_currency = try values.decodeIfPresent(String.self, forKey: .paypal_currency)
		push = try values.decodeIfPresent(String.self, forKey: .push)
		android_push_native = try values.decodeIfPresent(String.self, forKey: .android_push_native)
		ios_push_native = try values.decodeIfPresent(String.self, forKey: .ios_push_native)
		android_m_push_id = try values.decodeIfPresent(String.self, forKey: .android_m_push_id)
		android_m_push_key = try values.decodeIfPresent(String.self, forKey: .android_m_push_key)
		ios_m_push_id = try values.decodeIfPresent(String.self, forKey: .ios_m_push_id)
		ios_m_push_key = try values.decodeIfPresent(String.self, forKey: .ios_m_push_key)
		displaymode = try values.decodeIfPresent(String.self, forKey: .displaymode)
		bank_description = try values.decodeIfPresent(String.self, forKey: .bank_description)
		stripe_payment = try values.decodeIfPresent(String.self, forKey: .stripe_payment)
		paypal_payment = try values.decodeIfPresent(String.self, forKey: .paypal_payment)
		multiple_upload = try values.decodeIfPresent(String.self, forKey: .multiple_upload)
		usr_v_mon = try values.decodeIfPresent(String.self, forKey: .usr_v_mon)
		stripe_id = try values.decodeIfPresent(String.self, forKey: .stripe_id)
		ad_v_price = try values.decodeIfPresent(String.self, forKey: .ad_v_price)
		pub_price = try values.decodeIfPresent(String.self, forKey: .pub_price)
		ad_c_price = try values.decodeIfPresent(String.self, forKey: .ad_c_price)
		sound_cloud_client_id = try values.decodeIfPresent(String.self, forKey: .sound_cloud_client_id)
		soundcloud_login = try values.decodeIfPresent(String.self, forKey: .soundcloud_login)
		sound_cloud_client_secret = try values.decodeIfPresent(String.self, forKey: .sound_cloud_client_secret)
		emailNotification = try values.decodeIfPresent(String.self, forKey: .emailNotification)
		login_auth = try values.decodeIfPresent(String.self, forKey: .login_auth)
		two_factor = try values.decodeIfPresent(String.self, forKey: .two_factor)
		two_factor_type = try values.decodeIfPresent(String.self, forKey: .two_factor_type)
		sms_twilio_username = try values.decodeIfPresent(String.self, forKey: .sms_twilio_username)
		sms_twilio_password = try values.decodeIfPresent(String.self, forKey: .sms_twilio_password)
		sms_t_phone_number = try values.decodeIfPresent(String.self, forKey: .sms_t_phone_number)
		sms_phone_number = try values.decodeIfPresent(String.self, forKey: .sms_phone_number)
		rapidapi_key = try values.decodeIfPresent(String.self, forKey: .rapidapi_key)
		soundcloud_go = try values.decodeIfPresent(String.self, forKey: .soundcloud_go)
		soundcloud_import = try values.decodeIfPresent(String.self, forKey: .soundcloud_import)
		radio_station_import = try values.decodeIfPresent(String.self, forKey: .radio_station_import)
		affiliate_system = try values.decodeIfPresent(String.self, forKey: .affiliate_system)
		affiliate_type = try values.decodeIfPresent(String.self, forKey: .affiliate_type)
		amount_ref = try values.decodeIfPresent(String.self, forKey: .amount_ref)
		amount_percent_ref = try values.decodeIfPresent(String.self, forKey: .amount_percent_ref)
		discover_land = try values.decodeIfPresent(String.self, forKey: .discover_land)
		itunes_import = try values.decodeIfPresent(String.self, forKey: .itunes_import)
		itunes_affiliate = try values.decodeIfPresent(String.self, forKey: .itunes_affiliate)
		itunes_partner_token = try values.decodeIfPresent(String.self, forKey: .itunes_partner_token)
		deezer_import = try values.decodeIfPresent(String.self, forKey: .deezer_import)
		audio_ads = try values.decodeIfPresent(String.self, forKey: .audio_ads)
		who_audio_ads = try values.decodeIfPresent(String.self, forKey: .who_audio_ads)
		who_can_upload = try values.decodeIfPresent(String.self, forKey: .who_can_upload)
		android_n_push_id = try values.decodeIfPresent(String.self, forKey: .android_n_push_id)
		android_n_push_key = try values.decodeIfPresent(String.self, forKey: .android_n_push_key)
		ios_n_push_id = try values.decodeIfPresent(String.self, forKey: .ios_n_push_id)
		ios_n_push_key = try values.decodeIfPresent(String.self, forKey: .ios_n_push_key)
		web_push_id = try values.decodeIfPresent(String.self, forKey: .web_push_id)
		web_push_key = try values.decodeIfPresent(String.self, forKey: .web_push_key)
		allow_user_create_blog = try values.decodeIfPresent(String.self, forKey: .allow_user_create_blog)
		point_system = try values.decodeIfPresent(String.self, forKey: .point_system)
		point_system_comment_cost = try values.decodeIfPresent(String.self, forKey: .point_system_comment_cost)
		point_system_upload_cost = try values.decodeIfPresent(String.self, forKey: .point_system_upload_cost)
		point_system_replay_comment_cost = try values.decodeIfPresent(String.self, forKey: .point_system_replay_comment_cost)
		point_system_like_track_cost = try values.decodeIfPresent(String.self, forKey: .point_system_like_track_cost)
		point_system_dislike_track_cost = try values.decodeIfPresent(String.self, forKey: .point_system_dislike_track_cost)
		point_system_like_comment_cost = try values.decodeIfPresent(String.self, forKey: .point_system_like_comment_cost)
		point_system_repost_cost = try values.decodeIfPresent(String.self, forKey: .point_system_repost_cost)
		point_system_track_download_cost = try values.decodeIfPresent(String.self, forKey: .point_system_track_download_cost)
		point_system_like_blog_comment_cost = try values.decodeIfPresent(String.self, forKey: .point_system_like_blog_comment_cost)
		point_system_unlike_comment_cost = try values.decodeIfPresent(String.self, forKey: .point_system_unlike_comment_cost)
		point_system_unlike_blog_comment_cost = try values.decodeIfPresent(String.self, forKey: .point_system_unlike_blog_comment_cost)
		point_system_import_cost = try values.decodeIfPresent(String.self, forKey: .point_system_import_cost)
		point_system_purchase_track_cost = try values.decodeIfPresent(String.self, forKey: .point_system_purchase_track_cost)
		point_system_go_pro_cost = try values.decodeIfPresent(String.self, forKey: .point_system_go_pro_cost)
		point_system_review_track_cost = try values.decodeIfPresent(String.self, forKey: .point_system_review_track_cost)
		point_system_report_track_cost = try values.decodeIfPresent(String.self, forKey: .point_system_report_track_cost)
		point_system_report_comment_cost = try values.decodeIfPresent(String.self, forKey: .point_system_report_comment_cost)
		point_system_add_to_playlist_cost = try values.decodeIfPresent(String.self, forKey: .point_system_add_to_playlist_cost)
		point_system_create_new_playlist_cost = try values.decodeIfPresent(String.self, forKey: .point_system_create_new_playlist_cost)
		point_system_update_profile_picture_cost = try values.decodeIfPresent(String.self, forKey: .point_system_update_profile_picture_cost)
		point_system_update_profile_cover_cost = try values.decodeIfPresent(String.self, forKey: .point_system_update_profile_cover_cost)
		point_system_points_to_dollar = try values.decodeIfPresent(String.self, forKey: .point_system_points_to_dollar)
		prevent_system = try values.decodeIfPresent(String.self, forKey: .prevent_system)
		bad_login_limit = try values.decodeIfPresent(String.self, forKey: .bad_login_limit)
		lock_time = try values.decodeIfPresent(String.self, forKey: .lock_time)
		fame_system = try values.decodeIfPresent(String.self, forKey: .fame_system)
		views_count = try values.decodeIfPresent(String.self, forKey: .views_count)
		donate_system = try values.decodeIfPresent(String.self, forKey: .donate_system)
		tag_artist_system = try values.decodeIfPresent(String.self, forKey: .tag_artist_system)
		maxCharacters = try values.decodeIfPresent(String.self, forKey: .maxCharacters)
		cashfree_payment = try values.decodeIfPresent(String.self, forKey: .cashfree_payment)
		cashfree_mode = try values.decodeIfPresent(String.self, forKey: .cashfree_mode)
		cashfree_client_key = try values.decodeIfPresent(String.self, forKey: .cashfree_client_key)
		cashfree_secret_key = try values.decodeIfPresent(String.self, forKey: .cashfree_secret_key)
		paystack_payment = try values.decodeIfPresent(String.self, forKey: .paystack_payment)
		paystack_secret_key = try values.decodeIfPresent(String.self, forKey: .paystack_secret_key)
		razorpay_payment = try values.decodeIfPresent(String.self, forKey: .razorpay_payment)
		razorpay_key_id = try values.decodeIfPresent(String.self, forKey: .razorpay_key_id)
		razorpay_key_secret = try values.decodeIfPresent(String.self, forKey: .razorpay_key_secret)
		paysera_payment = try values.decodeIfPresent(String.self, forKey: .paysera_payment)
		paysera_mode = try values.decodeIfPresent(String.self, forKey: .paysera_mode)
		paysera_project_id = try values.decodeIfPresent(String.self, forKey: .paysera_project_id)
		paysera_sign_password = try values.decodeIfPresent(String.self, forKey: .paysera_sign_password)
		checkout_payment = try values.decodeIfPresent(String.self, forKey: .checkout_payment)
		checkout_mode = try values.decodeIfPresent(String.self, forKey: .checkout_mode)
		checkout_currency = try values.decodeIfPresent(String.self, forKey: .checkout_currency)
		checkout_seller_id = try values.decodeIfPresent(String.self, forKey: .checkout_seller_id)
		checkout_publishable_key = try values.decodeIfPresent(String.self, forKey: .checkout_publishable_key)
		checkout_private_key = try values.decodeIfPresent(String.self, forKey: .checkout_private_key)
		iyzipay_payment = try values.decodeIfPresent(String.self, forKey: .iyzipay_payment)
		iyzipay_mode = try values.decodeIfPresent(String.self, forKey: .iyzipay_mode)
		iyzipay_key = try values.decodeIfPresent(String.self, forKey: .iyzipay_key)
		iyzipay_secret_key = try values.decodeIfPresent(String.self, forKey: .iyzipay_secret_key)
		iyzipay_buyer_id = try values.decodeIfPresent(String.self, forKey: .iyzipay_buyer_id)
		iyzipay_buyer_name = try values.decodeIfPresent(String.self, forKey: .iyzipay_buyer_name)
		iyzipay_buyer_surname = try values.decodeIfPresent(String.self, forKey: .iyzipay_buyer_surname)
		iyzipay_buyer_gsm_number = try values.decodeIfPresent(String.self, forKey: .iyzipay_buyer_gsm_number)
		iyzipay_buyer_email = try values.decodeIfPresent(String.self, forKey: .iyzipay_buyer_email)
		iyzipay_identity_number = try values.decodeIfPresent(String.self, forKey: .iyzipay_identity_number)
		iyzipay_address = try values.decodeIfPresent(String.self, forKey: .iyzipay_address)
		iyzipay_city = try values.decodeIfPresent(String.self, forKey: .iyzipay_city)
		iyzipay_country = try values.decodeIfPresent(String.self, forKey: .iyzipay_country)
		iyzipay_zip = try values.decodeIfPresent(String.self, forKey: .iyzipay_zip)
		payu_payment = try values.decodeIfPresent(String.self, forKey: .payu_payment)
		payu_mode = try values.decodeIfPresent(String.self, forKey: .payu_mode)
		payu_merchant_id = try values.decodeIfPresent(String.self, forKey: .payu_merchant_id)
		payu_secret_key = try values.decodeIfPresent(String.self, forKey: .payu_secret_key)
		payu_buyer_name = try values.decodeIfPresent(String.self, forKey: .payu_buyer_name)
		payu_buyer_surname = try values.decodeIfPresent(String.self, forKey: .payu_buyer_surname)
		payu_buyer_gsm_number = try values.decodeIfPresent(String.self, forKey: .payu_buyer_gsm_number)
		payu_buyer_email = try values.decodeIfPresent(String.self, forKey: .payu_buyer_email)
		securionpay_payment = try values.decodeIfPresent(String.self, forKey: .securionpay_payment)
		securionpay_public_key = try values.decodeIfPresent(String.self, forKey: .securionpay_public_key)
		securionpay_secret_key = try values.decodeIfPresent(String.self, forKey: .securionpay_secret_key)
		authorize_payment = try values.decodeIfPresent(String.self, forKey: .authorize_payment)
		authorize_test_mode = try values.decodeIfPresent(String.self, forKey: .authorize_test_mode)
		authorize_login_id = try values.decodeIfPresent(String.self, forKey: .authorize_login_id)
		authorize_transaction_key = try values.decodeIfPresent(String.self, forKey: .authorize_transaction_key)
		invite_links_system = try values.decodeIfPresent(String.self, forKey: .invite_links_system)
		user_links_limit = try values.decodeIfPresent(String.self, forKey: .user_links_limit)
		expire_user_links = try values.decodeIfPresent(String.self, forKey: .expire_user_links)
		event_system = try values.decodeIfPresent(String.self, forKey: .event_system)
		channel_trailer = try values.decodeIfPresent(String.self, forKey: .channel_trailer)
		channel_trailer_upload = try values.decodeIfPresent(String.self, forKey: .channel_trailer_upload)
		story_system = try values.decodeIfPresent(String.self, forKey: .story_system)
		story_price = try values.decodeIfPresent(String.self, forKey: .story_price)
		store_system = try values.decodeIfPresent(String.self, forKey: .store_system)
		store_review_system = try values.decodeIfPresent(String.self, forKey: .store_review_system)
		store_commission = try values.decodeIfPresent(String.self, forKey: .store_commission)
		linkedin_login = try values.decodeIfPresent(String.self, forKey: .linkedin_login)
		vkontakte_login = try values.decodeIfPresent(String.self, forKey: .vkontakte_login)
		instagram_login = try values.decodeIfPresent(String.self, forKey: .instagram_login)
		qq_login = try values.decodeIfPresent(String.self, forKey: .qq_login)
		wechat_login = try values.decodeIfPresent(String.self, forKey: .wechat_login)
		discord_login = try values.decodeIfPresent(String.self, forKey: .discord_login)
		mailru_login = try values.decodeIfPresent(String.self, forKey: .mailru_login)
		linkedinAppId = try values.decodeIfPresent(String.self, forKey: .linkedinAppId)
		linkedinAppKey = try values.decodeIfPresent(String.self, forKey: .linkedinAppKey)
		vkontakteAppId = try values.decodeIfPresent(String.self, forKey: .vkontakteAppId)
		vkontakteAppKey = try values.decodeIfPresent(String.self, forKey: .vkontakteAppKey)
		instagramAppId = try values.decodeIfPresent(String.self, forKey: .instagramAppId)
		instagramAppkey = try values.decodeIfPresent(String.self, forKey: .instagramAppkey)
		qqAppId = try values.decodeIfPresent(String.self, forKey: .qqAppId)
		qqAppkey = try values.decodeIfPresent(String.self, forKey: .qqAppkey)
		weChatAppId = try values.decodeIfPresent(String.self, forKey: .weChatAppId)
		weChatAppkey = try values.decodeIfPresent(String.self, forKey: .weChatAppkey)
		discordAppId = try values.decodeIfPresent(String.self, forKey: .discordAppId)
		discordAppkey = try values.decodeIfPresent(String.self, forKey: .discordAppkey)
		mailruAppId = try values.decodeIfPresent(String.self, forKey: .mailruAppId)
		mailruAppkey = try values.decodeIfPresent(String.self, forKey: .mailruAppkey)
		event_commission = try values.decodeIfPresent(String.self, forKey: .event_commission)
		youtube_import = try values.decodeIfPresent(String.self, forKey: .youtube_import)
		youtube_video = try values.decodeIfPresent(String.self, forKey: .youtube_video)
		youtube_key = try values.decodeIfPresent(String.self, forKey: .youtube_key)
		spaces = try values.decodeIfPresent(String.self, forKey: .spaces)
		space_name = try values.decodeIfPresent(String.self, forKey: .space_name)
		spaces_key = try values.decodeIfPresent(String.self, forKey: .spaces_key)
		spaces_secret = try values.decodeIfPresent(String.self, forKey: .spaces_secret)
		space_region = try values.decodeIfPresent(String.self, forKey: .space_region)
		size_issue = try values.decodeIfPresent(String.self, forKey: .size_issue)
		seo = try values.decodeIfPresent(String.self, forKey: .seo)
		points_to = try values.decodeIfPresent(String.self, forKey: .points_to)
		point_system_listen_to_song_cost = try values.decodeIfPresent(String.self, forKey: .point_system_listen_to_song_cost)
		currency_array = try values.decodeIfPresent(String.self, forKey: .currency_array)
		currency_symbol_array = try values.decodeIfPresent(String.self, forKey: .currency_symbol_array)
		google_refreshToken = try values.decodeIfPresent(String.self, forKey: .google_refreshToken)
		google_ClientId = try values.decodeIfPresent(String.self, forKey: .google_ClientId)
		google_ClientSecret = try values.decodeIfPresent(String.self, forKey: .google_ClientSecret)
		google_drive = try values.decodeIfPresent(String.self, forKey: .google_drive)
		fortumo_payment = try values.decodeIfPresent(String.self, forKey: .fortumo_payment)
		fortumo_service_id = try values.decodeIfPresent(String.self, forKey: .fortumo_service_id)
		aamarpay_payment = try values.decodeIfPresent(String.self, forKey: .aamarpay_payment)
		aamarpay_mode = try values.decodeIfPresent(String.self, forKey: .aamarpay_mode)
		aamarpay_store_id = try values.decodeIfPresent(String.self, forKey: .aamarpay_store_id)
		aamarpay_signature_key = try values.decodeIfPresent(String.self, forKey: .aamarpay_signature_key)
		ngenius_payment = try values.decodeIfPresent(String.self, forKey: .ngenius_payment)
		ngenius_mode = try values.decodeIfPresent(String.self, forKey: .ngenius_mode)
		ngenius_api_key = try values.decodeIfPresent(String.self, forKey: .ngenius_api_key)
		ngenius_outlet_id = try values.decodeIfPresent(String.self, forKey: .ngenius_outlet_id)
		coinbase_payment = try values.decodeIfPresent(String.self, forKey: .coinbase_payment)
		coinbase_key = try values.decodeIfPresent(String.self, forKey: .coinbase_key)
		coinpayments = try values.decodeIfPresent(String.self, forKey: .coinpayments)
		coinpayments_secret = try values.decodeIfPresent(String.self, forKey: .coinpayments_secret)
		coinpayments_public_key = try values.decodeIfPresent(String.self, forKey: .coinpayments_public_key)
		coinpayments_coin = try values.decodeIfPresent(String.self, forKey: .coinpayments_coin)
		coinpayments_coins = try values.decodeIfPresent(String.self, forKey: .coinpayments_coins)
		password_complexity_system = try values.decodeIfPresent(String.self, forKey: .password_complexity_system)
		remember_device = try values.decodeIfPresent(String.self, forKey: .remember_device)
		auto_username = try values.decodeIfPresent(String.self, forKey: .auto_username)
		yoomoney_payment = try values.decodeIfPresent(String.self, forKey: .yoomoney_payment)
		yoomoney_wallet_id = try values.decodeIfPresent(String.self, forKey: .yoomoney_wallet_id)
		yoomoney_notifications_secret = try values.decodeIfPresent(String.self, forKey: .yoomoney_notifications_secret)
        withdrawal_payment_method = try values.decodeIfPresent([String: IntString].self, forKey: .withdrawal_payment_method)
		custom_name = try values.decodeIfPresent(String.self, forKey: .custom_name)
		who_can_sell = try values.decodeIfPresent(String.self, forKey: .who_can_sell)
		who_can_multi_upload = try values.decodeIfPresent(String.self, forKey: .who_can_multi_upload)
		who_can_blog = try values.decodeIfPresent(String.self, forKey: .who_can_blog)
		who_can_station_import = try values.decodeIfPresent(String.self, forKey: .who_can_station_import)
		who_can_soundcloud_import = try values.decodeIfPresent(String.self, forKey: .who_can_soundcloud_import)
		who_can_deezer_import = try values.decodeIfPresent(String.self, forKey: .who_can_deezer_import)
		who_can_itunes_import = try values.decodeIfPresent(String.self, forKey: .who_can_itunes_import)
		who_can_youtube_import = try values.decodeIfPresent(String.self, forKey: .who_can_youtube_import)
		who_can_user_ads = try values.decodeIfPresent(String.self, forKey: .who_can_user_ads)
		who_can_event_system = try values.decodeIfPresent(String.self, forKey: .who_can_event_system)
		who_can_story_system = try values.decodeIfPresent(String.self, forKey: .who_can_story_system)
		who_can_store_system = try values.decodeIfPresent(String.self, forKey: .who_can_store_system)
		who_can_point_system = try values.decodeIfPresent(String.self, forKey: .who_can_point_system)
		who_can_donate_system = try values.decodeIfPresent(String.self, forKey: .who_can_donate_system)
		developer_mode = try values.decodeIfPresent(String.self, forKey: .developer_mode)
		wasabi_storage = try values.decodeIfPresent(String.self, forKey: .wasabi_storage)
		wasabi_bucket_name = try values.decodeIfPresent(String.self, forKey: .wasabi_bucket_name)
		wasabi_access_key = try values.decodeIfPresent(String.self, forKey: .wasabi_access_key)
		wasabi_secret_key = try values.decodeIfPresent(String.self, forKey: .wasabi_secret_key)
		backblaze_storage = try values.decodeIfPresent(String.self, forKey: .backblaze_storage)
		backblaze_bucket_id = try values.decodeIfPresent(String.self, forKey: .backblaze_bucket_id)
		backblaze_bucket_name = try values.decodeIfPresent(String.self, forKey: .backblaze_bucket_name)
		backblaze_region = try values.decodeIfPresent(String.self, forKey: .backblaze_region)
		backblaze_access_key_id = try values.decodeIfPresent(String.self, forKey: .backblaze_access_key_id)
		backblaze_access_key = try values.decodeIfPresent(String.self, forKey: .backblaze_access_key)
		amazon_endpoint = try values.decodeIfPresent(String.self, forKey: .amazon_endpoint)
		spaces_endpoint = try values.decodeIfPresent(String.self, forKey: .spaces_endpoint)
		backblaze_endpoint = try values.decodeIfPresent(String.self, forKey: .backblaze_endpoint)
		wasabi_endpoint = try values.decodeIfPresent(String.self, forKey: .wasabi_endpoint)
		cronjob_last_run = try values.decodeIfPresent(String.self, forKey: .cronjob_last_run)
		logo_cache = try values.decodeIfPresent(String.self, forKey: .logo_cache)
		m_withdrawal = try values.decodeIfPresent(String.self, forKey: .m_withdrawal)
		wasabi_bucket_region = try values.decodeIfPresent(String.self, forKey: .wasabi_bucket_region)
		fluttewave_payment = try values.decodeIfPresent(String.self, forKey: .fluttewave_payment)
		fluttewave_secret_key = try values.decodeIfPresent(String.self, forKey: .fluttewave_secret_key)
		point_system_admob_cost = try values.decodeIfPresent(String.self, forKey: .point_system_admob_cost)
		developers_page = try values.decodeIfPresent(String.self, forKey: .developers_page)
		reserved_usernames_system = try values.decodeIfPresent(String.self, forKey: .reserved_usernames_system)
		reserved_usernames = try values.decodeIfPresent(String.self, forKey: .reserved_usernames)
		kkbox_import = try values.decodeIfPresent(String.self, forKey: .kkbox_import)
		main_color = try values.decodeIfPresent(String.self, forKey: .main_color)
		second_color = try values.decodeIfPresent(String.self, forKey: .second_color)
		theme_url = try values.decodeIfPresent(String.self, forKey: .theme_url)
		site_url = try values.decodeIfPresent(String.self, forKey: .site_url)
		ajax_url = try values.decodeIfPresent(String.self, forKey: .ajax_url)
		script_version = try values.decodeIfPresent(String.self, forKey: .script_version)
        blog_categories = try values.decodeIfPresent([String: String].self, forKey: .blog_categories)
        products_categories = try values.decodeIfPresent(ProductsCategoriesUnion.self, forKey: .products_categories)
	}

}

enum ProductsCategoriesUnion: Codable {
    
    case bool(Bool)
    case dictionary([String: String])
    
    var dictionaryValue : [String: String]? {
        guard case let .dictionary(value) = self else { return nil }
        return value
    }
    
    var boolValue : Bool? {
        guard case let .bool(value) = self else { return nil }
        return value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Bool.self) {
            self = .bool(x)
            return
        }
        if let x = try? container.decode([String: String].self) {
            self = .dictionary(x)
            return
        }
        throw DecodingError.typeMismatch(ProductsCategoriesUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ProductsCategoriesUnion"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .bool(let x):
            try container.encode(x)
        case .dictionary(let x):
            try container.encode(x)
        }
    }
    
}

enum IntString: Codable {
    
    case integer(Int)
    case string(String)
    
    var stringValue: String {
        switch self {
        case let .integer(value):
            return String(value)
        case let .string(value):
            return value
        }
    }
    
    var integerValue: Int {
        switch self {
        case let .integer(value):
            return value
        case let .string(value):
            return Int(value) ?? 0
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(IntString.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for IntString"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
    
}
