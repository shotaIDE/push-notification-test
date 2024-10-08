#!/bin/bash

source ./.env

# --------------------
# https://developer.apple.com/documentation/usernotifications/sending-notification-requests-to-apns

if [ "$USE_SANDBOX" = 1 ]; then
    ENDPOINT='https://api.sandbox.push.apple.com'
else
    ENDPOINT='https://api.push.apple.com'
fi

read -r -d '' payload <<-'EOF'
{
    "aps": {
        "title": "Test Title (via APNs with shell)",
        "body": "This VoIP notification was sent at TIME"
    }
}
EOF

# --------------------
# https://developer.apple.com/documentation/usernotifications/establishing-a-token-based-connection-to-apns

base64() {
   openssl base64 -e -A | tr -- '+/' '-_' | tr -d =
}

sign() {
   printf "$1"| openssl dgst -binary -sha256 -sign "$APNS_AUTH_KEY_FILE_PATH" | base64
}

time=$(date +%s)
header=$(printf '{ "alg": "ES256", "kid": "%s" }' "$APNS_AUTH_KEY_ID" | base64)
claims=$(printf '{ "iss": "%s", "iat": %d }' "$TEAM_ID" "$time" | base64)
jwt="$header.$claims.$(sign $header.$claims)"

time_str=$(date -Iseconds)
curl --verbose \
   --header "authorization: bearer $jwt" \
   --header "apns-push-type: voip" \
   --header "apns-topic: ${BUNDLE_ID}.voip" \
   --data "${payload/TIME/$time_str}" \
   $ENDPOINT/3/device/$VOIP_DEVICE_TOKEN
