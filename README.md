# Crime-data-management
Data management solution created to support interdisciplinary research on crime, sentencing, and socio-economic conditions. Centralizing and standardizing heterogeneous data sources, the project reduces the time spent on data preparation and allows users to focus only on the analysis.

## Overview
Existing research on crime in Russia relies on data that is dispersed across judicial portals, statistical agencies, and academic publications. This project consolidates two complementary datasets into a normalised relational schema that supports queries spanning individual verdicts, court behaviour, regional socio-economic context, and policing capacity.

## Goal
This project implements a relational database schema for managing judicial, law enforcement, and socio-economic data.  
It models entities such as persons, cases, courts, police departments, investigations, and regional statistics.

---
---
## Repository structure
 
```
Crime-data-management/
│
├── crime_database.sql            # Full schema: CREATE TABLE, constraints, indexes
├── populate_db_final.ipynb       # Python pipeline: data loading, mapping, population
│
├── 105_1_regression_data_en.csv  # Case-level dataset (Zhuchkova & Kazun, 2023)
├── Registru.xlsx                 # Regional statistics dataset (2012–2019)
│
├── 2025_dmdb_project_proposal.pdf
├── Group_B_DbDM_Project_Proposal.pdf
├── Group_B_DbDM_Project_Presentation.pptx
└── README.md
```
---
---
## Data sources

### Case-level dataset (105_1_regression_data_en.csv)
20,531 sentencing records for homicide cases (Article 105, Part 1 of the Russian Criminal Code), covering 2013–2019. Extracted from official court decisions published on the Pravosudie judicial portal using machine learning methods. Published by Zhuchkova & Kazun (2023).
Each record includes defendant gender, victim gender, judge gender, parental status, guilty plea, recidivism type, aggravating and mitigating circumstances, relationship type between offender and victim, sentence duration in months, court name, and region.

### Regional dataset (Registru.xlsx)
Annual panel data for 76 Russian regions, 2012–2019. Includes murders per 1,000 inhabitants, Gini index, unemployment rate, clearance rate, mean population, and total Article 105 cases. Sourced from the Prosecutor General's Office portal (crimestat.ru) and the Unified Interdepartmental Statistical Information System (UISIS).

## Schema
 
The database is implemented in PostgreSQL under the `project` schema and comprises **26 tables** organised into seven functional layers.
 
| Layer | Tables |
|---|---|
| Geographic | `spatial_hierarchy`, `region_statistics`, `police_deployment` |
| Person | `person`, `person_status_history`, `offender_risk_assessment` |
| Judicial | `court`, `judge`, `case_judge`, `appeal`, `appeal_judge` |
| Case | `case_file`, `case_status`, `case_participant`, `role`, `case_location` |
| Crime | `crime_act`, `crime_motive` |
| Law enforcement | `police_department`, `police_officer`, `investigation`, `investigation_officer`, `evidence` |
| Outcome | `sentence`, `sentence_prison`, `prison` |
 
**`case_file`** is the central entity. Every other layer connects to it directly or indirectly.
 
### Key design decisions
 
- `spatial_hierarchy` is self-referencing, encoding the Russian administrative hierarchy (country → region → city → district) in a single table.
- `person` is the universal actor table — the same record is reused across offender, victim, judge, and officer roles, avoiding duplication.
- `case_status` and `role` are normalised lookup tables, replacing free-text columns with foreign key references to a controlled vocabulary.
- `sentence_prison` uses a three-column composite primary key `(sentence_id, prison_id, entry_date)` to support multiple prison transfers over time.
- Six junction tables resolve many-to-many relationships: `case_participant`, `case_judge`, `case_location`, `investigation_officer`, `appeal_judge`, `sentence_prison`.
