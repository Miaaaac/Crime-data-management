# Crime-data-management
Data management solution created to support interdisciplinary research on crime, sentencing, and socio-economic conditions. Centralizing and standardizing heterogeneous data sources, the project reduces the time spent on data preparation and allows users to focus only on the analysis.

## Goal
This project implements a relational database schema for managing judicial, law enforcement, and socio-economic data.  
It models entities such as persons, cases, courts, police departments, investigations, and regional statistics.

## Repository structure

```
Crime-data-management/
├─ README.md
├─ code_implementation
├─ datasets
├─ report
├─ presentation
```

The schema includes the following main components:

### Core Entities
- `person`
- `spatial_hierarchy`
- `court`
- `police_department`
- `prison`

### Case Management
- `case_file`
- `case_participant`
- `case_location`
- `case_judge`

### Crime & Investigation
- `crime_act`
- `crime_motive`
- `investigation`
- `investigation_officer`
- `evidence`

### Legal Process
- `sentence`
- `appeal`
- `appeal_judge`

### Analytical / Supporting Tables
- `region_statistics`
- `police_deployment`
- `offender_risk_assessment`
- `person_status_history`
