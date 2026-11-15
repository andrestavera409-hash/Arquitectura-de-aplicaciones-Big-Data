-- =====================================================================
-- Base de datos: monitoreo-produccion  (Sustancias Locas)  PostgreSQL
-- Script 1: creación de tablas
-- Nota: en pgAdmin primero se crea la base: CREATE DATABASE "monitoreo-produccion";
--       en Supabase se usa la base "postgres" por defecto.
-- =====================================================================
CREATE EXTENSION IF NOT EXISTS postgis;   -- geolocalización (latitud, longitud, altitud)

CREATE TABLE fabricas (
  id_fabrica   char(1)       PRIMARY KEY,
  nombre       varchar(50)   NOT NULL,
  ciudad       varchar(50)   NOT NULL,
  latitud      double precision NOT NULL,
  longitud     double precision NOT NULL,
  altitud      real          NOT NULL
);

CREATE TABLE productos (
  id_producto  smallint      PRIMARY KEY,
  nombre       varchar(60)   NOT NULL,
  descripcion  varchar(200)
);

CREATE TABLE lineas_produccion (
  id_linea     char(2)       PRIMARY KEY,
  id_fabrica   char(1)       NOT NULL REFERENCES fabricas(id_fabrica),
  id_producto  smallint      NOT NULL REFERENCES productos(id_producto),
  nombre       varchar(50)   NOT NULL
);

CREATE TABLE microcontroladores (
  id_microcontrolador char(5) PRIMARY KEY,           -- ej. A1M01
  id_linea     char(2)       NOT NULL REFERENCES lineas_produccion(id_linea),
  modelo       varchar(20)   NOT NULL DEFAULT 'ESP8266',
  direccion_ip varchar(15)
);

CREATE TABLE sensores (
  id_sensor    char(5)       PRIMARY KEY,            -- ej. A1S01
  id_microcontrolador char(5) NOT NULL UNIQUE REFERENCES microcontroladores(id_microcontrolador),
  modelo       varchar(20)   NOT NULL DEFAULT 'MQ-135',
  fecha_calibracion date,
  latitud      double precision NOT NULL,
  longitud     double precision NOT NULL,
  altitud      real          NOT NULL,
  ubicacion    geography(Point,4326)                 -- PostGIS
);

CREATE TABLE niveles_ppm (
  id_nivel     smallint      PRIMARY KEY,
  ppm_min      numeric(8,3)  NOT NULL,               -- límite inferior (exclusivo)
  ppm_max      numeric(8,3),                         -- límite superior (inclusivo); NULL = sin tope
  clasificacion varchar(40)  NOT NULL,
  impacto_salud varchar(200) NOT NULL,
  accion       varchar(120)  NOT NULL,
  color_led    varchar(10)   NOT NULL
);

CREATE TABLE tipos_filtros (
  id_tipo_filtro smallint    PRIMARY KEY,
  nombre       varchar(60)   NOT NULL,
  costo_usd    numeric(8,2)  NOT NULL,
  vida_util_dias smallint    NOT NULL
);

CREATE TABLE filtros_instalados (
  id_filtro    integer       PRIMARY KEY,
  id_linea     char(2)       NOT NULL REFERENCES lineas_produccion(id_linea),
  id_tipo_filtro smallint    NOT NULL REFERENCES tipos_filtros(id_tipo_filtro),
  fecha_instalacion date     NOT NULL,
  fecha_retiro date
);

CREATE TABLE empleados (
  id_empleado  integer       PRIMARY KEY,
  nombre       varchar(80)   NOT NULL,
  cargo        varchar(40)   NOT NULL,
  es_supervisor boolean      NOT NULL DEFAULT false,
  id_fabrica   char(1)       NOT NULL REFERENCES fabricas(id_fabrica)
);

CREATE TABLE turnos (
  id_turno     smallint      PRIMARY KEY,
  nombre       varchar(20)   NOT NULL,
  hora_inicio  time          NOT NULL,
  hora_fin     time          NOT NULL
);

CREATE TABLE empleado_turno (
  id_empleado  integer       NOT NULL REFERENCES empleados(id_empleado),
  fecha        date          NOT NULL,
  id_turno     smallint      NOT NULL REFERENCES turnos(id_turno),
  id_supervisor integer      NOT NULL REFERENCES empleados(id_empleado),
  PRIMARY KEY (id_empleado, fecha, id_turno)
);

CREATE TABLE configuracion_fabrica (
  id_fabrica   char(1)       PRIMARY KEY REFERENCES fabricas(id_fabrica),
  frecuencia_lectura_seg smallint NOT NULL DEFAULT 10,
  umbral_alarma_ppm numeric(8,3) NOT NULL DEFAULT 1,
  dias_cambio_filtro smallint NOT NULL DEFAULT 7,
  lineas_produccion smallint NOT NULL DEFAULT 4,
  sensores_por_linea smallint NOT NULL DEFAULT 20
);

CREATE TABLE lecturas (
  id_lectura   bigint        PRIMARY KEY,
  fecha        date          NOT NULL,
  hora         time          NOT NULL,
  id_fabrica   char(1)       NOT NULL REFERENCES fabricas(id_fabrica),
  id_linea     char(2)       NOT NULL REFERENCES lineas_produccion(id_linea),
  id_microcontrolador char(5) NOT NULL REFERENCES microcontroladores(id_microcontrolador),
  id_sensor    char(5)       NOT NULL REFERENCES sensores(id_sensor),
  ppm          real          NOT NULL,
  id_nivel     smallint      NOT NULL REFERENCES niveles_ppm(id_nivel),
  alarma       boolean       NOT NULL,
  latitud      double precision NOT NULL,
  longitud     double precision NOT NULL,
  altitud      real          NOT NULL
);
CREATE INDEX idx_lecturas_fecha_hora ON lecturas (fecha, hora);
CREATE INDEX idx_lecturas_sensor     ON lecturas (id_sensor, fecha);
