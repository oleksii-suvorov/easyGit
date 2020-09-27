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

function checkIfBlank() {
  if [ "$1" = "" ]; then
    echo "Operation was canceled. Exiting...";
    sleep 1;
    clear;
    return 0;
  else
    return 1;
  fi
}

function showRepos() {
  echo "Print remote repos?";
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
  if [[ ! "$1" =~ .+_mvn$ && $currentBranch =~ .+_mvn$ ]]; then
    line;
    echo "Can't push _mvn branch into not _mvn branch. Only vice versa. Aborting...";
    line;
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
    echo "Type url of your repository...(leave blank to cancel this operation)";
    read -r repository;
    echo "Type name...(Leave blank to cancel this operation)";
    read -r nameRemote;
    if checkIfBlank "$nameRemote" || checkIfBlank "$repository"; then
      return 2;
    fi
    git remote add "$nameRemote" "$repository";
    showRepos;
  elif [ "$answer" = 4 ]; then
    showRepos;
    echo "Type repository to remove...(leave blank to cancel this operation)";
    read -r repository;
    if checkIfBlank "$repository"; then
      return 2;
    fi
    git remote  remove "$repository";
    showRepos;
  elif [ "$answer" = 6 ]; then
    git branch -a;
    echo "Type branch name to enter...";
    read -r branch;
    if checkIfBlank "$branch"; then
      return 2;
    fi
    line;
    if git checkout "$branch" | grep error:; then
      echo "It seems like you have uncommitted changes...";
      echo "Force checkout? (changes will be lost)?";
      echo "1. Yes.";
      echo "2. No.";
      read -r force;
      if checkIfBlank "$force"; then
        return 2;
      elif [ "$force" = 1 ]; then
         git checkout -f "$branch";
      else
        return 2;
      fi
    fi
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
    bye;
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
    line;
    git checkout -b "$branchName";
    line;
  elif [ "$answer" = 4 ]; then
    git branch -a;
    echo "Type branch name to move into...";
    read -r branchName;
    line;
    git checkout "$branchName";
    line;
  elif [ "$answer" = 5 ]; then
    git branch -a;
    echo "Type branch name to remove...(locally). Leave empty to cancel operation.";
    read -r branchName;
    if checkIfBlank "$fileName" == 2; then
       return 2;
    fi
    line;
    git branch -D "$branchName";
    line;
  elif [ "$answer" = 6 ]; then
    echo "Type new name...";
    read -r branchName;
    line;
    git branch -m "$branchName";
    git branch --show-current;
    line;
  elif [ "$answer" = 7 ]; then
    bye;
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
  echo "7. Git push.";
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
      if checkIfBlank "$fileName" == 2; then
        return 2;
      fi
      git add "$fileName";
      git status;
    else
      clear;
      return 2;
    fi
  elif [ "$answer" = 4 ]; then
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
        if checkIfBlank "$fileName" == 2; then
          return 2;
        fi
        git reset "$fileName";
        git status;
      else
        clear;
        return 2;
      fi
  elif [ "$answer" = 5 ]; then
    echo "Type branch (from) which you wanna merge (into current)...";
    read -r mergeBranch;
    currentBranch=$(git branch --show-current);
    if [[ $currentBranch =~ .+_mvn$ && $mergeBranch =~ .+_mvn$ ]]; then
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
    line;
    git commit -m "$title\n
    $details";
    line;
  elif [ "$answer" = 7 ]; then
    clear;
    currentBranch=$(git branch --show-current);
    echo "1. Push to current branch? ($currentBranch)";
    echo "2. Choose branch to push into.";
    read -r option;
    if [ "$option" = 1 ]; then
      git push origin "$currentBranch";
      line;
    else
      line;
      echo "Branches:"
      git branch -a;
      line;
      echo "Branch name to push into...";
      read -r branchNameToPush;
      checkBranches "$branchNameToPush";
      if [ "$?" == 2 ]; then
        keypress;
        return 2;
      fi
      line;
      git push origin "$branchNameToPush";
      line;
    fi
  elif [ "$answer" = 8 ]; then
    bye;
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