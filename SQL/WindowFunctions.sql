################################
# ROW_NUMBER()
################################

# Asigna un entero secuencial a cada fila en la particion. 
# Si dos o mas filas tienen el mismo valor en la clausula ORDER BY, estas filas reciben numeros de fila distintos.
# Para asegurar el orden en el caso del mismo valor para varias filas, puedes añadir a la clausula order by otras columnas que aserguren que los datos se devuelven siempre en el mismo orden.

# Ejercicio
# Obtén todas las ventas mostrando:vendedor,fecha,importe,numero_de_venta
# El número debe reiniciarse para cada vendedor y ordenar sus ventas de mayor a menor importe.

SELECT vendedor,
       fecha_venta,
       importe, 
       ROW_NUMBER() OVER (PARTITION BY vendedor ORDER BY importe DESC) AS numero_de_venta 
FROM ventas;

# PARTITION BY vendedor hace que la numeración se reinicie para cada vendedor.
# ORDER BY importe DESC hace que la venta de mayor importe reciba el número 1.


# Otros ejemplos

SELECT Department_id,employee_id,salary,
    ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS row_num
FROM employees
order by department_id

# Get third max salary
WITH SALARIOS AS
(
select employee_id, department_id, salary,
       row_number() over (partition by department_id order by department_id, salary desc) as salary_position
from employees
)
select * from salarios where salary_position = 3


# ROW_NUMBER to delete duplicates

SELECT rowid, id_cliente, nombre, email,
       ROW_NUMBER() OVER (
           PARTITION BY id_cliente, nombre, email 
           ORDER BY rowid --ORDER BY rowid to ensure to keep the first record inserted pyshically in the database
       ) AS fila_num
FROM clientes;

DELETE FROM clientes
WHERE rowid IN (
    SELECT registro_id 
    FROM (
        SELECT rowid AS registro_id,
               ROW_NUMBER() OVER (
                   PARTITION BY id_cliente, nombre, email 
                   ORDER BY rowid
               ) AS fila_num
        FROM clientes
    )
    WHERE fila_num > 1
);

################################
RANK 
################################

# Assigns a unique rank to each distinct row within the partition based on the ORDER BY clause. 
# Rows with the same values in the ORDER BY clause will receive the same rank, and the next row will receive a rank that increments by 1 rank.

# Ejercicio
# Para cada departamento, muestra las ventas ordenadas por importe

SELECT Departamento, importe,
    RANK() OVER (PARTITION BY departamento ORDER BY importe DESC) AS rank
FROM ventas

################################
DENSE_RANK
################################

# Assigns a unique rank to each distinct row in a result set, leaving no gaps in ranking when there are ties. 
# It's similar to the RANK() function, but it doesn't leave gaps between ranks when there are ties.

# Ejercicio
# Para cada departamento, muestra las ventas ordenadas por importe

SELECT Departamento, importe,
    DENSE_RANK() OVER (PARTITION BY departamento ORDER BY importe DESC) AS rank
FROM ventas

# Ejemplos:

# Se pueden combinar las funciones y omitir la clausula partition by:

SELECT Employee_id, Salary, Department_id,
  ROW_NUMBER() OVER(ORDER BY department_id DESC) ROW_NUMBER,
  RANK() OVER(ORDER BY Salary DESC) RANK,
  DENSE_RANK() OVER(ORDER BY department_id DESC) DENSE_RANK
 FROM Employees
 order by department_id desc;

# O no omitirla y combinar las funciones en una misma select:

SELECT Department_id,Employee_id, Salary, 
ROW_NUMBER() OVER(partition by department_id ORDER BY salary DESC) ROW_NUMBER,
         RANK() OVER(partition by department_id ORDER BY Salary DESC) RANK,
         DENSE_RANK() OVER(partition by department_id ORDER BY salary DESC) DENSE_RANK
FROM Employees
order by department_id 

























