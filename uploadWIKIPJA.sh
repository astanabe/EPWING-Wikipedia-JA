read -p 'input github token: ' github_token
user_name="astanabe"
repo_name="EPWING-Wikipedia-JA"
tag_name=`cat tag_name.txt`
DATE=`cat date.txt`

# Get release list
response=`curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${github_token}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/${user_name}/${repo_name}/releases`

# Check tag and create release if not exist
if test `echo ${response} | jq '.[] | .tag_name' | grep -c "${tag_name}"` -eq 0; then
curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${github_token}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/${user_name}/${repo_name}/releases \
  -d "{\"tag_name\":\"${tag_name}\",\"name\":\"${repo_name} ${tag_name}\",\"body\":\"The JIS X 4081 (EPWING-compatible) format electronic dictionary generated from dump data of ja.wikipedia.org and converter script (version of ${DATE}).\",\"draft\":false,\"prerelease\":true,\"generate_release_notes\":false,\"make_latest\":\"true\"}"
fi

# Get a release by tag name
response=`curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${github_token}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/${user_name}/${repo_name}/releases/tags/${tag_name}`

# Prepare upload URL
upload_url=`echo "${response}" | jq '. | .upload_url' | tr -d '"'`
upload_url="${upload_url%%\{*}?name="

# Perform upload
for asset_file in curlWIKIPJA-*.sh wgetWIKIPJA-*.sh checkWIKIPJA-*.sh catWIKIPJA-*.sh extractWIKIPJA-*.sh ${repo_name}-*.sha256.gz ${repo_name}-*.tar.*
do curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${github_token}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -H "Content-Type: application/octet-stream" \
  "${upload_url}${asset_file}" \
  -T "${asset_file}"
done
