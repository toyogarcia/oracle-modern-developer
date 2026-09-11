En Oracle PL/SQL, los tipos de datos compuestos son estructuras que pueden contener múltiples valores o piezas de información de manera conjunta

Los dos tipos principales de estructuras de datos compuestas en Oracle PL/SQL son:

1. Registros (RECORD)
	Agrupan valores de diferentes tipos de datos relacionados.
	Funcionan como una fila de una tabla, donde cada campo tiene su propio nombre y tipo.
	Se pueden definir campos basados en tipos existentes usando %TYPE o %ROWTYPE. 

2. Colecciones (COLLECTIONS)
	Almacenan múltiples elementos del mismo tipo de dato.
	Se dividen en tres categorías principales en PL/SQL:
		Index-by tables (o arrays asociativos): Permiten almacenar datos con una clave arbitraria.
		Nested tables (tablas anidadas): Se pueden almacenar en columnas de bases de datos y consultar como tablas.
		Varrays (arrays de tamaño variable): Tienen un límite máximo de elementos definido previamente.

##############
RECORDS
##############

variable compuesta que permite almacenar valores de diferentes tipos de datos organizados en campos

Características principales
	Estructura similar a una fila: Agrupa datos relacionados, como los campos de una tabla o de una consulta de cursor.
	Acceso por puntos: Se accede a los valores individuales usando la notación nombre_registro.nombre_campo.
	Tipos definidos por el usuario: Se pueden crear tipos personalizados mediante la instrucción TYPE ... IS RECORD (...).
	Uso de %ROWTYPE: Permite declarar un registro de forma automática con la misma estructura que una tabla o un cursor existente

	DECLARE
	  TYPE t_empleado IS RECORD (
		nombre VARCHAR2(50),
		salario NUMBER
	  );
	  v_emp t_empleado;
	BEGIN
	  v_emp.nombre := 'Ana';
	  v_emp.salario := 2500;
	  DBMS_OUTPUT.PUT_LINE(v_emp.nombre || ' gana ' || v_emp.salario);
	END;

¿Para qué se utiliza?
	Agrupar datos relacionados: Almacenar campos de distinta naturaleza (por ejemplo: un ID numérico, un nombre de tipo texto y una fecha) en una sola variable.
	Simplificar consultas: Facilitar la lectura y el paso de información completa entre bloques PL/SQL, funciones y procedimientos sin declarar una variable independiente para cada columna.
	Trabajar con filas de tablas: Mapear registros devueltos por cursores o consultas SELECT ... INTO

Tipos de Registros
	1.- Definidos por el usuario (TYPE ... IS RECORD): Tú defines la estructura con los campos y tipos de datos que necesites.
	
		DECLARE
		  -- 1. Definir el tipo de registro
		  TYPE t_empleado IS RECORD (
			id_emp    NUMBER(5),
			nombre    VARCHAR2(50),
			salario   NUMBER(8,2)
		  );

		  -- 2. Declarar una variable de ese tipo
		  v_emp t_empleado;
		BEGIN
		  -- 3. Asignar valores usando la notación de punto (.)
		  v_emp.id_emp  := 1001;
		  v_emp.nombre  := 'Ana Pérez';
		  v_emp.salario := 2500.50;

		  -- 4. Mostrar los valores
		  DBMS_OUTPUT.PUT_LINE('ID: ' || v_emp.id_emp);
		  DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_emp.nombre);
		  DBMS_OUTPUT.PUT_LINE('Salario: ' || v_emp.salario);
		END;
		/

	
	2.-	Basados en tablas (%ROWTYPE): Heredan automáticamente la estructura de columnas y tipos de una tabla o vista existente.
	
		DECLARE
		  -- Declara un registro con la misma estructura que la tabla 'empleados'
		  v_empleado empleados%ROWTYPE;
		BEGIN
		  -- Selecciona una fila completa de la base de datos
		  SELECT * INTO v_empleado 
		  FROM empleados 
		  WHERE id = 10;

		  -- Accede a un campo específico del registro
		  DBMS_OUTPUT.PUT_LINE('El nombre es: ' || v_empleado.nombre);
		END;
		/

Pasar un RECORD como parámetro
	Para pasar un registro a un procedimiento o función, el tipo de dato debe estar definido en la sección de especificación de un paquete (Package). 
	Si lo defines dentro del DECLARE de un bloque anónimo, un procedimiento externo no podrá reconocer el tipo de dato.	

	Paso A: Crear el Paquete (Define el tipo de registro)
		CREATE OR REPLACE PACKAGE pkg_gestion_emp IS
		  -- Definimos el tipo RECORD de manera global en el paquete
		  TYPE t_cliente IS RECORD (
			id_cliente  NUMBER,
			nombre      VARCHAR2(100),
			credito     NUMBER
		  );

		  -- Declaramos un procedimiento que acepta este RECORD como parámetro IN OUT
		  PROCEDURE evaluar_credito (p_cli IN OUT t_cliente);
		END pkg_gestion_emp;
		/

	Paso B: Crear el Cuerpo del Paquete (Lógica del procedimiento)
	
		CREATE OR REPLACE PACKAGE BODY pkg_gestion_emp IS
		  PROCEDURE evaluar_credito (p_cli IN OUT t_cliente) IS
		  BEGIN
			-- Modificamos los datos dentro del registro recibido
			IF p_cli.credito < 1000 THEN
			   p_cli.credito := p_cli.credito + 500; -- Aumentamos el crédito
			END IF;
		  END evaluar_credito;
		END pkg_gestion_emp;
		/

	
	Paso C: Ejecución del procedimiento pasándole el RECORD

		DECLARE
		  -- Usamos el tipo RECORD anteponiendo el nombre del paquete
		  v_mi_cliente pkg_gestion_emp.t_cliente;
		BEGIN
		  -- Inicializamos los valores del registro
		  v_mi_cliente.id_cliente := 55;
		  v_mi_cliente.nombre     := 'Talleres Automotrices';
		  v_mi_cliente.credito    := 800;

		  -- Invocamos al procedimiento enviando el registro completo
		  pkg_gestion_emp.evaluar_credito(v_mi_cliente);

		  -- Comprobamos que el valor cambió en nuestro registro local
		  DBMS_OUTPUT.PUT_LINE('Cliente: ' || v_mi_cliente.nombre || 
							   ' - Nuevo Crédito: ' || v_mi_cliente.credito);
		END;
		/
	
		
	

##############
COLLECTIONS
##############


Index-by tables (o arrays asociativos)

	Las index-by tables (también llamadas arrays asociativos) se usan en Oracle PL/SQL para almacenar colecciones de datos en memoria de forma temporal y acceder a ellos rápidamente mediante una clave o índice.
	Almacenamiento temporal: Guardar filas o columnas de una tabla física para procesarlas en memoria sin consultar la base de datos repetidamente.
	Caché de datos frecuentes: Mantener listas de valores (como códigos de monedas, estados o parámetros) consultados al inicio de un proceso.
	Paso de parámetros: Agrupar conjuntos de datos para enviarlos entre procedimientos o funciones dentro de PL/SQL.
	Transformación y carga (ETL): Agrupar datos antes de hacer inserciones o actualizaciones masivas.
	Índices flexibles: Pueden usar claves numéricas (BINARY_INTEGER / PLS_INTEGER) o cadenas de texto (VARCHAR2)
	Crecimiento dinámico: No tienen un tamaño fijo; se expanden de forma automática conforme agregas elementos.
	Ámbito local: Solo existen en la memoria durante la ejecución del bloque PL/SQL o la sesión actual y no se pueden almacenar directamente en una tabla física de la base de datos sin un tratamiento previo
	
	
	Para llenar una index-by table automáticamente con datos de una tabla física real, la mejor práctica en Oracle PL/SQL es usar la cláusula BULK COLLECT. 
	Esto permite traer múltiples filas de un solo golpe desde el motor SQL al motor PL/SQL, reduciendo el cambio de contexto (context switching) y mejorando drásticamente el rendimiento.
	
	
		DECLARE
		   -- 1. Definimos un tipo basado en la estructura completa de una fila de la tabla EMPLOYEES
		   TYPE t_lista_empleados IS TABLE OF employees%ROWTYPE INDEX BY PLS_INTEGER;
		   
		   -- 2. Declaramos la variable de la colección
		   v_empleados t_lista_empleados;
		BEGIN
		   -- 3. Consultamos y llenamos la index-by table de forma masiva (BULK COLLECT)
		   SELECT *
		   BULK COLLECT INTO v_empleados
		   FROM employees
		   WHERE department_id = 50; -- Filtro de ejemplo

		   -- 4. Verificamos si se encontraron registros y los recorremos por su índice numérico
		   IF v_empleados.COUNT > 0 THEN
			  DBMS_OUTPUT.PUT_LINE('Se cargaron ' || v_empleados.COUNT || ' empleados en memoria.');
			  DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
			  
			  -- Recorremos desde el primer índice (1) hasta el último (v_empleados.COUNT)
			  FOR i IN 1 .. v_empleados.COUNT LOOP
				 DBMS_OUTPUT.PUT_LINE('ID: ' || v_empleados(i).employee_id || 
									  ' | Nombre: ' || v_empleados(i).first_name || 
									  ' | Salario: ' || v_empleados(i).salary);
			  END LOOP;
		   ELSE
			  DBMS_OUTPUT.PUT_LINE('No se encontraron empleados para ese departamento.');
		   END IF;
		   
		END;
		/

	Permiten almacenar datos con una clave arbitraria (arbitrary numbers and strings for subscript values).
	Associative arrays are sets of key-value pairs, where each key is unique and is used to locate a corresponding value in the array. The key can be an integer or a string.
	Assigning a value using a key for the first time adds that key to the associative array. Subsequent assignments using the same key update the same entry. 
	It is important to choose a key that is unique, either by using the primary key from a SQL table, or by concatenating strings together to form a unique value.

	Associative arrays help you represent data sets of arbitrary size, with fast lookup for an individual element without knowing its position within the array and without having to loop through all the array elements. 
	It is like a simple version of a SQL table where you can retrieve values based on the primary key. 
	For simple temporary storage of lookup data, associative arrays let you avoid using the disk space and network operations required for SQL tables.

	Because associative arrays are intended for temporary data rather than storing persistent data, you cannot use them with SQL statements such as INSERT and SELECT INTO. 
	You can make them persistent for the life of a database session by declaring the type in a package and assigning the values in a package body.

	DECLARE
	  TYPE emp_table_type IS TABLE OF employees.first_name%TYPE INDEX BY PLS_INTEGER;
	  my_emp_table  emp_table_type;
	  BEGIN
		  SELECT first_name
			BULK COLLECT INTO my_emp_table
		  FROM employees;
	 
		  FOR i IN my_emp_table.FIRST .. my_emp_table.LAST
		LOOP
		  DBMS_OUTPUT.put_line (my_emp_table (i));
		END LOOP;
	 END;
 

	DECLARE
		TYPE EmpTabTyp IS TABLE OF emp%ROWTYPE INDEX BY BINARY_INTEGER;
		emp_tab EmpTabTyp;
	BEGIN
	   /* Retrieve employee record. */
	   SELECT * INTO emp_tab(7468) FROM emp WHERE empno = 7468;
	END;

	Para llenar una index-by table automáticamente con datos de una tabla física real, la mejor práctica en Oracle PL/SQL es usar la cláusula BULK COLLECT. 
	Esto permite traer múltiples filas de un solo golpe desde el motor SQL al motor PL/SQL, reduciendo el cambio de contexto (context switching) y mejorando drásticamente el rendimiento.

	La combinación de BULK COLLECT (para leer) y FORALL (para escribir) es el estándar de oro en Oracle PL/SQL para el procesamiento masivo de datos.
	Mientras que un bucle FOR tradicional ejecuta una sentencia SQL por cada fila, FORALL envía todo el bloque de instrucciones de la colección al motor SQL en un solo viaje, 
	eliminando el intercambio de contexto (context switching) y multiplicando la velocidad de ejecución.
	Aquí tienes un ejemplo completo donde leemos datos con BULK COLLECT, modificamos los valores en memoria y luego actualizamos la base de datos masivamente con FORALL:

	DECLARE
	   -- 1. Definimos el tipo de colección basado en la tabla EMPLOYEES
	   TYPE t_lista_empleados IS TABLE OF employees%ROWTYPE INDEX BY PLS_INTEGER;
	   v_empleados t_lista_empleados;
	BEGIN
	   -- 2. BULK COLLECT: Traemos los empleados del departamento 50 a memoria
	   SELECT *
	   BULK COLLECT INTO v_empleados
	   FROM employees
	   WHERE department_id = 50;

	   -- 3. Bucle tradicional en memoria para modificar los datos de la colección
	   -- (Esto es muy rápido porque ocurre 100% en la memoria RAM)
	   FOR i IN 1 .. v_empleados.COUNT LOOP
		  -- Ejemplo: Aplicar un aumento del 10% de salario en la colección
		  v_empleados(i).salary := v_empleados(i).salary * 1.10;
	   END LOOP;

	   -- 4. FORALL: Enviamos todas las actualizaciones juntas a la base de datos
	   -- NOTA: Dentro de FORALL solo se permite UNA única sentencia DML (INSERT/UPDATE/DELETE)
	   FORALL i IN 1 .. v_empleados.COUNT
		  UPDATE employees
		  SET salary = v_empleados(i).salary
		  WHERE employee_id = v_empleados(i).employee_id;

	   -- 5. Confirmamos los cambios de la transacción
	   COMMIT;
	   
	   DBMS_OUTPUT.PUT_LINE('Se actualizaron ' || SQL%ROWCOUNT || ' empleados masivamente.');
	   
	EXCEPTION
	   WHEN OTHERS THEN
		  ROLLBACK;
		  DBMS_OUTPUT.PUT_LINE('Error en el proceso: ' || SQLERRM);
	END;
	/

	Reglas importantes
		al usar FORALLNo es un bucle común: No puedes meter lógica de negocio ni varias líneas de código dentro de un bloque FORALL. Solo se permite una sentencia INSERT, UPDATE o DELETE.
		Colecciones consecutivas: Por defecto, el rango 1 .. v_empleados.COUNT requiere que los índices de la colección sean consecutivos (sin huecos). 
			Si eliminas elementos intermedios, debes usar INDICES OF o VALUES OF en lugar de 1 .. N.
		Uso de memoria: Si la tabla real tiene millones de filas, hacer esto de golpe puede agotar la memoria del servidor (PGA).

	Para procesar volúmenes masivos de datos (cientos de miles o millones de filas) sin agotar la memoria del servidor (PGA), debes combinar BULK COLLECT, LIMIT y FORALL dentro de un bucle LOOP tradicional.
	Esta estructura procesa los datos en bloques de tamaño controlado (por ejemplo, de 5,000 en 5,000). 
	Entra en la base de datos, toma un bloque, lo procesa, lo guarda y repite el ciclo hasta que no queden registros.

		DECLARE
		   -- 1. Definimos el tamaño del bloque (ajustable según la memoria disponible)
		   c_limit_size CONSTANT PLS_INTEGER := 5000;

			-- 2. Necesitamos un CURSOR explícito para poder usar la cláusula LIMIT
			CURSOR c_empleados IS
			  SELECT * FROM employees WHERE department_id = 50;

		   -- 3. Definimos el tipo de colección y la variable
		   TYPE t_lista_empleados IS TABLE OF employees%ROWTYPE INDEX BY PLS_INTEGER;
		   v_empleados t_lista_empleados;
		BEGIN
		   -- 4. Abrimos el cursor
		   OPEN c_empleados;

		   LOOP
			  -- 5. Extraemos datos en bloques controlados usando LIMIT
			  FETCH c_empleados 
			  BULK COLLECT INTO v_empleados 
			  LIMIT c_limit_size;

			  -- 6. Condición de salida: Si el bloque actual está vacío, terminamos
			  EXIT WHEN v_empleados.COUNT = 0;

			  -- 7. Lógica de negocio en memoria para este bloque específico
			  FOR i IN 1 .. v_empleados.COUNT LOOP
				 v_empleados(i).salary := v_empleados(i).salary * 1.10; -- Aumento del 10%
			  END LOOP;

			  -- 8. Guardado masivo del bloque actual en la base de datos
			  FORALL i IN 1 .. v_empleados.COUNT
				 UPDATE employees
				 SET salary = v_empleados(i).salary
				 WHERE employee_id = v_empleados(i).employee_id;

			  -- 9. Control de transacciones (opcional por bloque o al final)
			  COMMIT; 
			  DBMS_OUTPUT.PUT_LINE('Bloque procesado: ' || v_empleados.COUNT || ' filas.');

		   END LOOP;

		   -- 10. Cerramos el cursor al finalizar todo el procesamiento
		   CLOSE c_empleados;

		EXCEPTION
		   WHEN OTHERS THEN
			  IF c_empleados%ISOPEN THEN
				 CLOSE c_empleados;
			  END IF;
			  ROLLBACK;
			  DBMS_OUTPUT.PUT_LINE('Error en el proceso: ' || SQLERRM);
		END;
		/


	Cuando procesas miles de filas en bloque con FORALL, si una sola fila falla (por ejemplo, por una violación de llave primaria o un valor nulo no permitido), 
	todo el bloque completo aborta de forma predeterminada y los cambios anteriores se pierden.
	Para evitar esto y hacer que tu código sea tolerante a fallos, debes usar la cláusula SAVE EXCEPTIONS. 
	Esto le dice a Oracle: "Si una fila falla, guárdame el error, no te detengas y continúa procesando las filas restantes". Al final del bloque, puedes revisar qué filas fallaron y por qué.
	
			DECLARE
			   c_limit_size CONSTANT PLS_INTEGER := 5000;

			   CURSOR c_empleados IS
				  SELECT * FROM employees WHERE department_id = 50;

			   TYPE t_lista_empleados IS TABLE OF employees%ROWTYPE INDEX BY PLS_INTEGER;
			   v_empleados t_lista_empleados;

			   -- 1. Declaramos la excepción especial para capturar errores masivos
			   e_bulk_errors EXCEPTION;
			   PRAGMA EXCEPTION_INIT(e_bulk_errors, -24381); -- Código de error de Oracle para fallos en FORALL
			   
			   v_error_count PLS_INTEGER;
			BEGIN
			   OPEN c_empleados;

			   LOOP
				  FETCH c_empleados BULK COLLECT INTO v_empleados LIMIT c_limit_size;
				  EXIT WHEN v_empleados.COUNT = 0;

				  -- Modificación en memoria (Ejemplo: forzamos un error si el ID es 100 poniendo salario negativo)
				  FOR i IN 1 .. v_empleados.COUNT LOOP
					 IF v_empleados(i).employee_id = 100 THEN
						v_empleados(i).salary := -500; -- Esto romperá un CHECK constraint de salario positivo
					 ELSE
						v_empleados(i).salary := v_empleados(i).salary * 1.10;
					 END IF;
				  END LOOP;

				  BEGIN
					 -- 2. Agregamos SAVE EXCEPTIONS a nuestro FORALL
					 FORALL i IN 1 .. v_empleados.COUNT SAVE EXCEPTIONS
						UPDATE employees
						SET salary = v_empleados(i).salary
						WHERE employee_id = v_empleados(i).employee_id;

					 COMMIT;
					 DBMS_OUTPUT.PUT_LINE('Bloque procesado con éxito: ' || v_empleados.COUNT || ' filas.');

				  -- 3. Capturamos la excepción específica del FORALL dentro del bucle
				  EXCEPTION
					 WHEN e_bulk_errors THEN
						-- SQL%BULK_EXCEPTIONS guarda una lista de los errores ocurridos en este bloque
						v_error_count := SQL%BULK_EXCEPTIONS.COUNT;
						DBMS_OUTPUT.PUT_LINE('¡Alerta! Se encontraron ' || v_error_count || ' errores en este bloque.');
						
						-- Recorremos cada error individual para registrarlo (Logs)
						FOR j IN 1 .. v_error_count LOOP
						   -- SQL%BULK_EXCEPTIONS(j).ERROR_INDEX nos dice qué fila de la colección falló
						   -- SQL%BULK_EXCEPTIONS(j).ERROR_CODE nos da el código numérico del error (ej. 2290 para CHECK constraint)
						   DBMS_OUTPUT.PUT_LINE('-> Error #' || j || 
												' | Fila afectada en colección: ' || SQL%BULK_EXCEPTIONS(j).ERROR_INDEX || 
												' | ID Empleado: ' || v_empleados(SQL%BULK_EXCEPTIONS(j).ERROR_INDEX).employee_id ||
												' | Código Oracle: ORA-' || SQL%BULK_EXCEPTIONS(j).ERROR_CODE);
						END LOOP;
						
						-- Hacemos COMMIT de las filas que SÍ se actualizaron correctamente
						COMMIT; 
				  END;

			   END LOOP;

			   CLOSE c_empleados;
			END;
			/





Nested tables (tablas anidadas)


	sirven para almacenar una colección de valores o filas completas (como una subtabla) dentro de una columna de una tabla principal
	Modelar atributos multivaluados: Permiten guardar varios valores (por ejemplo, múltiples teléfonos o correos electrónicos) en un solo registro sin crear una tabla relacional independiente con claves ajenas
	Representar jerarquías o datos complejos: Facilitan la manipulación de estructuras desnormalizadas o de objetos anidados de manera lógica en el nivel de aplicación
	Flexibilidad en colecciones: El número de elementos no es fijo, por lo que la lista puede crecer o disminuir dinámicamente
	
	¿Cuándo conviene usarlas?
	Cuando tienes datos dependientes de una entidad principal que solo se consultan y muestran junto con dicha entidad, sin necesidad de hacer búsquedas complejas o cruces masivos por esos valores internos
	Para simplificar el modelo relacional en casos donde una tabla secundaria independiente aportaría demasiada complejidad innecesaria
	
	Limitaciones importantes
	Las búsquedas filtrando directamente por los valores internos de la tabla anida pueden ser menos eficientes porque se almacenan en segmentos separados fuera de la tabla principal.
	Requieren inicialización explícita en PL/SQL antes de poder usarlas
	
	Se pueden almacenar en columnas de bases de datos y consultar como tablas.
	Las tablas anidadas (nested tables) en Oracle Database se usan para almacenar colecciones de datos con múltiples valores dentro de una sola columna o procesarlos de manera dinámica en bloques PL/SQL
	Almacenar atributos multivaluados: Permiten guardar una lista completa de elementos (como varios teléfonos o direcciones de un cliente) en una sola fila de una tabla principal sin crear otra tabla relacional tradicional
	Manejo de colecciones en PL/SQL: Se usan en la programación interna para almacenar conjuntos de datos en memoria de manera temporal, procesarlos de forma rápida y reutilizarlos mediante operadores como BULK COLLECT
	Modelado de objetos: Facilitan la representación de estructuras jerárquicas o complejas orientadas a objetos dentro de bases de datos relacionales
	
	Tamaño dinámico: No tienen un límite fijo de elementos; pueden crecer o encogerse según se necesite usando métodos como EXTEND
	Índice numérico: Sus elementos se numeran de forma secuencial comenzando desde el 1
	Almacenamiento físico: Cuando se usan como columnas en una tabla de la base de datos, Oracle almacena los datos de la tabla anidada en una tabla de almacenamiento independiente de manera transparente
	
	Imagina que quieres almacenar la información de varios empleados y, dentro de la misma tabla, guardar todos sus números de teléfono sin necesidad de crear una tabla relacional tradicional con Foreign Keys.
	
	-- 1. Creamos el TIPO de dato (una tabla anidada de textos)
	CREATE OR REPLACE TYPE lista_telefonos AS TABLE OF VARCHAR2(15);

	-- 2. Creamos la tabla principal usando el tipo anterior en una columna
	-- Es OBLIGATORIO indicar el nombre de la tabla oculta donde Oracle guardará los datos (NESTED TABLE ... STORE AS)
	CREATE TABLE empleados (
		id_empleado NUMBER PRIMARY KEY,
		nombre      VARCHAR2(50),
		telefonos   lista_telefonos
	) NESTED TABLE telefonos STORE AS telefonos_empleados_tab;

	-- 3. Insertar datos (se usa el constructor del tipo para añadir elementos)
	INSERT INTO empleados VALUES (
		1, 
		'Carlos Gómez', 
		lista_telefonos('555-0192', '555-0193', '555-0194')
	);

	INSERT INTO empleados VALUES (
		2, 
		'Ana López', 
		lista_telefonos('555-0789')
	);
	COMMIT;

	-- 4. Consultar los datos expandiendo la tabla anidada con el operador TABLE
	SELECT e.nombre, t.column_value AS telefono
	FROM empleados e, TABLE(e.telefonos) t;

	Diferencias clave: Nested Tables vs. VARRAYs
	Aunque ambos sirven para guardar colecciones de datos, se comportan de manera muy distinta a nivel interno:
	
	Característica			Tablas Anidadas(Nested Tables)																			VARRAYs(Variable-Size Arrays)
	---------------			--------------------------------																		------------------------------
	Límite de tamaño		Ilimitado. Su tamaño es dinámico y crece según se requiera.												Fijo. Se debe definir un tamaño máximo al crearlo (ej. VARRAY(5)).
	Almacenamiento			Fuera de la tabla principal (en una tabla de almacenamiento oculta).									Dentro de la propia fila (In-line), junto con el resto de columnas.
	Eliminar elementos		Se pueden eliminar elementos individuales en cualquier posición (DELETE(i)).							No se pueden borrar elementos individuales en medio; se debe recortar desde el final (TRIM).
	Índice denso o disperso	Puede volverse disperso (si borras el elemento 2, quedan el 1 y el 3).									Siempre es denso (los datos se guardan estrictamente correlativos).
	¿Cuándo usarlo?			Cuando no sabes cuántos elementos habrá o necesitas consultar y modificar elementos de forma masiva.	Cuando hay un límite claro y pequeño de elementos (ej. los 12 meses del año, los 7 días de la semana).
	
	
	Métodos de colección en PL/SQL (.EXTEND, .COUNT, etc.)
	
	DECLARE
		-- Definimos el tipo y la variable en el bloque PL/SQL
		TYPE lista_nombres IS TABLE OF VARCHAR2(50);
		mis_amigos lista_nombres;
		i NUMBER;
	BEGIN
		-- 1. Inicializamos la colección (constructor vacío)
		mis_amigos := lista_nombres();
		
		-- 2. Añadimos posiciones usando .EXTEND
		mis_amigos.EXTEND; -- Abre la posición 1
		mis_amigos(1) := 'Carlos';
		
		mis_amigos.EXTEND(2); -- Abre las posiciones 2 y 3 juntas
		mis_amigos(2) := 'Ana';
		mis_amigos(3) := 'Pedro';
		
		-- 3. Usamos .COUNT para saber el tamaño total
		DBMS_OUTPUT.PUT_LINE('Total de amigos: ' || mis_amigos.COUNT); -- Imprime 3
		
		-- 4. Recorremos la colección desde el .FIRST hasta el .LAST
		i := mis_amigos.FIRST;
		WHILE i IS NOT NULL LOOP
			DBMS_OUTPUT.PUT_LINE('Amigo ' || i || ': ' || mis_amigos(i));
			i := mis_amigos.NEXT(i); -- Avanza al siguiente índice válido
		END LOOP;
	END;
	/

	Actualizar y borrar un elemento específico de la tabla anidada
	
	UPDATE TABLE(SELECT telefonos FROM empleados WHERE id_empleado = 1) t
	SET t.column_value = '555-9999'
	WHERE t.column_value = '555-0192';
	
	DELETE FROM TABLE(SELECT telefonos FROM empleados WHERE id_empleado = 1) t
	WHERE t.column_value = '555-0193';

	(Nota: Al hacer este DELETE, la colección dentro de esa fila se vuelve dispersa, es decir, el índice de ese elemento se elimina pero los demás conservan su posición original).
	
	
	Rendimiento masivo con BULK COLLECT
	
	DECLARE
		-- Definimos un tipo tabla anidada basado en la estructura de la tabla empleados
		TYPE tipo_tabla_empleados IS TABLE OF empleados%ROWTYPE;
		mis_empleados tipo_tabla_empleados;
	BEGIN
		-- Traemos TODOS los registros de la base de datos a la memoria en un solo paso
		SELECT * 
		BULK COLLECT INTO mis_empleados 
		FROM empleados;
		
		-- Verificamos cuántos registros se cargaron en memoria
		DBMS_OUTPUT.PUT_LINE('Se procesaron ' || mis_empleados.COUNT || ' empleados en memoria.');
		
		-- Podemos acceder directamente a cualquier fila cargada
		IF mis_empleados.EXISTS(1) THEN
			DBMS_OUTPUT.PUT_LINE('El primer empleado cargado es: ' || mis_empleados(1).nombre);
		END IF;
	END;
	/



	

Varrays (arrays de tamaño variable)
	Tienen un límite máximo de elementos definido previamente.
	VARRAY (variable-size array) en Oracle PL/SQL sirve para almacenar un conjunto ordenado de un número fijo o máximo de elementos del mismo tipo de datos
	Agrupar datos: Permite guardar varios valores (como números o textos) bajo una misma variable en la memoria
	Límite de tamaño: Debes definir un número máximo de elementos al crearlo (su cardinalidad). No puedes superar este límite, aunque puede tener menos elementos de los permitidos
	Orden fijo: Los elementos mantienen una posición exacta y se numeran de forma secuencial con un índice entero positivo (comenzando normalmente en 1)
	Almacenamiento compacto: Se guarda de manera contigua. Si se almacena dentro de una tabla de la base de datos, el VARRAY completo se recupera como un único bloque de datos
	
	DECLARE
	  -- 1. Definir el tipo con un máximo de 3 elementos de tipo VARCHAR2
	  TYPE t_telefonos IS VARRAY(3) OF VARCHAR2(15);
	  
	  -- 2. Declarar la variable de ese tipo
	  v_mis_telefonos t_telefonos;
	BEGIN
	  -- 3. Inicializar los valores
	  v_mis_telefonos := t_telefonos('555-1234', '555-5678');
	  
	  -- 4. Acceder a un elemento mediante su índice
	  DBMS_OUTPUT.PUT_LINE(v_mis_telefonos(1)); -- Imprime '555-1234'
	END;
	/

	¿Cuándo conviene usarlo?
	Cuando conoces de antemano el tamaño máximo aproximado de la lista de elementos.
	Cuando el orden de los datos es importante para la lógica de tu programa.
	Si necesitas almacenar el vector directamente como una columna dentro de una tabla relacional de Oracle manteniendo el orden de los datos en bloque
	
	Puedes guardar un VARRAY directamente como el tipo de dato de una columna en una tabla. Esto es útil para almacenar listas pequeñas y ordenadas de datos relacionados (como los teléfonos de un cliente)
	
	Paso 1: Crear el tipo de dato VARRAY a nivel de base de datos
	Para poder usarlo en una tabla, el tipo debe ser un objeto global del esquema (usando CREATE TYPE), no puede estar definido solo dentro de un bloque DECLARE
	CREATE OR REPLACE TYPE t_telefonos AS VARRAY(5) OF VARCHAR2(20);
	
	Paso 2: Crear la tabla utilizando el VARRAY
	CREATE TABLE clientes (
    cliente_id  NUMBER PRIMARY KEY,
    nombre      VARCHAR2(50),
    telefonos   t_telefonos);

	Paso 3: Insertar y consultar datos
	Para insertar datos, debes "construir" el VARRAY llamando a su tipo:
	
	-- Insertar un cliente con 2 teléfonos (el máximo permitido por el tipo es 5)
	INSERT INTO clientes VALUES (1, 'Juan Pérez', t_telefonos('555-0101', '555-0202'));

	-- Insertar un cliente con 1 solo teléfono
	INSERT INTO clientes VALUES (2, 'María López', t_telefonos('555-0303'));
	
	Si haces un SELECT * FROM clientes;, Oracle te devolverá el registro completo con su bloque de teléfonos agrupado.
	
	
	
	Comparativa: VARRAY vs. Tablas Anidadas (Nested Tables)
	Aunque ambas son colecciones en PL/SQL, funcionan de maneras muy distintas. 
	Aquí tienes una tabla comparativa directa:
	
	Característica			VARRAY																			Tabla Anidada (Nested Table)
	--------------			-------																			-----------------------------
	Tamaño 					MáximoFijo. Se define al crearlo (ej. máximo 5 elementos).						Ilimitado. Crece dinámicamente según lo necesites.
	Índices					Secuenciales y densos. Van del 1 al N sin huecos intermedios.					Pueden ser dispersos. Permite borrar elementos intermedios dejando huecos.
	Orden de Datos			Mantiene el orden en el que se insertaron los elementos.						No garantiza el orden cuando se almacena en la base de datos.
	Almacenamiento físico	Se guarda en la misma línea (inline) de la tabla principal como un bloque.		Se guarda en una tabla externa oculta (store table) mediante un puntero.
	Uso ideal				Datos pequeños con límite claro (días de la semana, meses, pocos teléfonos).	Listas grandes de datos donde el orden no importa y el tamaño es impredecible.
	
	¿Cómo elegir entre ellos?
	Usa VARRAY si tu lista de datos nunca va a crecer descontroladamente y el orden en que los guardas es sagrado.
	Usa Nested Table si necesitas flexibilidad para borrar elementos del medio o si no tienes idea de cuántos elementos insertará el usuario.
	
	1. Métodos Integrados de las Colecciones
	Oracle proporciona funciones y procedimientos internos (métodos) para consultar el estado de un VARRAY o alterar su estructura. 
	Los más importantes son:
		.COUNT: Devuelve el número actual de elementos que tiene el VARRAY.
		.LIMIT: Devuelve el número máximo de elementos que puede llegar a almacenar (el tope definido en su creación).
		.FIRST y .LAST: Devuelven el primer y último índice del VARRAY (en un VARRAY denso, .FIRST siempre es 1 y .LAST es igual a .COUNT).
		.EXTEND: Añade un espacio en blanco al final del VARRAY para poder asignarle un nuevo valor. Es obligatorio usarlo antes de intentar escribir en una posición que aún no ha sido inicializada.
		
	2. Ejemplo Práctico: Recorrer, Modificar y Usar MétodosEn el siguiente bloque de código verás cómo se aplican todos estos conceptos juntos:
	
			DECLARE
			  -- Definimos un VARRAY con capacidad máxima de 5 elementos
			  TYPE t_precios IS VARRAY(5) OF NUMBER;
			  v_lista_precios t_precios;
			BEGIN
			  -- 1. Inicializamos el VARRAY con 3 elementos
			  v_lista_precios := t_precios(100, 200, 300);
			  
			  -- 2. Mostrar información de tamaño usando .COUNT y .LIMIT
			  DBMS_OUTPUT.PUT_LINE('Elementos actuales: ' || v_lista_precios.COUNT); -- Imprime 3
			  DBMS_OUTPUT.PUT_LINE('Capacidad máxima: ' || v_lista_precios.LIMIT);   -- Imprime 5
			  
			  -- 3. RECORRER EL VARRAY (Bucle clásico usando .FIRST y .LAST)
			  DBMS_OUTPUT.PUT_LINE('--- Lista Original ---');
			  FOR i IN v_lista_precios.FIRST .. v_lista_precios.LAST LOOP
				 DBMS_OUTPUT.PUT_LINE('Índice ' || i || ': ' || v_lista_precios(i));
			  END LOOP;
			  
			  -- 4. MODIFICAR ELEMENTOS EXISTENTES
			  -- Aplicamos un 10% de descuento al segundo elemento
			  v_lista_precios(2) := v_lista_precios(2) * 0.9;
			  
			  -- 5. AÑADIR UN NUEVO ELEMENTO (Uso obligatorio de .EXTEND)
			  -- Como v_lista_precios tiene 3 elementos, ampliamos a 4 espacios
			  v_lista_precios.EXTEND; 
			  v_lista_precios(4) := 450; -- Ahora asignamos el valor en la nueva posición
			  
			  -- 6. RECORRER DE NUEVO (Bucle alternativo usando directamente 1 .. .COUNT)
			  DBMS_OUTPUT.PUT_LINE('--- Lista Modificada ---');
			  FOR i IN 1 .. v_lista_precios.COUNT LOOP
				 DBMS_OUTPUT.PUT_LINE('Índice ' || i || ': ' || v_lista_precios(i));
			  END LOOP;
			  
			EXCEPTION
			  WHEN SUBSCRIPT_BEYOND_COUNT THEN
				DBMS_OUTPUT.PUT_LINE('Error: Intentaste acceder a una posición que no ha sido extendida.');
			  WHEN COLLECTION_IS_NULL THEN
				DBMS_OUTPUT.PUT_LINE('Error: La colección no ha sido inicializada.');
			END;
			/


		Reglas clave a tener en cuenta:
		Error SUBSCRIPT_BEYOND_COUNT: Ocurre si intentas hacer algo como v_lista_precios(4) := 500; sin haber llamado primero a v_lista_precios.EXTEND;. 
			Oracle necesita que le pidas permiso para agrandar la estructura en memoria.
		Error SUBSCRIPT_LIMIT_EXCEEDED: Si intentas hacer .EXTEND más veces del límite configurado (por ejemplo, intentar meter 6 elementos en el VARRAY de tamaño 5 anterior), 
			Oracle lanzará esta excepción.
		No puedes usar .DELETE(i) en elementos intermedios: A diferencia de las Tablas Anidadas, en un VARRAY no puedes borrar un elemento del medio (ej. la posición 2) para dejarla vacía, 
			ya que los VARRAYs deben ser estrictamente compactos y secuenciales. Solo puedes borrar todo el contenido usando .DELETE completo.
	
Choosing Which PL/SQL Collection Types to Use
If you already have code or business logic that uses some other language, you can usually translate that language's array and set types directly to PL/SQL collection types.

Choosing Between Nested Tables and Associative Arrays
	Both nested tables and associative arrays (formerly known as index-by tables) use similar subscript notation, but they have different characteristics when it comes to persistence and ease of parameter passing.
	Nested tables can be stored in a database column, but associative arrays cannot. 
	Nested tables are appropriate for important data relationships that must be stored persistently.
	
	Associative arrays are appropriate for relatively small lookup tables where the collection can be constructed in memory each time a procedure is called or a package is initialized. 
		They are good for collecting information whose volume is unknown beforehand, because there is no fixed limit on their size. 
		Their index values are more flexible, because associative array subscripts can be negative, can be nonsequential, and can use string values instead of numbers when appropriate.
	PL/SQL automatically converts between host arrays and associative arrays that use numeric key values. º
	The most efficient way to pass collections to and from the database server is to use anonymous PL/SQL blocks to bulk-bind input and output host arrays to associative arrays.

Choosing Between Nested Tables and Varrays
	Varrays are a good choice when the number of elements is known in advance, and when the elements are usually all accessed in sequence. 
	When stored in the database, varrays retain their ordering and subscripts.
	Each varray is stored as a single object, either inside the table of which it is a column (if the varray is less than 4KB) or outside the table but still in the same tablespace (if the varray is greater than 4KB). 
	You must update or retrieve all elements of the varray at the same time, which is most appropriate when performing some operation on all the elements at once. 
	But you might find it impractical to store and retrieve large numbers of elements this way.
	
	Nested tables can be sparse: you can delete arbitrary elements, rather than just removing an item from the end. 		
	Nested table data is stored out-of-line in a store table, a system-generated database table associated with the nested table. 
	This makes nested tables suitable for queries and updates that only affect some elements of the collection. 
	You cannot rely on the order and subscripts of a nested table remaining stable as the table is stored and retrieved, because the order and subscripts are not preserved when a nested table is stored in the database.
