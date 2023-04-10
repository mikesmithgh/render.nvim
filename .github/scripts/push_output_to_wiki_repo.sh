#!/usr/bin/env bash
set -eu

print_usage() {
  printf "%s\n" "$0"
  printf "  -r, --repo \n"
  printf "  -h, --help display this help text and exit\n"
}

# copied from https://stackoverflow.com/questions/12022592/how-can-i-use-long-options-with-the-bash-getopts-builtin
# transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
    '--help')   set -- "$@" '-h'   ;;
    '--repo')   set -- "$@" '-r'   ;;
    '--ssh-deploy-key')   set -- "$@" '-k'   ;;
    '--target-dir')   set -- "$@" '-t'   ;;
    '--source-dir')   set -- "$@" '-s'   ;;
    *)          set -- "$@" "$arg" ;;
  esac
done

# Default behavior
repo='git@github.com:mikesmithgh/render.nvim.wiki.git'
commit_user_email='github-actions[bot]@users.noreply.github.com'
commit_user_name='github-actions[bot]'
commit_msg='chore(build): auto-generate wiki'

# Parse short options
OPTIND=1
while getopts "hr:k:t:s:" opt
do
  case "$opt" in
    'h') print_usage; exit 0 ;;
    'r') repo=$OPTARG ;;
    'k') ssh_deploy_key=$OPTARG ;;
    't') target_dir="ci/$OPTARG" ;;
    's') source_dir=$(realpath "$OPTARG") ;;
    '?') print_usage >&2; exit 1 ;;
  esac
done
shift $(("$OPTIND" - 1)) # remove options from positional parameters

if [ -n "${ssh_deploy_key:=}" ]; then

	printf "[+] using ssh_deploy_key\n"

  # Inspired by https://github.com/cpina/github-action-push-to-another-repository/blob/main/entrypoint.sh, thanks!
	# which was inspired by https://github.com/leigholiver/commit-with-deploy-key/blob/main/entrypoint.sh , thanks!
	mkdir --parents "$HOME/.ssh"
	deploy_key_file="$HOME/.ssh/deploy_key"
	printf "%s\n" "${ssh_deploy_key}" > "$deploy_key_file"
	chmod 600 "$deploy_key_file"

	ssh_known_hosts_file="$HOME/.ssh/known_hosts"
	ssh-keyscan -H "github.com" > "$ssh_known_hosts_file"

	export GIT_SSH_COMMAND="ssh -i $deploy_key_file -o userknownhostsfile=$ssh_known_hosts_file"

else
  print_usage >&2
  exit 1
fi

printf "[+] Git version\n"
git --version

# Setup git
git config --global user.email "$commit_user_email"
git config --global user.name "$commit_user_name"

printf "[+] Enable git lfs\n"
git lfs install

printf "[+] Cloning destination git repository %s\n" "$repo"
clone_dir=$(mktemp -d)
rm -rf "$clone_dir"
git clone "$repo" "$clone_dir"
cd "$clone_dir"

ls -la "$clone_dir"

temp_dir=$(mktemp -d)
# This mv has been the easier way to be able to remove files that were there
# but not anymore. Otherwise we had to remove the files from "$CLONE_DIR",
# including "." and with the exception of ".git/"
mv "$clone_dir/.git" "$temp_dir/.git"

printf "[+] Deleting target directory %s\n" "$target_dir"
rm -rf "$target_dir"
#
printf "[+] Creating (now empty) target directory %s\n" "$target_dir"
mkdir -p "$target_dir"

printf "[+] Listing Current Directory Location\n"
ls -la

mv "$temp_dir/.git" "$clone_dir/.git"

printf "[+] List contents of %s\n" "$source_dir"
ls "$source_dir"

printf "[+] Checking if local %s exist\n" "$source_dir"
if [ ! -d "$source_dir" ]; then
	printf "ERROR: %s does not exist\n" "$source_dir"
	printf "This directory needs to exist when push-to-another-repository is executed\n"
	exit 1
fi

printf "[+] Copying contents of source repository folder %s to folder %s in git repo %s\n" "$source_dir" "$target_dir" "$repo"
cp -a "$source_dir" "$clone_dir/$target_dir"
cd "$clone_dir"

printf "[+] Files that will be pushed\n"
ls -la

printf "[+] Set directory is safe (%s)\n" "$clone_dir"
# Related to https://github.com/cpina/github-action-push-to-another-repository/issues/64 and https://github.com/cpina/github-action-push-to-another-repository/issues/64
git config --global --add safe.directory "$clone_dir"

printf "[+] Adding git commit\n"
git add .

printf "[+] git status:\n"
git status

printf "[+] git diff-index:\n"
# git diff-index : to avoid doing the git commit failing if there are no changes to be commit
git diff-index --quiet HEAD || git commit --message "$commit_msg"

printf "[+] Pushing git commit\n"
# --set-upstream: sets the branch when pushing to a branch that does not exist
git push "$repo" --set-upstream "master"

set +eu
