#!/bin/sh

###
# Build the composer repository
#  1. Get the latest satis.json config file from GitHub
#  2. Run `satis build`
###

# GitHub repository to clone (can be private)
CONFIG_REPO="ministryofjustice/pp-satis-config"

# Path to config directory
CONFIG_DIR="/satis/config"
WEB_DIR="/satis/web"

cd "$CONFIG_DIR"

if [ -z "$GITHUB_TOKEN" ]
then
	echo "GitHub access token is not set."
	exit 1
fi

# Create auth.json so that composer can use the GitHub access token
if [ ! -f "/root/.composer/auth.json" ]
then
	cat > "/root/.composer/auth.json" <<- EOM
{
    "github-oauth": {
        "github.com": "$GITHUB_TOKEN"
    }
}
EOM
fi

if [ ! -d "$CONFIG_DIR/.git" ]
then
	# Clone the repo if it doesn't exist yet
	git clone "https://$GITHUB_TOKEN@github.com/$CONFIG_REPO" .
else
	# Otherwise pull any changes
	git pull
fi

satis build ./satis.json "$WEB_DIR"
