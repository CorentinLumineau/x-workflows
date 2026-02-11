.PHONY: new-skill validate help

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

new-skill: ## Create a new workflow skill (NAME=x-foo)
	@if [ -z "$(NAME)" ]; then echo "Usage: make new-skill NAME=x-foo"; exit 1; fi
	@if ! echo "$(NAME)" | grep -qE '^x-[a-z][-a-z]*$$'; then echo "ERROR: Name must match ^x-[a-z][-a-z]*$$ (e.g., x-foo, x-my-skill)"; exit 1; fi
	@if [ -d "skills/$(NAME)" ]; then echo "ERROR: skills/$(NAME) already exists"; exit 1; fi
	@BASE_NAME=$$(echo "$(NAME)" | sed 's/^x-//'); \
	mkdir -p "skills/$(NAME)/references"; \
	cp .templates/workflow-skill/SKILL.md "skills/$(NAME)/SKILL.md"; \
	sed -i "s/__NAME__/$$BASE_NAME/g" "skills/$(NAME)/SKILL.md"; \
	echo "Created skills/$(NAME)/SKILL.md"; \
	echo "Next: edit skills/$(NAME)/SKILL.md and replace __DESCRIPTION__ with actual description"

validate: ## Run repository validation
	@./scripts/validate-rules.sh
