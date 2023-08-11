-- Script Oracle
-- Curso de Tópicos Avanzados de base de datos - UPB 202320
-- Samuel Pérez Hurtado - Luisa María Florez 

-- Proyecto: Servicios de Domicilios en el Valle de Aburrá
-- Motor de Base de datos: Oracle XE 21c (Trabajado por Samuel Pérez Hurtado)

-- Tener presente el contenedor al que está conectado
alter session set container=xepdb1;

-- USER SQL
CREATE USER "DOMICILIOS_VALLE_USR" IDENTIFIED BY "domicilios"  
DEFAULT TABLESPACE "USERS"
TEMPORARY TABLESPACE "TEMP";

-- QUOTAS
ALTER USER "DOMICILIOS_VALLE_USR" QUOTA UNLIMITED ON "USERS";

-- ROLES
GRANT "CONNECT" TO "DOMICILIOS_VALLE_USR" ;
GRANT "RESOURCE" TO "DOMICILIOS_VALLE_USR" ;

-- SYSTEM PRIVILEGES
GRANT CREATE VIEW TO "DOMICILIOS_VALLE_USR" ;
GRANT CREATE SESSION TO "DOMICILIOS_VALLE_USR" ;
GRANT CREATE TABLE TO "DOMICILIOS_VALLE_USR" ;
GRANT CREATE SYNONYM TO "DOMICILIOS_VALLE_USR" ;
GRANT CREATE SEQUENCE TO "DOMICILIOS_VALLE_USR" ;

-- ***********************
-- Creación de las tablas
-- ***********************

-- Se debe establecer el esquema a usar
alter session set current_schema = DOMICILIOS_VALLE_USR

-- Tabla: municipios
create table municipios
(
    id int not null,
    municipio varchar(50) not null,
    constraint municipios_pk primary key (id)
);

comment on table municipios is 'Municipios del area metropolitana';
comment on column municipios.id is 'Código del municipio';
comment on column municipios.municipio is 'Nombre del municipio';

-- Tabla: hogares
create table hogares
(
    hogar number not null,
    municipio_id number not null,
    constraint hogares_pk primary key (hogar),
    constraint hogares_municipio_fk foreign key (municipio_id) references municipios (id)
);

comment on table hogares is 'Hogares del area metropolitana';
comment on column hogares.hogar is 'Código del hogar';
comment on column hogares.municipio_id is 'Código del municipio del hogar';

-- Tabla: medios_transporte
create table medios_transporte
(
    id number not null,
    medio_transporte varchar2(50) not null,
    constraint medios_transporte_pk primary key (id)
);

comment on table medios_transporte is 'Medios de transporte';
comment on column medios_transporte.id is 'Código del medio de transporte';
comment on column medios_transporte.medio_transporte is 'Nombre del medio de transporte';

-- Tabla: plataformas
create table plataformas
(
    id number not null,
    plataforma_domicilio varchar2(50) not null,
    constraint plataformas_pk primary key (id)
);

comment on table plataformas is 'Plataformas de domicilios';
comment on column plataformas.id is 'Código de la plataforma de domicilios';
comment on column plataformas.plataforma_domicilio is 'Nombre de la plataforma de domicilios';

-- Tabla: agentes
create table agentes
(
    id number not null,
    medio_transporte_id number not null,
    plataforma_domicilio_id number not null,
    constraint agentes_pk primary key (id),
    constraint agentes_medio_transporte_fk foreign key (medio_transporte_id) references medios_transporte (id),
    constraint agentes_plataforma_domicilio_fk foreign key (plataforma_domicilio_id) references plataformas (id)
);

comment on table agentes is 'Agentes de domicilios';
comment on column agentes.id is 'Código del agente de domicilios';
comment on column agentes.medio_transporte_id is 'Código del medio de transporte del agente de domicilios';
comment on column agentes.plataforma_domicilio_id is 'Código de la plataforma de domicilios del agente de domicilios';

-- Tabla: tipos_domicilio
create table tipos_domicilio
(
    id number not null,
    tipo_domicilio varchar2(50) not null,
    constraint tipos_domicilio_pk primary key (id)
);

comment on table tipos_domicilio is 'Tipos de domicilio';
comment on column tipos_domicilio.id is 'Código del tipo de domicilio';
comment on column tipos_domicilio.tipo_domicilio is 'Nombre del tipo de domicilio';

-- Tabla: formas_pago
create table formas_pago
(
    id number not null,
    forma_pago varchar2(50) not null,
    constraint formas_pago_pk primary key (id)
);

comment on table formas_pago is 'Formas de pago';
comment on column formas_pago.id is 'Código de la forma de pago';
comment on column formas_pago.forma_pago is 'Nombre de la forma de pago';

-- Tabla: servicios
create table servicios
(
    id number generated always as identity,
    hogar_id number not null,
    agente_id number not null,
    tipo_domicilio_id number not null,
    forma_pago_id number not null,
    dia number not null,
    hora number not null,
    duracion_minutos number not null,
    valor number not null,
    constraint servicios_pk primary key (id),
    constraint servicios_hogar_fk foreign key (hogar_id) references hogares (hogar),
    constraint servicios_agente_fk foreign key (agente_id) references agentes (id),
    constraint servicios_tipo_domicilio_fk foreign key (tipo_domicilio_id) references tipos_domicilio (id),
    constraint servicios_forma_pago_fk foreign key (forma_pago_id) references formas_pago (id)
);

comment on table servicios is 'Servicios de domicilios';
comment on column servicios.id is 'Código del servicio de domicilio';
comment on column servicios.hogar_id is 'Código del hogar que solicita el servicio de domicilio';
comment on column servicios.agente_id is 'Código del agente que realiza el servicio de domicilio';
comment on column servicios.tipo_domicilio_id is 'Código del tipo de domicilio';
comment on column servicios.forma_pago_id is 'Código de la forma de pago';
comment on column servicios.dia is 'Día del mes en que se realiza el servicio de domicilio';
comment on column servicios.hora is 'Hora del día en que se realiza el servicio de domicilio';

-- Tabla: remuneraciones
create table remuneraciones
(
    id number not null,
    servicio_id number not null,
    cargo_causado number not null,
    bonificacion_agilidad number not null,
    compensacion_nocturna number not null,
    valor_total number not null,
    fecha_registro timestamp,
    fecha_actualizacion timestamp,
    constraint remuneraciones_pk primary key (id),
    constraint remuneraciones_servicio_fk foreign key (servicio_id) references servicios (id)
);

comment on table remuneraciones is 'Remuneraciones de los agentes de domicilios';
comment on column remuneraciones.id is 'Código de la remuneración del agente de domicilios';
comment on column remuneraciones.cargo_causado is 'Valor del cargo causado';
comment on column remuneraciones.bonificacion_agilidad is 'Valor de la bonificación por agilidad';
comment on column remuneraciones.compensacion_nocturna is 'Valor de la compensación nocturna';
comment on column remuneraciones.valor_total is 'Valor total de la remuneración';
comment on column remuneraciones.fecha_registro is 'Fecha de registro de la remuneración';
comment on column remuneraciones.fecha_actualizacion is 'Fecha de actualización de la remuneración';