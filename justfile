_default:
	@just --choose

all: clean stylua_config update_brewfile update_submods

clean:
	@printf ">>> Begin cleaning directories...\n"
	@rm -rf ./config/zsh/.zsh_sessions
	@fd '\.(DS_Store|swo|swp)$|~$' -tf -u -X rm
	@printf ">>> Finished cleaning directories...\n"

stylua_config:
	@printf ">>> Style all config lua files...\n"
	@fd . 'config/' -e lua -j 4 -x sh -c 'stylua "$1" > /dev/null 2>&1 || true' sh {}
	@printf ">>> Finished styling all config lua files...\n"

update_brewfile:
	@printf ">>> Creating brewfile...\n"
	@brew bundle dump --describe --force --file=./config/brew/Brewfile
	@printf ">>> Brewfile created at ./config/brew/Brewfile\n"

update_submods:
	@printf ">>> Update all submods...\n"
	git submodule update --recursive --remote
	@printf ">>> Updated all submods\n"

