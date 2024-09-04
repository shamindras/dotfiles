.PHONY: brewfile update_submods dotbot_install

brewfile:
	@printf ">>> Creating brewfile...\n"
	@brew bundle dump --describe --force --file=./config/brew/Brewfile
	@printf ">>> Brewfile created at ./config/brew/Brewfile\n"

update_submods:
	@printf ">>> Update all submods...\n"
	git submodule update --recursive --remote
	@printf ">>> Updated all submods\n"

dotbot_install:
	@printf ">>> Starting dotfiles installation using dotbot...\n"
	@./install
	@printf ">>> Completed dotfiles installation using dotbot...\n"
