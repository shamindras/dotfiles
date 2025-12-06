.PHONY: dotbot_install setup-dropbox

setup-dropbox:
	@bash scripts/setup-dropbox.sh

dotbot_install:
	@printf ">>> Starting dotfiles installation using dotbot...\n"
	@./install
	@printf ">>> Completed dotfiles installation using dotbot...\n"
