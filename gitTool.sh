#!/bin/bash

clear;
cat ./pic.txt;
sleep 1;
function printOptions() {
  clear;
  echo "0. Exit.";
  echo "1. Info operations. (init, add/show repo, checkout, config global)";
  echo "2. Branch operations. (create, change, remove, rename)";
  echo "3. Git main operations. (status, diff, add, reset, commit, push)";
}

function line() {
  echo "-------------------------------------------";
}

function showRepos() {
  echo "Show remote repos?";
  echo "1. Yes.";
  echo "2. No.";
  read -r show;
  clear;
  if [ "$show" = 1 ]; then
    line;
    git remote -v;
    line;
  else
    echo "Exiting...";
  fi
}

 function checkBranches() {
  currentBranch=$(git branch --show-current);
  if [[ ($currentBranch != *"_mvn"* && $1 == *"_mvn"*) ||
    ($1 != *"_mvn"* && $currentBranch == *"_mvn"*) ]]; then
      echo "You can not merge _mvn branch into not _mvn branch! Aborting..."
      return 2;
  else
      return 1;
  fi
}

function infoOpts() {
  echo "0. <- Main menu.";
  echo "1. Config global name/mail.";
  echo "2. Git init.";
  echo "3. Add remote repository.";
  echo "4. Remove remote repository.";
  echo "5. Show remote repository.";
  echo "6. Git checkout.";
  echo "7. Exit.";
  read -r answer;
  clear;
  if [ "$answer" = 2 ]; then
    line;
    git init;
    line;
  elif [ "$answer" = 5 ]; then
    line;
    git remote -v;
    line;
  elif [ "$answer" = 3 ]; then
    echo "Type url of your repository...(Leave blank to cancel this operation)";
    read -r repository;
    echo "Type name...(Leave blank to cancel this operation)";
    read -r nameRemote;
    if [ "$nameRemote" = "" ] || [ "$repository" = "" ]; then
      echo "Exiting...";
      sleep 1;
      clear;
      return 2;
    fi
    git remote add "$nameRemote" "$repository";
    showRepos;
  elif [ "$answer" = 4 ]; then
    showRepos;
    echo "Type repository to remove...";
    read -r repository;
    git remote remove "$repository";
    showRepos;
  elif [ "$answer" = 6 ]; then
    line;
    git checkout;
    line;
  elif [ "$answer" = 1 ]; then
    echo "Type your user name";
    read -r username;
    echo "Type your email";
    read -r email;
    git config --global user.name "$username";
    if [ "$?" = 0 ]; then
      echo "Done. Successfully set username: $username";
    fi
    git config --global user.email "$email";
    if [ "$?" = 0 ]; then
      echo "Done. Successfully set email: $email";
    fi
  elif [ "$answer" = 7 ]; then
    return 5;
  else
    return 1;
  fi
  keypress;
  return 2;
}

function branchOpts() {
  echo "0. <- Main menu.";
  echo "1. Show current branch.";
  echo "2. Show all branches.";
  echo "3. Create branch.";
  echo "4. Change branch.";
  echo "5. Remove branch (locally with -D).";
  echo "6. Rename branch (locally).";
  echo "7. Exit.";
  read -r answer;
  clear;
  if [ "$answer" = 1 ]; then
    line;
    git branch --show-current;
    line;
  elif [ "$answer" = 2 ]; then
    echo "Local or remote? Leave blank to exit.";
    echo "1. Local.";
    echo "2. Remote.";
    read -r branches;
    if [ "$branches" = 1 ]; then
      line;
      git branch -a;
      line;
    elif [ "$branches" = 2 ]; then
      line;
      git branch -r;
      line;
    else
      echo "Exiting...";
    fi
  elif [ "$answer" = 3 ]; then
    echo "Type your branch name...";
    read -r branchName;
    git checkout -b "$branchName";
  elif [ "$answer" = 4 ]; then
    echo "Type branch name to move into...";
    read -r branchName;
    git checkout "$branchName";
  elif [ "$answer" = 5 ]; then
    echo "Type branch name to remove...";
    read -r branchName;
    git checkout "$branchName";
  elif [ "$answer" = 6 ]; then
    echo "Type new name...";
    read -r branchName;
    git branch -m "$branchName";
  elif [ "$answer" = 7 ]; then
    return 5
  else
    return 1;
  fi
  keypress;
  return 2;
}

function mainOpts() {
  echo "0. Back";
  echo "1. Git status.";
  echo "2. Git diff.";
  echo "3. Git add.";
  echo "4. Git reset.";
  echo "5. Git merge.";
  echo "6. Git commit. Title and description.";
  echo "7. Git push. By default into your current branch.";
  echo "8. Exit.";
  read -r answer;
  clear;
  if [ "$answer" = 1 ]; then
    line;
    git status;
    line;
  elif [ "$answer" = 2 ]; then
    line;
    git diff;
    line;
  elif [ "$answer" = 3 ]; then
    clear;
    echo "1. Add one file...";
    echo "2. Add * (all)";
    echo "3. Back.";
    read -r option;
    clear;
    if [ "$option" = 2 ]; then
      git add *;
      git status;
    elif [ "$option" = 1 ]; then
      git status;
      echo "Type file name to add...(leave blank to cancel operation)";
      read -r fileName;
      if [ "$fileName" != "" ]; then
        git add "$fileName";
        git status;
      else
        echo "Exiting...";
      fi
    else
      clear;
      return 2;
    fi
  elif [ "$answer" = 4 ]; then
#    while true; do
      clear;
      echo "1. Reset one...";
      echo "2. Reset * (all)";
      echo "3. Back.";
      read -r option;
      if [ "$option" = 2 ]; then
        git reset *;
        git status;
      elif [ "$option" = 1 ]; then
        git status;
        echo "Type file to reset...(leave blank to cancel operation)";
        read -r fileName;
        if [ "$fileName" != "" ]; then
          git reset "$fileName";
          git status;
        else
          echo "Exiting...";
        fi
      else
        clear;
        return 2;
      fi
#    done
  elif [ "$answer" = 5 ]; then
    echo "Type branch (from) which you wanna merge (into current)...";
    read -r mergeBranch;
    currentBranch=$(git branch --show-current);
    if [[ $currentBranch != *"_mvn"* && $mergeBranch == *"_mvn"* ]]; then
      echo "You can not merge _mvn branch into not _mvn branch! Aborting..."
      return 2;
    fi
    git merge "$mergeBranch";
  elif [ "$answer" = 6 ]; then
    clear;
    echo "Type commit title...";
    read -r title;
    echo "Type commit details...";
    read -r details;
    git commit -m "$title\n
    $details";
    sleep 1;
  elif [ "$answer" = 7 ]; then
    clear;
    echo "1. Push to current branch.";
    echo "2. Choose branch to push into.";
    read -r option;
    if [ "$option" = 1 ]; then
      currentBranch=$(git branch --show-current);
      git push origin "$currentBranch";
    else
      echo "Type your branch name to push into...";
      read -r branchNameToPush;
      checkBranches "$branchNameToPush";
      if [ "$?" == 2 ]; then
        echo "You can not merge _mvn branch into not _mvn branch or vice versa! Aborting..."
        return 2;
      fi
      git push origin "$branchName";
    fi
  elif [ "$answer" = 8 ]; then
      return 5;
  else
    return 1;
  fi
  keypress;
  return 2;
}

function keypress() {
  echo " <- press any key to go back..."
  while true; do
    read -t 3600 -n 1
    if [ "$?" = 0 ]; then
      clear;
      return;
    else
      echo "waiting for the keypress"
    fi
  done
}

function bye() {
  clear;
  printf "Bye!";
  exit 0;
}



while true; do
  printOptions;
  read -r option;
  clear;
  case $option in
    0)
      bye;
    ;;
    1)
      while true; do
        infoOpts;
        if [ "$?" = 2 ]; then
          continue;
        elif [ "$?" = 1 ]; then
          break;
        else
          bye;
        fi
      done
    ;;
    2)
      while true; do
        branchOpts;
        if [ "$?" = 2 ]; then
          continue;
        elif [ "$?" = 1 ]; then
          break;
        else
          bye;
        fi
      done
    ;;
    3)
      while true; do
        mainOpts;
        if [ "$?" = 2 ]; then
          continue;
        elif [ "$?" = 1 ]; then
          break;
        else
          bye;
        fi
      done
  esac
done

exit 0;