DEST = /bin
PROF = /etc/profile.d
PROGRAM = jump.sh
INITSRC = jump_init.sh

install:	$(PROGRAM) $(INITSRC)
	@if [ -e "$(DEST)/$(PROGRAM)" ]; then \
		echo "The command already exists." >&2; \
		false; \
	fi
	@if [ ! -e "$(PROF)/$(INITSRC)" ]; then cp $(INITSRC) $(PROF) && chmod 644 $(PROF)/$(INITSRC) ; fi
	@if [ ! -e "$(DEST)/$(PROGRAM)" ]; then install $(PROGRAM) $(DEST); fi
	@echo "Install was successful."
	@echo "Please restart your shell (or load initialize script as 'source /etc/profile.d/jump_init.sh' now)."

uninstall:
	@if [ -e "$(PROF)/$(INITSRC)" ]; then rm -f $(PROF)/$(INITSRC); fi
	@if [ -e "$(DEST)/$(PROGRAM)" ]; then rm -f $(DEST)/$(PROGRAM); fi
	@echo "Uninstall was successful."
	@echo "Please restart your shell."

cleanup:
	@read -p "Are you sure you want to delete the jump command workfile? [y/N]: " ans && [ $${ans:-N} = y ] || (echo "OK, We are not doing anything."; exit 1)
	@rm -f ~/.jump
	@rm -f ~/.jump_backpath
	@rm -f ~/.jump_cdpath
	@rm -f ~/.jump_modified
	@echo "Cleanup was successful."

