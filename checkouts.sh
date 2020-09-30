#!/bin/bash

if [ "$#" = 0 ]; then
  echo "Please, check args. Usage: ./checkouts.sh <some-branch>";
  exit 0;
fi
dirToExclude=(appdatabasefixer gisfomobileapp gisfosql);

function line() {
  echo "----------------------------"
}

containsElement() {
  local e match="$1";
  shift;
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1;
}

# Checking uncommited changes
function checkUncommited() {
  for dir in $(ls); do
    if [[ -d "$dir" ]]; then
      cd "$dir";
      line;
      if ! containsElement "$dir" "${dirToExclude[@]}"; then
        echo "Checking: $dir";
        sleep 0.5;
        uncommitedChanges=$(git status --porcelain=v1 2>/dev/null | wc -l);
        if [ "$uncommitedChanges" != 0 ]; then
          echo "Operation is not permitted. You have uncommited changes in $dir.";
          echo "Please commit your changes then try again."
          exit 0;
        fi
        cd ..
      else
        echo "Skipping $dir";
        cd ..;
      fi
    fi
  done
  line;
}

# Entering every directory with our modules, changing branch desired and pulling remote repository or restoring
# branch to it previous state (for example 30 min ago)
function changeBranchAndUpdateOrRestore() {
  for dir in $(ls);
    do
      if [[ -d $dir ]]; then
        cd "$dir";
        line;
        echo "Entering: $dir";
        sleep 0.5;
        if ! containsElement "$dir" "${dirToExclude[@]}"; then
          git checkout "$1";
          status="$?";
          if [ "$status" ] && [ "$2" = 1 ] && [ "$3" = 1 ]; then
            git pull origin "$1";
          elif [ "$status" ] && [ "$2" = 2 ]; then
            git reset --hard "$1"@{"$3 minutes ago"};
          fi
          cd ..;
        else
          echo "Skipping $dir";
          cd ..;
        fi
      fi
    done
    line;
}


# MAIN
while true; do
  cd /c/Users/osuvorov/GISFO;
  clear;
  line;
  echo "Current branch: $1";
  line;
  echo "1. Change or/and update branch in all modules (git checkout <someBranch>)";
  echo "2. Restore all branches (git reset --hard master@{'<Xmin> minutes ago'})";
  echo "3. Set new branch. Current: $1";
  echo "4. Exit.";
  read -r option;
  clear;
  if [ "$option" = 4 ]; then
    echo "Bye!";
    exit 0;
  fi
  if [ "$option" != 3 ]; then
    echo "Checking uncommited changes...";
    if checkUncommited; then
      echo "Everything is up to date.";
      echo "Changing directories...";
    fi
    sleep 1;
  fi

  if [ "$option" = 1 ]; then
    echo "Would you like to update all modules as well: (git pull origin $1)?";
    echo "1. Yes"
    echo "2. No"
    read -r update;
    changeBranchAndUpdateOrRestore "$1" "$option" "$update";
  elif [ "$option" = 2 ]; then
    echo "How many minutes roll back?Leave blank to cancel operation.";
    read -r minutes;
    if [ "$minutes" = "" ]; then
      echo "Exiting..."
      exit 0;
    fi
    changeBranchAndUpdateOrRestore "$1" "$option" "$minutes";
  elif [ "$option" = 3 ]; then
    echo "Type branch name...";
    read -r nameOfBranch;
    set $nameOfBranch;
    clear;
  else
    exit 0;
  fi
done

exit 0;
