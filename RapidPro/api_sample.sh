#!/bin/bash

API_KEY=
CONTACTS=https://api.textit.in/api/v2/contacts.json
FLOW_STARTS=https://api.textit.in/api/v2/flow_starts.json

# specific to the saved artifacts in project.json
CONTACT_UUID=4f9a2cbb-2eee-435d-8dca-9505d9ab7b91
ENROLL_UUID=1aa47fe5-32c3-4125-b70c-a02c2f189712
UNENROLL_UUID=1d0cad75-42c5-4da7-91bd-1327095b73dc


function get() {
    curl -H "Authorization: Token $API_KEY" \
    -H "content-type: application/json" \
    -X GET https://api.textit.in/api/v2/$1.json | jq
}

function contact_post() {
    curl -H "Authorization: Token $API_KEY" \
    -H "Content-Type: application/json" \
    -X POST $CONTACTS \
    --data $1 | jq
}

# Flow Triggers

#The Flow API expects bodies with flow and urns. We pass data to flows using the extra block like:

{"flow":"4f9a2cbb-2eee-435d-8dca-9505d9ab7b91","extra":{"msg": "hello!"}, "urns": ["tel:+15555011234"]}

function flow_post() {
    curl -H "Authorization: Token $API_KEY" \
    -H "Content-Type: application/json" \
    -X POST $FLOW_STARTS \
    --data $1 | jq
}
