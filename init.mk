define expand_exports
export $(word 1, $(subst =, , $(1))) := $(word 2, $(subst =, , $(1)))
endef

# expand PG* environment vars
$(foreach a,$(shell set -a; node_modules/.bin/pgexplode),$(eval $(call expand_exports,$(a))))

define create_extension
@psql -c "\dx $(subst db/,,$@)" | grep $(subst db/,,$@) > /dev/null 2>&1 || \
	psql -v ON_ERROR_STOP=1 -qX1c "CREATE EXTENSION $(subst db/,,$@)"
endef

define download
@mkdir -p $$(dirname $@)
@curl -sfL $(1) -o $@
endef

define create_relation
@psql -v ON_ERROR_STOP=1 -qXc "\d $(subst db/,,$@)" > /dev/null 2>&1 || \
	psql -v ON_ERROR_STOP=1 -qX1f sql/$(subst db/,,$@).sql
endef

define register_relation_target
.PHONY: db/$(strip $(1))

db/$(strip $(1)): db
	$$(call create_relation)
endef

$(foreach fn,$(shell ls sql/ 2> /dev/null | sed 's/\..*//'),$(eval $(call register_relation_target,$(fn))))

define extname
	$(subst .,,$(suffix $(1)))
endef