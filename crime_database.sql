--  spatial hierarchy
CREATE TABLE project.spatial_hierarchy (
    location_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    type VARCHAR(50) NOT NULL CHECK (type IN ('country','region','city','district','other')),
    postal_code VARCHAR(20),
    parent_location_id INT REFERENCES project.spatial_hierarchy(location_id)
        ON DELETE SET NULL,
    UNIQUE (name, type, parent_location_id)
);

-- person
CREATE TABLE project.person (
    person_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    gender VARCHAR(20)
        CHECK (gender IN ('Male','Female','Other')),
    birth_date DATE
        CHECK (birth_date <= CURRENT_DATE),
    has_children BOOLEAN,
    nationality VARCHAR(100)
);

-- person status history
CREATE TABLE project.person_status_history (
    status_id SERIAL PRIMARY KEY,
    person_id INT NOT NULL
        REFERENCES project.person(person_id)
        ON DELETE CASCADE,
    education_level VARCHAR(100),
    employment_status VARCHAR(100),
    income_level NUMERIC(12,2)
        CHECK (income_level >= 0),
    valid_from DATE NOT NULL,
    valid_to DATE,
    CHECK (valid_to IS NULL OR valid_to >= valid_from)
);

-- police department
CREATE TABLE project.police_department (
    police_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    location_id INT NOT NULL
        REFERENCES project.spatial_hierarchy(location_id)
        ON DELETE RESTRICT,
    station_type VARCHAR(100),
    staff_count INT CHECK (staff_count >= 0),
    budget NUMERIC(15,2) CHECK (budget >= 0),
    UNIQUE (name, location_id)
);


-- police officer (added end_date in case an officer is retired)
CREATE TABLE project.police_officer (
    officer_id SERIAL PRIMARY KEY,
    police_id INT NOT NULL
        REFERENCES project.police_department(police_id)
        ON DELETE RESTRICT,
    person_id INT NOT NULL UNIQUE
        REFERENCES project.person(person_id)
        ON DELETE CASCADE,
    rank VARCHAR(100),
    date_joined DATE NOT NULL CHECK (date_joined <= CURRENT_DATE),
    end_date DATE CHECK (end_date IS NULL OR end_date >= date_joined),
    training_level VARCHAR(100)
);


-- court
CREATE TABLE project.court (
    court_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    location_id INT NOT NULL
        REFERENCES project.spatial_hierarchy(location_id)
        ON DELETE RESTRICT,
    court_type VARCHAR(100),
    established_year INT,
    UNIQUE (name, location_id),
    CHECK (established_year <= EXTRACT(YEAR FROM CURRENT_DATE)::INT)
);


-- judge
CREATE TABLE project.judge (
    judge_id SERIAL PRIMARY KEY,
    person_id INT NOT NULL UNIQUE
        REFERENCES project.person(person_id)
        ON DELETE RESTRICT,
    court_id INT NOT NULL
        REFERENCES project.court(court_id)
        ON DELETE RESTRICT,
    appointment_date DATE CHECK (appointment_date <= CURRENT_DATE),
    term_end DATE CHECK (term_end IS NULL OR term_end >= appointment_date),
    specialization VARCHAR(100)
);


-- prison
CREATE TABLE project.prison (
    prison_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    location_id INT NOT NULL
        REFERENCES project.spatial_hierarchy(location_id)
        ON DELETE RESTRICT,
    capacity INT NOT NULL CHECK (capacity >= 0),
    current_occupancy INT CHECK (current_occupancy >= 0),
    security_level VARCHAR(100),
    health_facilities TEXT,
    CHECK (current_occupancy <= capacity),
    UNIQUE (name, location_id)
);


-- case file
CREATE TABLE project.case_file (
    case_id SERIAL PRIMARY KEY,
    court_id INT NOT NULL
        REFERENCES project.court(court_id)
        ON DELETE RESTRICT,
    year INT NOT NULL CHECK (year >= 1900),
    case_status VARCHAR(50) NOT NULL,
    report_date DATE NOT NULL,
    trial_end_date DATE,
    guilty_plea BOOLEAN,
    CHECK (trial_end_date IS NULL OR trial_end_date >= report_date)
);


-- role
CREATE TABLE project.role (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL UNIQUE,
    role_description TEXT,
    legal_authority TEXT
);


-- case participant
CREATE TABLE project.case_participant (
    case_id INT NOT NULL REFERENCES project.case_file(case_id)
        ON DELETE CASCADE,
    person_id INT NOT NULL REFERENCES project.person(person_id)
        ON DELETE CASCADE,
    role_id INT NOT NULL REFERENCES project.role(role_id)
        ON DELETE RESTRICT,
    involvement_notes TEXT,
    participation_level VARCHAR(100),
    remarks TEXT,
    PRIMARY KEY (case_id, person_id, role_id)
);


-- case location
CREATE TABLE project.case_location (
    case_id INT NOT NULL REFERENCES project.case_file(case_id)
        ON DELETE CASCADE,
    location_id INT NOT NULL REFERENCES project.spatial_hierarchy(location_id)
        ON DELETE RESTRICT,
    PRIMARY KEY (case_id, location_id)
);


-- crime act
CREATE TABLE project.crime_act (
    act_id SERIAL PRIMARY KEY,
    case_id INT NOT NULL
        REFERENCES project.case_file(case_id)
        ON DELETE CASCADE,
    act_type VARCHAR(100) NOT NULL,
    description TEXT,
    date_of_act DATE CHECK (date_of_act <= CURRENT_DATE)
);


-- crime motive
CREATE TABLE project.crime_motive (
    motive_id SERIAL PRIMARY KEY,
    act_id INT NOT NULL
        REFERENCES project.crime_act(act_id)
        ON DELETE CASCADE,
    description TEXT NOT NULL
);


-- investigation
CREATE TABLE project.investigation (
    investigation_id SERIAL PRIMARY KEY,
    case_id INT NOT NULL
        REFERENCES project.case_file(case_id)
        ON DELETE RESTRICT,
    lead_investigator_id INT
        REFERENCES project.police_officer(officer_id)
        ON DELETE SET NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    investigation_status VARCHAR(100),
    CHECK (end_date IS NULL OR end_date >= start_date)
); -- we deleted success_rate NUMERIC(5,2) CHECK (success_rate BETWEEN 0 AND 100) since it can be computed => succes = trial_end_date is not null or succes = guilty_plea=TRUE


-- evidence
CREATE TABLE project.evidence (
    evidence_id SERIAL PRIMARY KEY,
    case_id INT NOT NULL
        REFERENCES project.case_file(case_id)
        ON DELETE CASCADE,
    evidence_type VARCHAR(100) NOT NULL,
    description TEXT,
    collected_date DATE CHECK (collected_date <= CURRENT_DATE),
    collected_by INT
        REFERENCES project.police_officer(officer_id)
        ON DELETE SET NULL,
    storage_status VARCHAR(100)
);


-- sentence
CREATE TABLE project.sentence (
    sentence_id SERIAL PRIMARY KEY,
    case_id INT NOT NULL
        REFERENCES project.case_file(case_id)
        ON DELETE CASCADE,
    total_duration_months INT CHECK (total_duration_months >= 0),
    sentence_type VARCHAR(100) NOT NULL,
    parole_eligibility BOOLEAN,
    fine_amount NUMERIC(12,2) CHECK (fine_amount >= 0)
);


-- appeal
CREATE TABLE project.appeal (
    appeal_id SERIAL PRIMARY KEY,
    case_id INT NOT NULL
        REFERENCES project.case_file(case_id)
        ON DELETE RESTRICT,
    court_id INT NOT NULL
        REFERENCES project.court(court_id)
        ON DELETE RESTRICT,
    date_filed DATE NOT NULL,
    result VARCHAR(100),
    appeal_status VARCHAR(100),
    decision_date DATE,
    CHECK (decision_date IS NULL OR decision_date >= date_filed)
);


-- appeal judge
CREATE TABLE project.appeal_judge (
    appeal_id INT NOT NULL REFERENCES project.appeal(appeal_id)
        ON DELETE CASCADE,
    judge_id INT NOT NULL REFERENCES project.judge(judge_id)
        ON DELETE RESTRICT,
    PRIMARY KEY (appeal_id, judge_id)
);


-- police deployment
CREATE TABLE project.police_deployment (
    region_id INT NOT NULL REFERENCES project.spatial_hierarchy(location_id)
        ON DELETE CASCADE,
    year INT NOT NULL CHECK (year >= 1900),
    officers_assigned INT CHECK (officers_assigned >= 0),
    patrol_units INT CHECK (patrol_units >= 0),
    budget NUMERIC(15,2) CHECK (budget >= 0),
    PRIMARY KEY (region_id, year)
);

-- ragion statsistics
CREATE TABLE project.region_statistics (
    region_id INT NOT NULL
        REFERENCES project.spatial_hierarchy(location_id)
        ON DELETE CASCADE,
    year INT NOT NULL CHECK (year >= 1900),
	mean_population BIGINT CHECK (mean_population >= 0),
    murders_per_1000 NUMERIC(6,3) CHECK (murders_per_1000 >= 0),
    gini_index NUMERIC(5,3) CHECK (gini_index BETWEEN 0 AND 1),
    unemployment_rate NUMERIC(5,2) CHECK (unemployment_rate BETWEEN 0 AND 100),
    clearance_rate NUMERIC(5,2) CHECK (clearance_rate BETWEEN 0 AND 100),
    total_article_105_cases INT CHECK (total_article_105_cases >= 0),
    mean_january_temperature NUMERIC(5,2),
    mean_june_temperature NUMERIC(5,2),
    PRIMARY KEY (region_id, year)
);

-- offeder risk assessment
CREATE TABLE project.offender_risk_assessment (
    assessment_id SERIAL PRIMARY KEY,
    person_id INT NOT NULL
        REFERENCES project.person(person_id)
        ON DELETE CASCADE,
    risk_score NUMERIC(5,2) CHECK (risk_score >= 0),
    assessment_date DATE NOT NULL CHECK (assessment_date <= CURRENT_DATE)
);

-- investigation officer
CREATE TABLE project.investigation_officer (
    investigation_id INT NOT NULL
        REFERENCES project.investigation(investigation_id)
        ON DELETE CASCADE,
    officer_id INT NOT NULL
        REFERENCES project.police_officer(officer_id)
        ON DELETE RESTRICT,
    role_in_investigation VARCHAR(100),
    hours_assigned INT CHECK (hours_assigned >= 0),
    PRIMARY KEY (investigation_id, officer_id)
);

-- sentence prison
CREATE TABLE project.sentence_prison (
    sentence_id INT NOT NULL
    	REFERENCES project.sentence(sentence_id)
    	ON DELETE CASCADE,
    prison_id INT NOT NULL
    	REFERENCES project.prison(prison_id)
    	ON DELETE cascade,
    entry_date DATE NOT NULL,
    release_date DATE,
    PRIMARY KEY (sentence_id, prison_id, entry_date)
);

-- case judge
CREATE TABLE project.case_judge (
    case_id INT REFERENCES project.case_file(case_id)
        ON DELETE CASCADE,
    judge_id INT REFERENCES project.judge(judge_id)
        ON DELETE RESTRICT,
    role_in_panel VARCHAR(100),
    PRIMARY KEY (case_id, judge_id)
);

-- improvements
ALTER TABLE project.case_file
DROP COLUMN case_status;

-- case status
CREATE TABLE project.case_status (
    case_status_id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

ALTER TABLE project.case_file
ADD COLUMN case_status_id INT;

ALTER TABLE project.case_file
ADD FOREIGN KEY (case_status_id)
REFERENCES project.case_status(case_status_id);

-- indexes
CREATE INDEX idx_case_file_court_id ON project.case_file(court_id);
CREATE INDEX idx_case_participant_person ON project.case_participant(person_id);
CREATE INDEX idx_crime_act_case ON project.crime_act(case_id);
CREATE INDEX idx_investigation_case ON project.investigation(case_id);
CREATE INDEX idx_evidence_case ON project.evidence(case_id);
CREATE INDEX idx_police_officer_police ON project.police_officer(police_id);
CREATE INDEX idx_judge_court ON project.judge(court_id);
CREATE INDEX idx_case_file_status ON project.case_file(case_status_id);
