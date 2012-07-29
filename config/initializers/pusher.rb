
Pusher.app_id = ENV["PUSHER_APP_ID"]
Pusher.key = ENV["PUSHER_KEY"]
Pusher.secret = ENV["PUSHER_SECRET"]

if Pusher.app_id && Pusher.key && Pusher.secret
  p "Pusher is configuread!"
else
  p "Pusher is not configured."
end
