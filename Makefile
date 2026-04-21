.PHONY: dotbot_install dotbot_install_quiet setup-dropbox

setup-dropbox:
	@bash scripts/setup/setup-dropbox

dotbot_install:
	@printf ">>> Starting dotfiles installation using dotbot...\n"
	@./install
	@printf ">>> Completed dotfiles installation using dotbot...\n"

dotbot_install_quiet:
	@printf ">>> Starting dotfiles installation using dotbot (quiet)...\n"
	@./install --no-hints
	@printf ">>> Completed dotfiles installation using dotbot...\n"
