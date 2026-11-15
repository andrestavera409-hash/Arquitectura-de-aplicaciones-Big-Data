-- Script 2: poblamiento (INSERTs) de monitoreo-produccion. Ejecutar después de 01_crear_tablas.sql

INSERT INTO fabricas (id_fabrica,nombre,ciudad,latitud,longitud,altitud) VALUES
('A','Fábrica A','Medellín',6.2442,-75.5812,1495),
('B','Fábrica B','Bello',6.3373,-75.5579,1450),
('C','Fábrica C','Itagüí',6.1846,-75.5991,1560);

INSERT INTO productos (id_producto,nombre,descripcion) VALUES
(1,'Solvente aromático SL-1','Producto que emite benceno durante la producción (4 líneas por fábrica)'),
(2,'Resina sintética RS-2','Producto de apoyo, sin emisión relevante de benceno'),
(3,'Pintura base solvente PB-3','Producto de apoyo, sin emisión relevante de benceno');

INSERT INTO lineas_produccion (id_linea,id_fabrica,id_producto,nombre)
SELECT f.id_fabrica||n, f.id_fabrica, 1, 'Línea '||f.id_fabrica||n
FROM fabricas f CROSS JOIN generate_series(1,4) AS n;

INSERT INTO microcontroladores (id_microcontrolador,id_linea,modelo,direccion_ip)
SELECT l.id_linea||'M'||lpad(n::text,2,'0'), l.id_linea, 'ESP8266',
       '192.168.'||(ascii(l.id_fabrica)-64)||'.'||((substr(l.id_linea,2,1)::int-1)*20+n)
FROM lineas_produccion l CROSS JOIN generate_series(1,20) AS n;   -- 240 microcontroladores

INSERT INTO sensores (id_sensor,id_microcontrolador,modelo,fecha_calibracion,latitud,longitud,altitud)
SELECT l.id_linea||'S'||lpad(n::text,2,'0'), l.id_linea||'M'||lpad(n::text,2,'0'), 'MQ-135', DATE '2026-11-01',
       f.latitud + n*0.00001, f.longitud + n*0.00001, f.altitud
FROM lineas_produccion l JOIN fabricas f ON f.id_fabrica=l.id_fabrica CROSS JOIN generate_series(1,20) AS n;   -- 240 sensores

-- Punto PostGIS de cada sensor (requiere la extensión postgis)
UPDATE sensores SET ubicacion = ST_SetSRID(ST_MakePoint(longitud, latitud),4326)::geography;

INSERT INTO niveles_ppm (id_nivel,ppm_min,ppm_max,clasificacion,impacto_salud,accion,color_led) VALUES
(1,0,0.5,'Exposición leve y sin consecuencias','Exposición generalmente segura y sin efectos adversos inmediatos ni a largo plazo (NIOSH).','Operación normal','Verde'),
(2,0.5,1,'Exposición permitida (leve)','Exposición ocupacional a largo plazo permitida por OSHA. Riesgo acumulativo reducido.','Operación normal con observación','Verde'),
(3,1,10,'Moderada toxicidad','Riesgo de anemia y mareos leves. Aumenta el riesgo de cáncer con exposiciones prolongadas.','Revisar el microcontrolador y el filtro','Amarillo'),
(4,10,50,'Peligroso','Mareos, somnolencia, náuseas. Riesgo de daño orgánico y hematológico.','Detener la línea de producción','Naranja'),
(5,50,500,'Altamente peligroso','Desorientación, convulsiones, pérdida de conciencia. Daño severo al sistema nervioso.','Detener la fábrica','Rojo'),
(6,500,NULL,'Peligro extremo (letal)','Colapso inmediato, fallo respiratorio y riesgo de muerte.','Detener la fábrica y llamar a bomberos y defensa civil','Rojo');

INSERT INTO tipos_filtros (id_tipo_filtro,nombre,costo_usd,vida_util_dias) VALUES
(1,'Filtro de carbón activado para benceno (alto costo)',300.00,15),
(2,'Prefiltro de partículas',45.00,30);

INSERT INTO filtros_instalados (id_filtro,id_linea,id_tipo_filtro,fecha_instalacion,fecha_retiro)
SELECT row_number() OVER (ORDER BY id_linea), id_linea, 1, DATE '2026-11-10', NULL FROM lineas_produccion;

INSERT INTO turnos (id_turno,nombre,hora_inicio,hora_fin) VALUES
(1,'Turno 1','08:00','16:00'),
(2,'Turno 2','16:00','00:00'),
(3,'Turno 3','00:00','08:00');

INSERT INTO empleados (id_empleado,nombre,cargo,es_supervisor,id_fabrica) VALUES
(1,'Carlos Gómez','Supervisor de planta',true,'A'),
(2,'Ana Ríos','Supervisor de planta',true,'A'),
(3,'Luis Mejía','Supervisor de planta',true,'A'),
(4,'María Torres','Operario de planta',false,'A'),
(5,'Juan Pérez','Operario de planta',false,'A'),
(6,'Sofía Cano','Operario de planta',false,'A'),
(7,'Pedro Arias','Supervisor de planta',true,'B'),
(8,'Laura Ossa','Supervisor de planta',true,'B'),
(9,'Diego Vélez','Supervisor de planta',true,'B'),
(10,'Camila Ruiz','Operario de planta',false,'B'),
(11,'Andrés Soto','Operario de planta',false,'B'),
(12,'Paula Duque','Operario de planta',false,'B'),
(13,'Felipe Zapata','Supervisor de planta',true,'C'),
(14,'Natalia Gil','Supervisor de planta',true,'C'),
(15,'Mateo Cardona','Supervisor de planta',true,'C'),
(16,'Valentina Henao','Operario de planta',false,'C'),
(17,'Sebastián Marín','Operario de planta',false,'C'),
(18,'Daniela Franco','Operario de planta',false,'C');

INSERT INTO empleado_turno (id_empleado,fecha,id_turno,id_supervisor) VALUES
(4,'2026-11-14',1,1),
(1,'2026-11-14',1,1),
(5,'2026-11-14',2,2),
(2,'2026-11-14',2,2),
(6,'2026-11-14',3,3),
(3,'2026-11-14',3,3),
(10,'2026-11-14',1,7),
(7,'2026-11-14',1,7),
(11,'2026-11-14',2,8),
(8,'2026-11-14',2,8),
(12,'2026-11-14',3,9),
(9,'2026-11-14',3,9),
(16,'2026-11-14',1,13),
(13,'2026-11-14',1,13),
(17,'2026-11-14',2,14),
(14,'2026-11-14',2,14),
(18,'2026-11-14',3,15),
(15,'2026-11-14',3,15);

INSERT INTO configuracion_fabrica (id_fabrica,frecuencia_lectura_seg,umbral_alarma_ppm,dias_cambio_filtro,lineas_produccion,sensores_por_linea)
SELECT id_fabrica,10,1,7,4,20 FROM fabricas;

INSERT INTO lecturas (id_lectura,fecha,hora,id_fabrica,id_linea,id_microcontrolador,id_sensor,ppm,id_nivel,alarma,latitud,longitud,altitud) VALUES
(1,'2026-11-14','08:00:10','A','A1','A1M01','A1S01',0.12,1,false,6.24421,-75.58119,1495),
(2,'2026-11-14','08:00:20','A','A1','A1M01','A1S01',0.18,1,false,6.24421,-75.58119,1495),
(3,'2026-11-14','08:00:30','A','A1','A1M01','A1S01',0.31,1,false,6.24421,-75.58119,1495),
(4,'2026-11-14','08:00:40','A','A1','A1M01','A1S01',0.47,1,false,6.24421,-75.58119,1495),
(5,'2026-11-14','08:00:50','A','A1','A1M01','A1S01',0.55,2,false,6.24421,-75.58119,1495),
(6,'2026-11-14','08:01:00','A','A1','A1M01','A1S01',0.62,2,false,6.24421,-75.58119,1495),
(7,'2026-11-14','08:01:10','A','A2','A2M05','A2S05',0.28,1,false,6.24425,-75.58115,1495),
(8,'2026-11-14','08:01:20','A','A3','A3M12','A3S12',1.4,3,true,6.24432,-75.58108,1495),
(9,'2026-11-14','08:01:30','A','A3','A3M12','A3S12',2.8,3,true,6.24432,-75.58108,1495),
(10,'2026-11-14','08:01:40','A','A4','A4M20','A4S20',0.09,1,false,6.2444,-75.581,1495),
(11,'2026-11-14','08:01:50','B','B1','B1M03','B1S03',0.35,1,false,6.33733,-75.55787,1450),
(12,'2026-11-14','08:02:00','B','B1','B1M03','B1S03',0.9,2,false,6.33733,-75.55787,1450),
(13,'2026-11-14','08:02:10','B','B2','B2M10','B2S10',4.6,3,true,6.3374,-75.5578,1450),
(14,'2026-11-14','08:02:20','B','B3','B3M07','B3S07',12.3,4,true,6.33737,-75.55783,1450),
(15,'2026-11-14','08:02:30','B','B4','B4M18','B4S18',0.21,1,false,6.33748,-75.55772,1450),
(16,'2026-11-14','08:02:40','C','C1','C1M02','C1S02',0.44,1,false,6.18462,-75.59908,1560),
(17,'2026-11-14','08:02:50','C','C2','C2M15','C2S15',7.9,3,true,6.18475,-75.59895,1560),
(18,'2026-11-14','08:03:00','C','C3','C3M09','C3S09',0.58,2,false,6.18469,-75.59901,1560),
(19,'2026-11-14','08:03:10','C','C4','C4M11','C4S11',0.15,1,false,6.18471,-75.59899,1560),
(20,'2026-11-14','08:03:20','C','C4','C4M11','C4S11',0.26,1,false,6.18471,-75.59899,1560);
