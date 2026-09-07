CREATE TABLE ventas (
    id_venta       NUMBER PRIMARY KEY,
    fecha_venta    DATE,
    vendedor       VARCHAR2(50),
    departamento   VARCHAR2(50),
    importe        NUMBER(10,2)
);

INSERT INTO ventas VALUES (1,  DATE '2026-01-05', 'Ana',    'VENTAS',     1200);
INSERT INTO ventas VALUES (2,  DATE '2026-01-12', 'Ana',    'VENTAS',      850);
INSERT INTO ventas VALUES (3,  DATE '2026-01-25', 'Ana',    'VENTAS',     1500);
INSERT INTO ventas VALUES (4,  DATE '2026-02-03', 'Ana',    'VENTAS',      900);
INSERT INTO ventas VALUES (5,  DATE '2026-02-18', 'Ana',    'VENTAS',     1500);
INSERT INTO ventas VALUES (6,  DATE '2026-03-10', 'Ana',    'VENTAS',     2100);

INSERT INTO ventas VALUES (7,  DATE '2026-01-07', 'Luis',   'VENTAS',     1100);
INSERT INTO ventas VALUES (8,  DATE '2026-01-15', 'Luis',   'VENTAS',      700);
INSERT INTO ventas VALUES (9,  DATE '2026-02-01', 'Luis',   'VENTAS',     1500);
INSERT INTO ventas VALUES (10, DATE '2026-02-20', 'Luis',   'VENTAS',      950);
INSERT INTO ventas VALUES (11, DATE '2026-03-05', 'Luis',   'VENTAS',     1500);
INSERT INTO ventas VALUES (12, DATE '2026-03-25', 'Luis',   'VENTAS',     1800);

INSERT INTO ventas VALUES (13, DATE '2026-01-03', 'Marta',  'MARKETING',   600);
INSERT INTO ventas VALUES (14, DATE '2026-01-20', 'Marta',  'MARKETING',   900);
INSERT INTO ventas VALUES (15, DATE '2026-02-10', 'Marta',  'MARKETING',  1200);
INSERT INTO ventas VALUES (16, DATE '2026-02-25', 'Marta',  'MARKETING',   900);
INSERT INTO ventas VALUES (17, DATE '2026-03-15', 'Marta',  'MARKETING',  1600);

INSERT INTO ventas VALUES (18, DATE '2026-01-08', 'Carlos', 'MARKETING',   750);
INSERT INTO ventas VALUES (19, DATE '2026-01-18', 'Carlos', 'MARKETING',  1100);
INSERT INTO ventas VALUES (20, DATE '2026-02-05', 'Carlos', 'MARKETING',   900);
INSERT INTO ventas VALUES (21, DATE '2026-02-28', 'Carlos', 'MARKETING',  1300);
INSERT INTO ventas VALUES (22, DATE '2026-03-20', 'Carlos', 'MARKETING',  1600);

INSERT INTO ventas VALUES (23, DATE '2026-01-10', 'Pedro',  'IT',         2000);
INSERT INTO ventas VALUES (24, DATE '2026-01-22', 'Pedro',  'IT',          800);
INSERT INTO ventas VALUES (25, DATE '2026-02-15', 'Pedro',  'IT',         2000);
INSERT INTO ventas VALUES (26, DATE '2026-03-01', 'Pedro',  'IT',         2500);
INSERT INTO ventas VALUES (27, DATE '2026-03-28', 'Pedro',  'IT',         1200);

INSERT INTO ventas VALUES (28, DATE '2026-01-14', 'Laura',  'IT',         1000);
INSERT INTO ventas VALUES (29, DATE '2026-01-30', 'Laura',  'IT',         1800);
INSERT INTO ventas VALUES (30, DATE '2026-02-12', 'Laura',  'IT',         2000);
INSERT INTO ventas VALUES (31, DATE '2026-03-05', 'Laura',  'IT',         2500);
INSERT INTO ventas VALUES (32, DATE '2026-03-30', 'Laura',  'IT',          900);

COMMIT;