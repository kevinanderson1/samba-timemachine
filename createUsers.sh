IFS=':' read -r -a USERS <<< "${USER_ENV}"
for user in "${USERS[@]}"
do
  echo "Creating ${user}"
  useradd ${user}
done

exit 0
