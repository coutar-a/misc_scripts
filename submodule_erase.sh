#!/bin/sh

## erases lines matching pattern (service name) from file
## arguments : pattern, file
erase_service_from_file ()
{
  LINES=$(grep -n "$1" "$2" |cut -f1 -d:)
  if [ "$LINES" = "" ]
  then
    echo "submodule $1 not found"
    return 1
  fi

  PATTERN=$(echo $LINES | sed 's/ /d;/g')"d"

  if [ "$PATTERN" = "" ]
  then
    echo "submodule $1 not found"
    return 1
  fi
  sed -i "$PATTERN" "$2"
  return 0
}

## erases lines in range matching pattern from file using sed
## arguments : pattern, file
erase_using_sed ()
{
  LINES=$(grep -n -m1 "$1" "$2" |cut -f1 -d:)
  if [ "$LINES" = "" ]
  then
      echo "submodule $1 not found"
      return 1
  fi

  PATTERN=$(echo "$LINES $(( LINES + 1)) $(( LINES + 2))" | sed 's/ /d;/g')"d" # no quote to shed newline (no I don't know why it works)

  if [ "$PATTERN" = "" ]
  then
      echo "submodule $1 not found"
      return 1
  fi
  sed -i "$PATTERN" "$2"
  return 0
}

main()
{
  echo "Erasing submodule $1 from repository..."
  erase_service_from_file "$1" .gitmodules
  STAGE_1=$?
  if [ "$STAGE_1" = 1 ]
  then
    echo "$1 does not exist as a submodule"
    return 1
  fi
  echo "Staging changes to .gitmodules..."
  git add .gitmodules
  echo "Erasing submodule $1 from git config file..."
  erase_using_sed "$1" .git/config
  STAGE_2=$?
    if [ "$STAGE_2" = 1 ]
  then
    echo "$1 does not exist as a submodule in .git/config"
    return 1
  fi
  echo "Removing $1 from repository..."
  git rm -rf --cached "$1" ; rm -rf .git/modules/"$1"
  echo "Removing $1 from file system..."
  rm -rf "$1"
  echo "Done !"
}


if [ $# -eq 0 ]
  then
    echo "Usage : sh submodule_remove.sh <submodule>"
    return 0
  else
    main "$1"
fi
