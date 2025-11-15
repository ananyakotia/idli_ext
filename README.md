# India Data Lab Initiative (IDLI)

## Overview
The India Data Lab Initiative (IDLI) harmonizes India’s flagship household and firm surveys so researchers can work with consistent, analysis-ready microdata. By standardizing layouts, reconciling evolving classification systems, and validating outputs against official benchmarks, the lab lowers the fixed cost of using datasets such as the National Sample Surveys (NSS) and the Annual Survey of Industries (ASI).

## Repository layout
- `code/asi/` – Stata workflows to clean ASI state-by-industry panels and produce validation graphics (for example, `clean_asi_nic3xstate.do` and `validation_graphs.do`).【F:code/asi/clean_asi_nic3xstate.do†L1-L44】【F:code/asi/validation_graphs.do†L1-L30】
- `code/nss/` – Harmonization pipelines for NSS consumption, labor, and enterprise surveys along with shared resources such as district concordances.【F:code/nss/nss_cons/00_master_nss_cons.do†L1-L13】【F:code/nss/nss_lab/00_master_nss_lab.do†L1-L12】【F:code/nss/district_concordance/nss_lab_ent_dist_merge.do†L1-L34】
- `documentation/` – Supporting materials referenced by the scripts (for example, district concordance workbooks consumed by `nss_lab_ent_dist_merge.do`).【F:code/nss/district_concordance/nss_lab_ent_dist_merge.do†L5-L24】

## Harmonization workflows
### NSS surveys
1. **Environment setup** – Run `code/nss/00_preamble.do` to configure system paths, toggle package installation, and register shared directories for NSS/ASI processing.【F:code/nss/00_preamble.do†L1-L120】 Update the `global root` candidates or add your own block if your folder structure differs.
2. **Household consumption** – Execute `code/nss/nss_cons/00_master_nss_cons.do` to sequentially clean each survey round listed in `local years` and then append the harmonized blocks.【F:code/nss/nss_cons/00_master_nss_cons.do†L1-L13】
3. **Employment & labor** – Use `code/nss/nss_lab/00_master_nss_lab.do` to process person- and household-level files, derive consistent district/industry/occupation codes, and assemble analysis files and figures.【F:code/nss/nss_lab/00_master_nss_lab.do†L1-L35】 Downstream scripts in the same folder build shared concordances (`02_nss_consistent_districts.do`, `03_consistent_industry_codes.do`, etc.) and generate diagnostics (`05a_nss_lab_graphs.do`, `05b_nss_lab_graphs.do`).
4. **Enterprise surveys** – The enterprise workflow mirrors the structure above; use the scripts in `code/nss/nss_ent/` together with the district harmonization utilities located in `code/nss/district_concordance/` (see `nss_lab_ent_dist_merge.do` for an example merge between labor and enterprise district lists).【F:code/nss/district_concordance/nss_lab_ent_dist_merge.do†L1-L34】

### ASI surveys
The ASI cleaning pipeline (`code/asi/clean_asi_nic3xstate.do`) iterates over Excel workbooks that report 3-digit NIC activity by state, drops empty columns, generates standardized year/state identifiers, and reshapes the content into machine-readable format.【F:code/asi/clean_asi_nic3xstate.do†L1-L44】 The companion `validation_graphs.do` script aggregates cleaned data, merges it with historical ASI extracts, and exports comparison charts for quality checks.【F:code/asi/validation_graphs.do†L1-L30】

## Data & documentation assets
- District concordance spreadsheets in `documentation/district_concordance/` are imported directly by the Stata code to reconcile NSS labor and enterprise district codes before merging or validation.【F:code/nss/district_concordance/nss_lab_ent_dist_merge.do†L5-L24】
- Additional methodological notes, cleaning logs, and institutional documents live under `documentation/` and can be referenced as needed when adapting the workflows.

## Getting started
1. **Prerequisites** – Stata 17 or later (MP/SE) with access to the proprietary NSS/ASI microdata. Some scripts optionally install user-written packages listed in `00_preamble.do`.
2. **Clone the repository** and place it inside the shared directory referenced by your `global root` (e.g., Dropbox or OneDrive) so the relative paths defined in `00_preamble.do` resolve correctly.【F:code/nss/00_preamble.do†L56-L116】
3. **Configure globals** – Modify `code/nss/00_preamble.do` if your environment differs, then run it from Stata to set `$idl`, `$idl_git`, `$code`, and other macros.
4. **Run the desired master script** – For example, `do code/nss/nss_cons/00_master_nss_cons.do` will call all round-specific cleaners and append routines for the consumption surveys.【F:code/nss/nss_cons/00_master_nss_cons.do†L1-L13】 Monitor the log files (where provided) to verify each block completes.
5. **Validate outputs** – Use the graphing/diagnostic scripts (`code/asi/validation_graphs.do`, `code/nss/nss_lab/05a_nss_lab_graphs.do`, etc.) to benchmark aggregates before distributing cleaned data.【F:code/asi/validation_graphs.do†L1-L30】【F:code/nss/nss_lab/00_master_nss_lab.do†L1-L35】

## Team
- **Ananya Kotia** – Founder and Director  •  [www.ananyakotia.com](https://www.ananyakotia.com)
- **Bharat Singhal** – Research Associate
- **Naila Fatima** – Research Associate (2023–25)
- **Bommi Reddy Meghana** – Research Manager
- **Ayush Chaudhary** – Research Associate

## Contributing
1. Fork the repository and create a feature branch.
2. Run the relevant master script(s) and validation routines to ensure harmonized outputs remain consistent.
3. Submit a pull request summarizing the methodological change, affected rounds, and validation evidence.

Private raw data are **not** stored in this repository; only code and documentation needed to reproduce the harmonized releases are included.