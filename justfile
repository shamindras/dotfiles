default:
  @just --list

update_brewfile:
	@printf ">>> Creating brewfile...\n"
	@brew bundle dump --describe --force --file=./config/brew/Brewfile
	@printf ">>> Brewfile created at ./config/brew/Brewfile\n"

update_submods:
	@printf ">>> Update all submods...\n"
	git submodule update --recursive --remote
	@printf ">>> Updated all submods\n"