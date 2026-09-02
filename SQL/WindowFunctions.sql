# ROW_NUMBER()
# Assigns a unique sequential integer to each row within the partition. 
# If two rows have the same values in the ORDER BY clause, they will receive different row numbers.

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

