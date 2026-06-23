.PHONY: help bootstrap fmt validate lint security docs \
        dev-init dev-plan dev-apply dev-destroy \
        staging-init staging-plan staging-apply staging-destroy \
        prod-init prod-plan prod-apply prod-destroy

TERRAFORM_DIRS := environments/dev environments/staging environments/prod
MODULE_DIRS    := modules/bootstrap modules/vpc modules/security_groups modules/iam modules/ec2_asg

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-26s\033[0m %s\n", $$1, $$2}'

# ── Bootstrap (run once) ───────────────────────────────────────────────────────

bootstrap: ## Create S3 state bucket + DynamoDB lock table
	cd modules/bootstrap && terraform init && terraform apply

# ── Code quality ──────────────────────────────────────────────────────────────

fmt: ## Format all Terraform files recursively
	terraform fmt -recursive .

validate: ## Validate all environment configs
	@for dir in $(TERRAFORM_DIRS); do \
		echo "→ Validating $$dir ..."; \
		cd $$dir && terraform validate && cd -; \
	done

lint: ## Run tflint on all modules and environments
	@for dir in $(MODULE_DIRS) $(TERRAFORM_DIRS); do \
		echo "→ Linting $$dir ..."; \
		tflint --chdir=$$dir; \
	done

security: ## Run checkov security scan
	checkov -d . --framework terraform --quiet

docs: ## Regenerate terraform-docs README for each module
	@for dir in $(MODULE_DIRS); do \
		echo "→ Docs for $$dir ..."; \
		terraform-docs markdown table --output-file README.md $$dir; \
	done

# ── Dev ───────────────────────────────────────────────────────────────────────

dev-init: ## Initialise dev environment
	cd environments/dev && terraform init

dev-plan: ## Plan dev environment
	cd environments/dev && terraform plan

dev-apply: ## Apply dev environment
	cd environments/dev && terraform apply

dev-destroy: ## Destroy dev environment
	cd environments/dev && terraform destroy

# ── Staging ───────────────────────────────────────────────────────────────────

staging-init: ## Initialise staging environment
	cd environments/staging && terraform init

staging-plan: ## Plan staging environment
	cd environments/staging && terraform plan

staging-apply: ## Apply staging environment
	cd environments/staging && terraform apply

staging-destroy: ## Destroy staging environment
	cd environments/staging && terraform destroy

# ── Prod ──────────────────────────────────────────────────────────────────────

prod-init: ## Initialise prod environment
	cd environments/prod && terraform init

prod-plan: ## Plan prod environment (always run before apply)
	cd environments/prod && terraform plan

prod-apply: ## Apply prod environment
	cd environments/prod && terraform apply

prod-destroy: ## Destroy prod environment
	cd environments/prod && terraform destroy
