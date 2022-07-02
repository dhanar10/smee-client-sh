# smee-client-sh

Smee.io client using bash, curl, grep, and jq

# Requirements

- bash
- curl
- grep
- jq

# Usage

Bitbucket -> smee.io -> Jenkins webhook example: 

```
bash smee-client.sh "https://smee.io/XXXXXXXXXXXXXXXX" "https://jenkins/bitbucket-hook" "^x-event-key:"
```
