STATUS_CODE=$(curl -L \
  -o /dev/null -s -w "%{http_code}\n" \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_ACCESS_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/brandongregoryscott/spotify-data/actions/workflows/92677804/dispatches \
  -d '{"ref":"main"}')


if test $STATUS_CODE != '200' && test $STATUS_CODE != '204'
then
  echo "Request to start workflow failed with status code $STATUS_CODE"
  exit 1;
fi;
