-- Script 3: consultas SELECT para los pantallazos (punto 7.2). Ejecutar una por una.
SELECT * FROM fabricas;
SELECT * FROM productos;
SELECT * FROM lineas_produccion ORDER BY id_linea;
SELECT * FROM microcontroladores ORDER BY id_microcontrolador LIMIT 25;
SELECT id_sensor, id_microcontrolador, modelo, fecha_calibracion, latitud, longitud, altitud FROM sensores ORDER BY id_sensor LIMIT 25;
SELECT * FROM niveles_ppm ORDER BY id_nivel;
SELECT * FROM tipos_filtros;
SELECT * FROM filtros_instalados ORDER BY id_filtro;
SELECT * FROM turnos;
SELECT * FROM empleados ORDER BY id_empleado;
SELECT * FROM empleado_turno ORDER BY id_turno, id_empleado;
SELECT * FROM configuracion_fabrica;
SELECT * FROM lecturas ORDER BY id_lectura;
-- Conteo de registros por tabla (esperado: 3, 3, 12, 240, 240, 6, 2, 12, 3, 18, 18, 3, 20)
SELECT 'fabricas' AS tabla, COUNT(*) FROM fabricas UNION ALL SELECT 'productos', COUNT(*) FROM productos
UNION ALL SELECT 'lineas_produccion', COUNT(*) FROM lineas_produccion UNION ALL SELECT 'microcontroladores', COUNT(*) FROM microcontroladores
UNION ALL SELECT 'sensores', COUNT(*) FROM sensores UNION ALL SELECT 'niveles_ppm', COUNT(*) FROM niveles_ppm
UNION ALL SELECT 'tipos_filtros', COUNT(*) FROM tipos_filtros UNION ALL SELECT 'filtros_instalados', COUNT(*) FROM filtros_instalados
UNION ALL SELECT 'turnos', COUNT(*) FROM turnos UNION ALL SELECT 'empleados', COUNT(*) FROM empleados
UNION ALL SELECT 'empleado_turno', COUNT(*) FROM empleado_turno UNION ALL SELECT 'configuracion_fabrica', COUNT(*) FROM configuracion_fabrica
UNION ALL SELECT 'lecturas', COUNT(*) FROM lecturas;
-- Lecturas con su clasificación y acción
SELECT l.id_lectura, l.fecha, l.hora, l.id_sensor, l.ppm, n.clasificacion, n.accion
FROM lecturas l JOIN niveles_ppm n ON n.id_nivel = l.id_nivel ORDER BY l.id_lectura;
