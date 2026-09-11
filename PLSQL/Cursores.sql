En PL/SQL, un cursor es una estructura que te permite recorrer un conjunto de filas recuperadas por una sentencia SELECT.
Hay dos tipos de cursores: explícitos e implícitos.

1.- Cursor Implícito
se crea automáticamente al ejecutar la sentencia SELECT. Luego, se recorre el conjunto de resultados utilizando un bucle FOR.

	BEGIN
		FOR empleado_rec IN (SELECT first_name, last_name, salary FROM employees order by salary desc) LOOP
			DBMS_OUTPUT.PUT_LINE('Nombre: ' || empleado_rec.first_name ||' '||empleado_rec.last_name||' - '||'Salario: ' || empleado_rec.salary);
		END LOOP;
	END;

2.- Cursor Explícito
se crea un cursor explícitamente. 
Hay que abrir el cursor, se recorren las filas con un bucle, y luego se cierra el cursor.


	DECLARE
    CURSOR empleados_cursor IS SELECT first_name, last_name, salary FROM employees order by salary desc;
    empleado_rec empleados_cursor%ROWTYPE;
	BEGIN
		OPEN empleados_cursor;
		LOOP
			FETCH empleados_cursor INTO empleado_rec;
			EXIT WHEN empleados_cursor%NOTFOUND;
			DBMS_OUTPUT.PUT_LINE('Nombre: ' || empleado_rec.first_name ||' '||empleado_rec.last_name||' - '||'Salario: ' || empleado_rec.salary);
		END LOOP;
		CLOSE empleados_cursor;
	END;


La principal diferencia entre los cursores implícitos y explícitos en PL/SQL radica en cómo se declaran y manejan.

1. Cursor Implícito:
– Declaración: Se crea automáticamente cuando ejecutas una sentencia SELECT.
– Sintaxis de Recorrido: Utiliza un bucle FOR para recorrer las filas directamente.

2. Cursor Explícito:
– Declaración: Se define y declara explícitamente antes de su uso.
– Sintaxis de Recorrido: Requiere abrir, fetchear y cerrar manualmente.

Los cursores implícitos son más simples de usar y no requieren una declaración explícita, pero pueden ser menos flexibles en términos de control. 
Los cursores explícitos brindan un mayor control y flexibilidad, pero a expensas de una sintaxis más detallada y un manejo manual más complejo. 
La elección entre ellos depende de los requisitos específicos de tu lógica de programación y manipulación de datos.

Cursor Implícito:

	Ventajas del Cursor Implícito:
	– Sintaxis más concisa y fácil de entender.
	– Automáticamente se ocupa de la apertura, fetch y cierre.

	Desventajas del Cursor Implícito:
	– Menos control explícito sobre la manipulación del cursor.
	– Limitado en términos de personalización y manejo de errores.

Cursor Explícito:

	Ventajas del Cursor Explícito:
	– Mayor control sobre la apertura, fetch, y cierre del cursor.
	– Posibilidad de realizar acciones específicas antes o después del fetch.

	Desventajas del Cursor Explícito:
	– Sintaxis más extensa y detallada.
	– Requiere manejo manual de apertura, fetch, y cierre.

Elección:
– Si la operación es simple y no requiere un control detallado del cursor, el cursor implícito puede ser más adecuado por su simplicidad.
– Si se necesita un mayor control sobre el cursor, como realizar acciones específicas antes o después del fetch, el cursor explícito ofrece más flexibilidad.

En general, la elección entre ambos tipos de cursores depende de la complejidad de la lógica requerida y del nivel de control que necesitas sobre la manipulación de los datos en la base de datos Oracle.

Manejo de Errores con Cursor Implícito:

	BEGIN
	  FOR empleado_rec IN (SELECT ename, sal FROM emp) LOOP
	BEGIN
	  -- Lógica de procesamiento aquí
	  DBMS_OUTPUT.PUT_LINE('Nombre: ' || empleado_rec.ename || ', Salario: ' || empleado_rec.sal);
	EXCEPTION
	WHEN OTHERS THEN
	  DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
	END;
	END LOOP;
	END;


Manejo de Errores con Cursor Explícito:

	DECLARE
	  CURSOR empleados_cursor IS
		SELECT ename, sal FROM emp;
		empleado_rec empleados_cursor%ROWTYPE;
	BEGIN
	  OPEN empleados_cursor;
	  LOOP
	   BEGIN
		 FETCH empleados_cursor INTO empleado_rec;
		 EXIT WHEN empleados_cursor%NOTFOUND;

	-- Lógica de procesamiento aquí
	  DBMS_OUTPUT.PUT_LINE('Nombre: ' || empleado_rec.ename || ', Salario: ' || empleado_rec.sal);
	EXCEPTION
	WHEN OTHERS THEN
	  DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
	  END;
	  END LOOP;
	  CLOSE empleados_cursor;
	END;

#################################
REF CURSOR
#################################

In PL/SQL, Cursor variables, also known as REF CURSORs, provide a dynamic and flexible means to handle query results. 
A cursor variable is a reference to a cursor, which can be opened, fetched, and closed dynamically at runtime.

Why Use REF CURSOR in PL/SQL?
Cursor variables with REF CURSOR are important in PL/SQL programming for below reasons:
	Dynamic SQL: They allow the creation and execution of dynamic SQL queries. This is useful when the structure of the query or the tables involved is not known at compile time.
	Reusability: Cursor variables can be reused across different parts of the program reducing code duplication and improving maintainability.
	Parameter Passing: They can be used to pass query results between different program units such as stored procedures or functions and enable more modular and flexible code.
	Data Manipulation: They enable complex data manipulation operations that may involve multiple queries or data sources.
	
Cursor variables in PL/SQL provide a means to work with dynamic SQL queries and results. 
Unlike explicit cursors, cursor variables allow the definition of a cursor without specifying the SQL query at compile-time. 
This flexibility is particularly useful when dealing with varying queries or when the query needs to be determined dynamically during runtime. 
REF CURSORs, associated with cursor variables enable the retrieval of query results. 	

1. Using PL/SQL Cursor Variable with REF CURSOR to Fetch Data Dynamically

		-- PL/SQL Block with Cursor Variable
		DECLARE
			TYPE ref_cursor_type IS REF CURSOR;
			cursor_variable ref_cursor_type;
			emp_id employees.employee_id%TYPE;
			emp_name employees.first_name%TYPE;
		BEGIN
			-- Dynamic Query using Cursor Variable
			OPEN cursor_variable FOR 'SELECT employee_id, first_name FROM employees';
			
			-- Fetch and Display Data
			LOOP
				FETCH cursor_variable INTO emp_id, emp_name;
				EXIT WHEN cursor_variable%NOTFOUND;
				DBMS_OUTPUT.PUT_LINE('Employee ID: ' || emp_id || ', Employee Name: ' || emp_name);
			END LOOP;

			-- Close Cursor
			CLOSE cursor_variable;
		END;
		/

2. Using Passing Cursor Variable as Parameter to a Procedure

		-- Procedure Accepting Cursor Variable as Parameter
		CREATE OR REPLACE PROCEDURE display_employee_data (
			p_cursor_variable IN OUT SYS_REFCURSOR
		)
		IS
			emp_id employees.employee_id%TYPE;
			emp_name employees.first_name%TYPE;
		BEGIN
			-- Fetch and Display Data
			LOOP
				FETCH p_cursor_variable INTO emp_id, emp_name;
				EXIT WHEN p_cursor_variable%NOTFOUND;
				DBMS_OUTPUT.PUT_LINE('Employee ID: ' || emp_id || ' - Employee Name: ' || emp_name);
			END LOOP;
		END;
		/

		-- PL/SQL Block Calling Procedure with Cursor Variable
		DECLARE
			TYPE ref_cursor_type IS REF CURSOR;
			cursor_variable ref_cursor_type;
		BEGIN
			-- Dynamic Query using Cursor Variable
			OPEN cursor_variable FOR 'SELECT employee_id, first_name FROM employees';
			
			-- Call Procedure with Cursor Variable as Parameter
			display_employee_data(p_cursor_variable => cursor_variable);

			-- Close Cursor
			CLOSE cursor_variable;
		END;
		/



Difference between Cursor and REF Cursor
Here is a concise table highlighting the key differences between Cursor and REF Cursor in PL/SQL:

Feature					Cursor										REF Cursor
-------					------										----------
Type					Static										Dynamic
SQL Binding				Query is predefined at compile-time			Query is dynamically assigned at runtime
SCOPE					Can be GLOBAL								you cannot define them OUTSIDE of a procedure / function
Usage					Specific to the defined query				Can be reused with multiple queries
Passing as Parameter	Cannot be passed between subprograms		Can be passed as a parameter (IN, OUT, IN OUT)
Flexibility				Less flexible (fixed query structure)		More flexible (dynamic query structure)
Memory Usage			More resource-intensive for large queries	More efficient for large or dynamic queries