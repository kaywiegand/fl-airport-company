# Makefile – fl-airport-company
# -------------------------
# Shortcuts für die Portfolio-Pipeline.
# Verwendung: make <target>

.PHONY: portfolio

SKILL_SCRIPTS := ../wgnd-skills/project-case/scripts

# Kein eigenes Python-Projekt (BI-Export, kein src/notebooks) — pyyaml kommt ad-hoc
# über `uv run --with pyyaml` statt über ein projektlokales pyproject.toml.
portfolio: ## Portfolio-Artefakte regenerieren (archiviert alten Stand → public/archive/vN)
	uv run python $(SKILL_SCRIPTS)/archive_portfolio_artifacts.py
	uv run --with pyyaml python $(SKILL_SCRIPTS)/generate_json_from_slides.py
	uv run python $(SKILL_SCRIPTS)/generate_html_from_json.py
	uv run --with pyyaml python $(SKILL_SCRIPTS)/generate_index_from_portfolio.py
	uv run python $(SKILL_SCRIPTS)/convert_json_to_md.py
	uv run --with pyyaml python $(SKILL_SCRIPTS)/print_slide_matrix.py
	@echo "✅ Portfolio regeneriert · alter Stand in public/archive/ · öffne public/index.html"
