CREATE OR REPLACE PACKAGE SELECTION_PROCESS_PACKAGE AS

	FUNCTION GetCandidatesData RETURN SYS_REFCURSOR;
	FUNCTION GetCriteriaData(p_is_automatized NUMBER) RETURN SYS_REFCURSOR;
	FUNCTION GetCriteriaConfigurationData(p_id_criterion VARCHAR2, p_is_automated NUMBER) RETURN SYS_REFCURSOR;
	FUNCTION GetPriorizationData(p_id_criterion VARCHAR2, p_is_automated NUMBER) RETURN SYS_REFCURSOR;
	FUNCTION GetHeadquarter(p_id_headquarter_career NUMBER) RETURN VARCHAR2;
	FUNCTION GetCareerData(p_id_headquarter_career NUMBER) RETURN VARCHAR2;
	FUNCTION GetEducationTypeData(p_id_education NUMBER) RETURN VARCHAR2;
	FUNCTION GetValueInList(p_id_criterion VARCHAR2) RETURN VARCHAR2;
	FUNCTION ExecuteSelectionProcessPercentages (p_is_automatized NUMBER) RETURN SelectionsTableType;
	FUNCTION SortSelectionResults (p_results SelectionsTableType) RETURN SelectionsTableType;
	PROCEDURE StoreSelectionProcessData (p_is_automatized NUMBER);
	
END SELECTION_PROCESS_PACKAGE;

CREATE OR REPLACE PACKAGE BODY SELECTION_PROCESS_PACKAGE AS 

	--Function to get the candidates data and return it.
	FUNCTION GetCandidatesData RETURN SYS_REFCURSOR IS
		CANDIDATES_CURSOR SYS_REFCURSOR;
	BEGIN 
		OPEN CANDIDATES_CURSOR FOR
		SELECT ID_CANDIDATE, SEX, CITY, ESTATE, AGE, ICFES_GENERAL, ID_HEADQUARTER_CAREER, ID_EDUCATION 
		FROM CANDIDATES ;
		RETURN CANDIDATES_CURSOR;
	END GetCandidatesData;

	--Function to get the criteria data and return it.
	FUNCTION GetCriteriaData(p_is_automatized NUMBER) RETURN SYS_REFCURSOR IS
		CRITERIA_CURSOR SYS_REFCURSOR;
	BEGIN 
		IF(p_is_automatized = 0) THEN
			OPEN CRITERIA_CURSOR FOR
			SELECT C.ID_CRITERION,C.VALUE FROM CRITERIA C;
		ELSIF(p_is_automatized = 1) THEN
			OPEN CRITERIA_CURSOR FOR
			SELECT C.ID_CRITERION,C.SCHEDULED_VALUE FROM CRITERIA C;
		END IF;
		
		
		RETURN CRITERIA_CURSOR;
	END GetCriteriaData;

	--Function to get the criteria configuration data and return it.
	FUNCTION GetCriteriaConfigurationData(p_id_criterion VARCHAR2, p_is_automated NUMBER) RETURN SYS_REFCURSOR IS
		CONF_CURSOR SYS_REFCURSOR;
	BEGIN
		
		OPEN CONF_CURSOR FOR
		SELECT CC.ID_CRITERION, CC.VALUE, CC.PRIORITY, CC.PERCENTAGE, CC.COMPARATOR  FROM CRITERIA_CONFIGURATION CC
		WHERE CC.ID_CRITERION = p_id_criterion
		AND CC.AUTOMATIZED = p_is_automated
		AND ROWNUM = 1;
	
		RETURN CONF_CURSOR;
	END GetCriteriaConfigurationData;

	--Function to get the priorization data from a criterion
	FUNCTION GetPriorizationData(p_id_criterion VARCHAR2, p_is_automated NUMBER) RETURN SYS_REFCURSOR IS
		PRIO_CURSOR SYS_REFCURSOR;
	BEGIN
		OPEN PRIO_CURSOR FOR
		SELECT CC.ID_CRITERION, CC.VALUE, CC.PRIORITY, CC.PERCENTAGE, CC.COMPARATOR  FROM CRITERIA_CONFIGURATION CC
		WHERE CC.ID_CRITERION = p_id_criterion
		AND CC.AUTOMATIZED = p_is_automated
		AND CC.VALUE IS NOT NULL;
		RETURN PRIO_CURSOR;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RETURN NULL;
	END GetPriorizationData;

	--Function to get the headquarters in a string
	FUNCTION GetHeadquarter(p_id_headquarter_career NUMBER) RETURN VARCHAR2 IS 
		V_HEADQUARTER_CITY VARCHAR2(50);
	BEGIN
		SELECT h.HEADQUARTER_CITY
		INTO V_HEADQUARTER_CITY
		FROM HEADQUARTERS_CAREERS hc 
		INNER JOIN HEADQUARTERS h ON hc.ID_HEADQUARTER = h.ID_HEADQUARTER
		WHERE hc.ID_HEADQUARTER_CAREER = p_id_headquarter_career;
	
		RETURN V_HEADQUARTER_CITY;
	
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RETURN 'No data found for the id provided';
	END GetHeadquarter;
	
	--Function to get the career in a string	
	FUNCTION GetCareerData(p_id_headquarter_career NUMBER) RETURN VARCHAR2 IS 
		V_CAREER_NAME VARCHAR2(50);
	BEGIN
		SELECT c.CAREER_NAME
		INTO V_CAREER_NAME
		FROM HEADQUARTERS_CAREERS hc
		INNER JOIN CAREERS c ON hc.ID_CAREER = c.ID_CAREER
		WHERE hc.ID_HEADQUARTER_CAREER = p_id_headquarter_career;
	
		RETURN V_CAREER_NAME;
	
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RETURN 'No data found for the id provided';
	END GetCareerData;

	--Function to get the education type in a string
	FUNCTION GetEducationTypeData(p_id_education NUMBER) RETURN VARCHAR2 IS
		V_EDUCATION_NAME VARCHAR2(50);
	BEGIN 
		SELECT et.EDUCATION_TYPE_NAME
		INTO V_EDUCATION_NAME
		FROM EDUCATION_TYPES et
		WHERE et.EDUCATION_TYPE_NAME = p_id_education;
	
		RETURN V_EDUCATION_NAME;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RETURN 'No data found for the id provided';
	END GetEducationTypeData;

	--Function that recieves a criterion id and return the column value in a list split by commas (',')
	FUNCTION GetValueInList(p_id_criterion VARCHAR2) RETURN VARCHAR2 IS 
		V_VALUE VARCHAR2(1000);
		V_LIST VARCHAR2(1000);
	BEGIN
		--QUERY TO FIND VALUE
		SELECT c.VALUE INTO V_VALUE
		FROM CRITERIA c 
		WHERE c.ID_CRITERION = p_id_criterion;
	
		IF (V_VALUE != NULL) THEN
			--Verifies if there's a ',' in V_CRITERIA_VALUE. If true then the string is casted to a list
			IF INSTR(V_VALUE, ',') > 0 THEN
				--CONVERT TO LIST
				--REGEXP_SUBSTR extracts string with a regular expression.'[^,]+' indicates string without ','
				-- 1 means that the search process starts in the first character
				SELECT LISTAGG('''' || TRIM(REGEXP_SUBSTR(V_VALUE, '[^,]+', 1, LEVEL)) || '''', ', ')
		        INTO V_LIST
		        FROM dual
		        CONNECT BY REGEXP_SUBSTR(V_VALUE, '[^,]+', 1, LEVEL) IS NOT NULL;
			ELSE
				V_LIST := '''' || V_VALUE || '''';
			END IF;
				   
		    RETURN V_LIST;
	    ELSE
	    	RETURN NULL;
		END IF;
	
	END GetValueInList;
	
	--Procedure that carries out the selection process
	FUNCTION ExecuteSelectionProcessPercentages(p_is_automatized NUMBER) RETURN SelectionsTableType IS
	
		CANDIDATES_CURSOR SYS_REFCURSOR;
		CRITERIA_CURSOR SYS_REFCURSOR;
		CONF_CURSOR SYS_REFCURSOR;
		PRIO_CURSOR SYS_REFCURSOR;
		
		--Variables for candidates data
		V_CANDIDATE_ID VARCHAR2(11);
		V_CANDIDATE_SEX VARCHAR2(15);
	    V_CANDIDATE_CITY VARCHAR2(50);
	    V_CANDIDATE_ESTATE VARCHAR2(50);
	    V_CANDIDATE_AGE NUMBER;
	    V_CANDIDATE_ICFES NUMBER;
	   	V_ID_HEADQUARTERS_CAREER NUMBER;
	   	V_ID_EDUCATION NUMBER;
	   
	   	--Variables for headquarters and careers data
	   	V_HEADQUARTER_CAREER VARCHAR2(50);
	   	V_HEADQUARTER VARCHAR2(50);
	   	V_CAREER VARCHAR2(50);
	   
	   	V_EDUCATION VARCHAR2(50);
	   	
	   	V_CRITERIA_ID VARCHAR2(10);
	   	V_CRITERIA_VALUE VARCHAR2(100);
	   	
	   --Variables to fetch data from GetCriteriaConfigurationData
	   	V_CONF_ID VARCHAR2(10);
	   	V_CONF_VALUE VARCHAR2(50);
	   	V_CONF_PRIORITY NUMBER;
	   	V_CONF_PERCENTAGE NUMBER;
	   	V_CONF_COMPARATOR VARCHAR2(30);
	   	V_CONF_AUTOMATIZED CHAR(1);
	   
	   --Variables to fetch data from GetPriorizationData
	   	V_PRIO_ID VARCHAR2(10);
	   	V_PRIO_VALUE VARCHAR2(50);
	   	V_PRIO_PRIORITY NUMBER;
	   	V_PRIO_PERCENTAGE NUMBER;
	   	V_PRIO_COMPARATOR VARCHAR2(30);
	   	V_PRIO_AUTOMATIZED CHAR(1);
	   
		v_percentage NUMBER := 0;
		V_PRIORITY NUMBER := 30;
		v_list VARCHAR2(100);
	
		V_LIST_SEX VARCHAR(1000);
		V_LIST_CITY VARCHAR(1000);
		V_LIST_ESTATE VARCHAR(1000);
		V_LIST_EDUCATION_TYPE VARCHAR(1000);
		V_LIST_HEADQUARTER VARCHAR(1000);
		V_LIST_CAREER VARCHAR(1000);
	
		--Variable for quantitative value from criteria configuration converted to number
		V_QUANT_VALUE NUMBER := 0;
	
		V_ID_PROCESS NUMBER;
		V_CURRENT_DATE TIMESTAMP := SYSTIMESTAMP;
		V_DATE_STRING VARCHAR2(100);
	
		V_FINAL_RESULTS SelectionsTableType := SelectionsTableType();
       
      BEGIN
	    V_LIST_SEX := GetValueInList('1');
	    V_LIST_CITY := GetValueInList('2');
	    V_LIST_ESTATE := GetValueInList('3');
	    V_LIST_EDUCATION_TYPE := GetValueInList('5');
	    V_LIST_HEADQUARTER := GetValueInList('7');
	    V_LIST_CAREER := GetValueInList('8');
	   
	   	V_DATE_STRING := TO_CHAR(V_CURRENT_DATE, 'YYYY-MM-DD HH24:MI:SS');
	  
	   	--New record for new selection process is created.
	  	INSERT INTO SELECTION_PROCESSES(PROCESS_DATE)
	  	VALUES (V_DATE_STRING) RETURNING ID_PROCESS INTO V_ID_PROCESS;
	  
	  	--Creates a new partition in SELECTION with V_ID_PROCESS
	  	EXECUTE IMMEDIATE 'ALTER TABLE SELECTIONS ADD PARTITION p' || V_ID_PROCESS || ' VALUES (''' || V_ID_PROCESS || ''')';
	    
		CANDIDATES_CURSOR := GetCandidatesData();
		
		LOOP
			v_percentage := 0;
			V_PRIORITY := 30;
			FETCH CANDIDATES_CURSOR INTO V_CANDIDATE_ID,V_CANDIDATE_SEX,V_CANDIDATE_CITY,V_CANDIDATE_ESTATE,V_CANDIDATE_AGE,V_CANDIDATE_ICFES, V_ID_HEADQUARTERS_CAREER, V_ID_EDUCATION;
			EXIT WHEN CANDIDATES_CURSOR%NOTFOUND;
			
			CRITERIA_CURSOR := GetCriteriaData(p_is_automatized);
		
			LOOP 
				FETCH CRITERIA_CURSOR INTO V_CRITERIA_ID,V_CRITERIA_VALUE;
				EXIT WHEN CRITERIA_CURSOR%NOTFOUND;
			
				IF ((V_CRITERIA_VALUE IS NOT NULL) AND (V_CRITERIA_VALUE != 'Undefined')) THEN
				
					CONF_CURSOR := GetCriteriaConfigurationData(V_CRITERIA_ID, p_is_automatized);
					FETCH CONF_CURSOR INTO V_CONF_ID,V_CONF_VALUE,V_CONF_PRIORITY,V_CONF_PERCENTAGE,V_CONF_COMPARATOR;
					
						IF (V_CRITERIA_ID = '1') THEN
							IF (V_CANDIDATE_SEX IN (V_LIST_SEX)) THEN
								v_percentage := v_percentage + V_CONF_PERCENTAGE;
								
								--If GetCriteriaConfigurationData finds data then it calculates the priority
								PRIO_CURSOR := GetPriorizationData(V_CRITERIA_ID, p_is_automatized);
								IF(PRIO_CURSOR IS NOT NULL) THEN
									LOOP
										FETCH PRIO_CURSOR INTO V_PRIO_ID,V_PRIO_VALUE,V_PRIO_PRIORITY,V_PRIO_PERCENTAGE,V_PRIO_COMPARATOR;
										EXIT WHEN PRIO_CURSOR%NOTFOUND;
									
										IF (V_CANDIDATE_SEX = V_PRIO_VALUE) THEN
											V_PRIORITY := V_PRIORITY + TO_NUMBER(V_PRIO_PRIORITY);
										END IF;
								
									END LOOP;
								END IF;
							
								CLOSE PRIO_CURSOR;
								
							END IF;
						ELSIF (V_CRITERIA_ID = '2') THEN
							IF (V_CANDIDATE_CITY IN (V_LIST_CITY)) THEN
								v_percentage := v_percentage + V_CONF_PERCENTAGE;
								
								--If GetCriteriaConfigurationData finds data then it calculates the priority
								PRIO_CURSOR := GetPriorizationData(V_CRITERIA_ID, p_is_automatized);
								IF(PRIO_CURSOR IS NOT NULL) THEN
									LOOP
										FETCH PRIO_CURSOR INTO V_PRIO_ID,V_PRIO_VALUE,V_PRIO_PRIORITY,V_PRIO_PERCENTAGE,V_PRIO_COMPARATOR;
										EXIT WHEN PRIO_CURSOR%NOTFOUND;
									
										IF (V_CANDIDATE_CITY = V_PRIO_VALUE) THEN
											V_PRIORITY := V_PRIORITY + TO_NUMBER(V_PRIO_PRIORITY);
										END IF;
								
									END LOOP;
								END IF;
							
								CLOSE PRIO_CURSOR;
							END IF;
						ELSIF (V_CRITERIA_ID = '3') THEN
							IF (V_CANDIDATE_ESTATE IN (V_LIST_ESTATE)) THEN
								v_percentage := v_percentage + V_CONF_PERCENTAGE;
							
								--If GetCriteriaConfigurationData finds data then it calculates the priority
								PRIO_CURSOR := GetPriorizationData(V_CRITERIA_ID, p_is_automatized);
								IF(PRIO_CURSOR IS NOT NULL) THEN
									LOOP
										FETCH PRIO_CURSOR INTO V_PRIO_ID,V_PRIO_VALUE,V_PRIO_PRIORITY,V_PRIO_PERCENTAGE,V_PRIO_COMPARATOR;
										EXIT WHEN PRIO_CURSOR%NOTFOUND;
									
										IF (V_CANDIDATE_ESTATE = V_PRIO_VALUE) THEN
											V_PRIORITY := V_PRIORITY + TO_NUMBER(V_PRIO_PRIORITY);
										END IF;
								
									END LOOP;
								END IF;
							
								CLOSE PRIO_CURSOR;
							END IF;
						ELSIF (V_CRITERIA_ID = '4') THEN
							--AGE
							V_QUANT_VALUE := TO_NUMBER(V_CONF_VALUE);
							IF ((V_CONF_COMPARATOR = 'Mayor a' AND V_CANDIDATE_AGE > TO_NUMBER(V_CONF_VALUE)) OR (V_CONF_COMPARATOR = 'Menor a' AND V_CANDIDATE_AGE < TO_NUMBER(V_CONF_VALUE))) THEN
								v_percentage := v_percentage + TO_NUMBER(V_CONF_PERCENTAGE);
							
								IF ((V_CONF_COMPARATOR = 'Mayor a' AND V_CANDIDATE_AGE > TO_NUMBER(V_CONF_PRIORITY)) 
											OR 
											(V_CONF_COMPARATOR = 'Menor a' AND V_CANDIDATE_AGE < TO_NUMBER(V_CONF_PRIORITY))) THEN
											V_PRIORITY := V_PRIORITY + TO_NUMBER(V_CONF_PRIORITY);
								ELSE
									V_PRIORITY := V_PRIORITY + TO_NUMBER(V_CONF_PRIORITY) + 1;
								END IF;
							
							END IF;
						ELSIF (V_CRITERIA_ID = '5') THEN
							V_EDUCATION := GetEducationTypeData(V_ID_EDUCATION);
							IF (V_EDUCATION IN (V_LIST_EDUCATION_TYPE)) THEN
								v_percentage := v_percentage + V_CONF_PERCENTAGE;
							
								--If GetCriteriaConfigurationData finds data then it calculates the priority
								PRIO_CURSOR := GetPriorizationData(V_CRITERIA_ID, p_is_automatized);
								IF(PRIO_CURSOR IS NOT NULL) THEN
									LOOP
										FETCH PRIO_CURSOR INTO V_PRIO_ID,V_PRIO_VALUE,V_PRIO_PRIORITY,V_PRIO_PERCENTAGE,V_PRIO_COMPARATOR;
										EXIT WHEN PRIO_CURSOR%NOTFOUND;
									
										IF (V_EDUCATION = V_PRIO_VALUE) THEN
											V_PRIORITY := V_PRIORITY + TO_NUMBER(V_PRIO_PRIORITY);
										END IF;
									END LOOP;
								END IF;
							
								CLOSE PRIO_CURSOR;
							END IF;
						ELSIF (V_CRITERIA_ID = '6') THEN
							--ICFES
							V_QUANT_VALUE := TO_NUMBER(V_CONF_VALUE);
							IF ((V_CONF_COMPARATOR = 'Mayor a' AND V_CANDIDATE_ICFES > V_QUANT_VALUE) OR (V_CONF_COMPARATOR = 'Menor a' AND V_CANDIDATE_ICFES < V_QUANT_VALUE)) THEN
								v_percentage := v_percentage + V_CONF_PERCENTAGE;
							
								IF ((V_CONF_COMPARATOR = 'Mayor a' AND V_CANDIDATE_AGE > TO_NUMBER(V_CONF_PRIORITY)) 
											OR 
											(V_CONF_COMPARATOR = 'Menor a' AND V_CANDIDATE_AGE < TO_NUMBER(V_CONF_PRIORITY))) THEN
											
											V_PRIORITY := V_PRIORITY + TO_NUMBER(V_CONF_PRIORITY);
								ELSE
									V_PRIORITY := V_PRIORITY + TO_NUMBER(V_CONF_PRIORITY) + 1;
								END IF;
							
							END IF;
						ELSIF (V_CRITERIA_ID = '7') THEN
							V_HEADQUARTER := GetHeadquarter(V_ID_HEADQUARTERS_CAREER);
							IF (V_HEADQUARTER IN (V_LIST_HEADQUARTER)) THEN
								v_percentage := v_percentage + V_CONF_PERCENTAGE;
							
								--If GetCriteriaConfigurationData finds data then it calculates the priority
								PRIO_CURSOR := GetPriorizationData(V_CRITERIA_ID, p_is_automatized);
								IF(PRIO_CURSOR IS NOT NULL) THEN
									LOOP
										FETCH PRIO_CURSOR INTO V_PRIO_ID,V_PRIO_VALUE,V_PRIO_PRIORITY,V_PRIO_PERCENTAGE,V_PRIO_COMPARATOR;
										EXIT WHEN PRIO_CURSOR%NOTFOUND;
									
										IF (V_HEADQUARTER = V_PRIO_VALUE) THEN
											V_PRIORITY := V_PRIORITY + TO_NUMBER(V_PRIO_PRIORITY);
										END IF;
									END LOOP;
								END IF;
							
								CLOSE PRIO_CURSOR;
							END IF;
						ELSIF (V_CRITERIA_ID = '8') THEN
							V_CAREER := GetCareerData(V_ID_HEADQUARTERS_CAREER);
							IF (V_CAREER IN (V_LIST_CAREER)) THEN
								v_percentage := v_percentage + V_CONF_PERCENTAGE;
							
								--If GetCriteriaConfigurationData finds data then it calculates the priority
								PRIO_CURSOR := GetPriorizationData(V_CRITERIA_ID, p_is_automatized);
								IF(PRIO_CURSOR IS NOT NULL) THEN
									LOOP
										FETCH PRIO_CURSOR INTO V_PRIO_ID,V_PRIO_VALUE,V_PRIO_PRIORITY,V_PRIO_PERCENTAGE,V_PRIO_COMPARATOR;
										EXIT WHEN PRIO_CURSOR%NOTFOUND;
									
										IF (V_CAREER = V_PRIO_VALUE) THEN
											V_PRIORITY := V_PRIORITY + TO_NUMBER(V_PRIO_PRIORITY);
										END IF;
									END LOOP;
								END IF;
							
								CLOSE PRIO_CURSOR;
							END IF;
						END IF;
				
					CLOSE CONF_CURSOR;
							
				END IF;
			
			END LOOP;
			
		
			CLOSE CRITERIA_CURSOR;
		
			V_FINAL_RESULTS.EXTEND;
			V_FINAL_RESULTS(V_FINAL_RESULTS.LAST) := SELECTIONS_RECORD(ID_INCREMENT_SELECTIONS.NEXTVAL, V_CANDIDATE_ID, V_ID_PROCESS, v_percentage, V_PRIORITY);
			
		END LOOP;
		
		--V_FINAL_RESULTS := V_FINAL_RESULTS.ORDER BY PERCENTAGE DESC, PRIORITY ASC;
		--V_FINAL_RESULTS := SELECT * FROM TABLE(V_FINAL_RESULTS) ORDER BY PERCENTAGE DESC, PRIORITY ASC;
		--V_FINAL_RESULTS := MULTISET(SELECT * FROM TABLE(V_FINAL_RESULTS) ORDER BY PERCENTAGE DESC, PRIORITY ASC);
	
		CLOSE CANDIDATES_CURSOR;
		RETURN V_FINAL_RESULTS;
	END ExecuteSelectionProcessPercentages;

	--Procedure to execute selection process and store data in SELECTIONS table
	PROCEDURE StoreSelectionProcessData(p_is_automatized NUMBER) IS
		V_FINAL_RESULTS SelectionsTableType;
		V_FINAL_RESULTS_SORTED SelectionsTableType;
	
	BEGIN
		V_FINAL_RESULTS := ExecuteSelectionProcessPercentages(p_is_automatized);
		V_FINAL_RESULTS_SORTED := SortSelectionResults(V_FINAL_RESULTS);
		
		FOR i IN 1..V_FINAL_RESULTS_SORTED.COUNT LOOP
			INSERT INTO SELECTIONS (ID_SELECTION, ID_CANDIDATE, ID_SELECTION_PROCESS, PERCENTAGE, PRIORITY)
			VALUES (V_FINAL_RESULTS_SORTED(i).ID_SELECTION, V_FINAL_RESULTS_SORTED(i).ID_CANDIDATE, V_FINAL_RESULTS_SORTED(i).ID_SELECTION_PROCESS, 
					V_FINAL_RESULTS_SORTED(i).PERCENTAGE, V_FINAL_RESULTS_SORTED(i).PRIORITY);
		END LOOP;
		
		--Delete records used in the selection process	
		--DELETE FROM CRITERIA_CONFIGURATION cc 
		--WHERE cc.AUTOMATIZED = p_is_automatized;
		--COMMIT;
	
	END StoreSelectionProcessData;

	--Function to sort selection process results
	FUNCTION SortSelectionResults (p_results SelectionsTableType) RETURN SelectionsTableType IS
	
		V_FINAL_RESULTS_SORTED SelectionsTableType;
	
	BEGIN
	
		V_FINAL_RESULTS_SORTED := p_results;
		
		FOR i IN 1..V_FINAL_RESULTS_SORTED.COUNT - 1 LOOP
	        FOR j IN 1..V_FINAL_RESULTS_SORTED.COUNT - i LOOP
	            IF V_FINAL_RESULTS_SORTED(j).PERCENTAGE < V_FINAL_RESULTS_SORTED(j + 1).PERCENTAGE OR
	               (V_FINAL_RESULTS_SORTED(j).PERCENTAGE = V_FINAL_RESULTS_SORTED(j + 1).PERCENTAGE AND
	                V_FINAL_RESULTS_SORTED(j).PRIORITY > V_FINAL_RESULTS_SORTED(j + 1).PRIORITY) THEN
	                -- Intercambiar elementos si están en el orden incorrecto
	                DECLARE
	                    TEMP SELECTIONS_RECORD;
	                BEGIN
	                    TEMP := V_FINAL_RESULTS_SORTED(j);
	                    V_FINAL_RESULTS_SORTED(j) := V_FINAL_RESULTS_SORTED(j + 1);
	                    V_FINAL_RESULTS_SORTED(j + 1) := TEMP;
	                END;
	            END IF;
	        END LOOP;
	    END LOOP;
		RETURN V_FINAL_RESULTS_SORTED;
	END SortSelectionResults;
	

END SELECTION_PROCESS_PACKAGE;--FIN DEL PAQUETE



DECLARE
	p_is_automatized NUMBER := 0;
BEGIN
	SELECTION_PROCESS_PACKAGE.StoreSelectionProcessData(p_is_automatized);
END;


--Borrado
DROP PACKAGE SELECTION_PROCESS_PACKAGE;
DROP PACKAGE BODY SELECTION_PROCESS_PACKAGE;

