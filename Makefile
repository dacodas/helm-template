PACKAGE_OUTPUT_DIRECTORY ?= $(PWD)

PROJECT_FOLDER ?= $(PWD)
APPLICATION_NAME ?= $(shell basename $(PROJECT_FOLDER))
SECRET_FILE ?= /usr/share/$(APPLICATION_NAME)/secret.yaml

KUBERNETES_FOLDER = $(PROJECT_FOLDER)/kubernetes

ifneq ($(shell basename $(KUBERNETES_FOLDER)),kubernetes)
$(error KUBERNETES_FOLDER ($(KUBERNETES_FOLDER)) should be a path './kubernetes' under your project)
endif

ifndef APPLICATION_NAME
$(error APPLICATION_NAME is not set)
endif

USER_MANAGED_FILES=\
$(shell gfind $(CURDIR)/template/ -maxdepth 1 -name \*.yaml -printf "$(KUBERNETES_FOLDER)/%P\n")

RENDERED_TEMPLATE=$(CURDIR)/$(APPLICATION_NAME)

$(RENDERED_TEMPLATE): 
	cp -r template $(APPLICATION_NAME)
	find $(APPLICATION_NAME) -type f | \
		xargs gsed -i'' "s/%%% APPLICATION_NAME %%%/$(APPLICATION_NAME)/g"

$(KUBERNETES_FOLDER):
	mkdir -p $(KUBERNETES_FOLDER)

$(USER_MANAGED_FILES): $(RENDERED_TEMPLATE) $(KUBERNETES_FOLDER)

	@FILE="$$(basename $@)" ; \
	OLD="$(RENDERED_TEMPLATE)/$$FILE" ; \
	NEW="$(KUBERNETES_FOLDER)/$$FILE" ; \
	echo "$$OLD -> $$NEW" ; \
	cp "$$OLD" "$$NEW"

check-user-files: 
	@FOUND_FILES=$$(gfind $(USER_MANAGED_FILES) 2>/dev/null) ; \
	if [ ! -z "$$FOUND_FILES" ]; \
	then \
		echo "Found the following user files: "; \
		echo "$$FOUND_FILES"; \
		echo ""; \
		echo "Please back up those files and move them somewhere else before proceeding"; \
		exit 1; \
	fi

user-files: check-user-files $(USER_MANAGED_FILES)

PACKAGE_OUTPUT_DIRECTORY ?= $(APPLICATION_NAME)
package: $(RENDERED_TEMPLATE)
	helm package $(APPLICATION_NAME) -d $(PACKAGE_OUTPUT_DIRECTORY)

clean:
	rm -rf "$(RENDERED_TEMPLATE)"
