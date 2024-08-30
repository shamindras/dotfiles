.PHONY: brewfile

brewfile:
	@printf ">>> Creating brewfile...\n"
	@brew bundle dump --describe --force --file=./config/brew/Brewfile
	@printf ">>> Brewfile created at ./config/brew/Brewfile"