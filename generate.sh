# 17.0.0
#PREVIOUS_RELEASE=f99ce7c1b88ff445f60e9e5575b674cb509e47f3
# 17.8.0
PREVIOUS_RELEASE=123661eda6c9238739a1f8c122fbbaacfb2ea246
LAST_COMMIT=0187bc5cdcffdb80763792d32666d0814bb265fc 

git log --oneline $PREVIOUS_RELEASE..$LAST_COMMIT >raw-list
cat raw-list |grep -v "doc:" |grep -v "test:" |grep -v "meta:" >trimmed-list
cat trimmed-list | awk '{print $1}' > commit-list
rm -f pr-list.json
echo "{" >>pr-list.json
while read commit; do
  pr=`git log --format=%B -n 1 $commit | \
      grep "PR-URL:" | \
      sed -e 's|https://github.com/nodejs/node/pull/||g' | \
      sed -e 's|https://github.com/nodejs/node/issues/||g' | \
      sed -e 's|https://github.com/nodejs-private/node-private/pull/|PRIVATE-|g' | \
      sed -e 's|https://github.com/libuv/libuv-private/pull/|LIBUVPRIVATE-|g' | \
      sed -e 's|LIBUVPRIVATE-\([0-9]\+\)|{"repo":"libuv-private","commit":\1}|g' | \
      sed -e 's|PRIVATE-\([0-9]\+\)|{"repo":"nodejs-private","commit":\1}|g' | \
      sed -e 's|PR-URL:||g' | tr -d '\n' | tr -d '\r' | sed -e 's/  \+/ /g' | \
      sed -e 's| |,|g' | sed -e 's|,||'`
  echo "\"$commit\": [$pr]," >>pr-list.json
done <commit-list
sed -i '$ s|],|]|' pr-list.json
echo "}" >>pr-list.json

node generate.js >pr-list-labelled

rm -f release-info
while read commit; do
  set $commit 
  COMMENT=`git log --pretty=format:%s -n 1 $2`
  echo "$1|$2|$COMMENT" >>release-info
done <pr-list-labelled
