
--1.

-- Crear el cursor
CREATE OR REPLACE FUNCTION mostrar_numero_empleados (num_dep INTEGER)
RETURNS VOID AS $$
DECLARE
  num_empleados INTEGER;
  cursor_empleados CURSOR FOR
    SELECT COUNT(*) FROM employees WHERE department_id = num_dep;
BEGIN
  -- Verificar si el departamento existe
  IF NOT EXISTS (SELECT 1 FROM departments WHERE department_id = num_dep) THEN
    RAISE EXCEPTION 'El departamento % no existe.', num_dep;
  END IF;

  -- Ejecutar la consulta para obtener el número de empleados
  OPEN cursor_empleados;
  FETCH cursor_empleados INTO num_empleados;
  CLOSE cursor_empleados;

  -- Mostrar el resultado
  RAISE NOTICE 'El número de empleados del departamento % es: %', num_dep, num_empleados;
END;
$$ LANGUAGE plpgsql;

SELECT mostrar_numero_empleados(20);


-- 2.
DO $$
DECLARE
  emp_record RECORD;
BEGIN
  FOR emp_record IN SELECT first_name, last_name FROM employees WHERE first_name = 'ST_CLERK' LOOP
    RAISE NOTICE 'Nombre del empleado: % %', emp_record.first_name, emp_record.last_name;
  END LOOP;
END $$;


-- 3.
CREATE OR REPLACE FUNCTION actualizar_salarios() RETURNS VOID AS $$
DECLARE
  empleado employees%ROWTYPE;
  c_empleados CURSOR FOR SELECT * FROM employees FOR UPDATE;
BEGIN
  -- Abrimos el cursor para recorrer los empleados
  OPEN c_empleados;
  LOOP
    -- Recuperamos el siguiente registro de empleados
    FETCH c_empleados INTO empleado;
    EXIT WHEN NOT FOUND;

    -- Si el salario es mayor de 8000 incrementamos un 2%
    IF empleado.salary > 8000 THEN
      empleado.salary := empleado.salary * 1.02;
    -- Si el salario es menor de 8000 incrementamos un 3%
    ELSIF empleado.salary < 8000 THEN
      empleado.salary := empleado.salary * 1.03;
    END IF;

    -- Actualizamos el registro con el nuevo salario
    UPDATE employees SET salary = empleado.salary WHERE CURRENT OF c_empleados;
  END LOOP;

  -- Comprobamos que los salarios se han actualizado correctamente
  FOR empleado IN SELECT * FROM employees LOOP
    RAISE NOTICE 'Empleado % %, salario: %', empleado.first_name, empleado.last_name, empleado.salary;
  END LOOP;

  -- Cerramos el cursor
  CLOSE c_empleados;
END;
$$ LANGUAGE plpgsql;

SELECT actualizar_salarios();



