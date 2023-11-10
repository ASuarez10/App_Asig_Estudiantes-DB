CREATE INDEX IDX_CITY_HEADQUARTERS
ON HEADQUARTERS(HEADQUARTER_CITY);

CREATE INDEX IDX_NAME_CAREERS
ON CAREERS(CAREER_NAME);

CREATE INDEX IDX_CITY_CANDIDATE
ON CANDIDATES(CITY);

CREATE INDEX IDX_ESTATE_CANDIDATE
ON CANDIDATES(ESTATE);

CREATE INDEX IDX_PROCESS_DATE_SELECTION_PROCESSES
ON SELECTION_PROCESSES(PROCESS_DATE);

CREATE INDEX IDX_ID_SELECTION_PROCESS_DATE_SELECTION
ON SELECTIONS(ID_SELECTION_PROCESS);