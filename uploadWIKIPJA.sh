read -p 'input github token: ' github_token
user_name="astanabe"
repo_name="EPWING-Wikipedia-JA"
dict_name="WIKIPJA"
date=`cat date.txt`
tag_name=`echo "${date}" | perl -npe 's/(\d{4})(\d\d)(\d\d)/v0.1.$1.$2.$3/'`

# Make package
tar -cf ${repo_name}-${date}.tar ${dict_name} || exit $?
rm -rf ${dict_name} || exit $?
split -d -a 2 -b 2000M ${repo_name}-${date}.tar ${repo_name}-${date}.tar. || exit $?
rm ${repo_name}-${date}.tar || exit $?
ls ${repo_name}-${date}.tar.* | xargs -P $NCPU -I {} sh -c 'sha256sum {} > {}.sha256 || exit $?' || exit $?
cat ${repo_name}-${date}.tar.*.sha256 | gzip -c9 > ${repo_name}-${date}.sha256.gz || exit $?
rm ${repo_name}-${date}.tar.*.sha256 || exit $?

# Make check/cat/extraction scripts
echo -e "gzip -d ${repo_name}-${date}.sha256.gz\nsha256sum -c ${repo_name}-${date}.sha256" > check${dict_name}-${date}.sh || exit $?
echo -e "for f in ${repo_name}-${date}.tar.*\ndo cat \$f >> ${repo_name}-${date}.tar\nrm \$f\ndone" > cat${dict_name}-${date}.sh || exit $?
echo "tar -xf ${repo_name}-${date}.tar" > extract${dict_name}-${date}.sh || exit $?

# Make download scripts
for asset_file in check${dict_name}-${date}.sh cat${dict_name}-${date}.sh extract${dict_name}-${date}.sh ${repo_name}-${date}.sha256.gz ${repo_name}-${date}.tar.*
do echo "wget -c https://github.com/${user_name}/${repo_name}/releases/download/${tag_name}/${asset_file}" >> wget${dict_name}-${date}.sh
echo "curl -L -O -C - https://github.com/${user_name}/${repo_name}/releases/download/${tag_name}/${asset_file}" >> curl${dict_name}-${date}.sh
done

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
  -d "{\"tag_name\":\"${tag_name}\",\"name\":\"${repo_name} ${tag_name}\",\"body\":\"The JIS X 4081 (EPWING-compatible) format electronic dictionary generated from dump data of ja.wikipedia.org and converter script (version of ${date}).\",\"draft\":false,\"prerelease\":true,\"generate_release_notes\":false,\"make_latest\":\"true\"}"
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
for asset_file in curl${dict_name}-${date}.sh wget${dict_name}-${date}.sh check${dict_name}-${date}.sh cat${dict_name}-${date}.sh extract${dict_name}-${date}.sh ${repo_name}-${date}.sha256.gz ${repo_name}-${date}.tar.*
do curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${github_token}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -H "Content-Type: application/octet-stream" \
  "${upload_url}${asset_file}" \
  -T "${asset_file}"
done
