-- Script PostgreSQL
-- Curso de Tópicos Avanzados de base de datos - UPB 202320
-- Luisa María Florez - Samuel Pérez Hurtado

-- Proyecto: Servicios de Domicilios en el Valle de Aburrá
-- Motor de Base de datos: PostgreSQL 15.3 (Trabajado por Luisa María Florez)

-- Crear el esquema de la base de datos
create database domicilios_valle_db;

-- Crear el usuario con el que se realizarán las acciones con privilegios mínimos
create user domicilios_valle_usr with encrypted password 'domicilios';

-- Asignar privilegios al nuevo usuario solo en la base de datos creada
grant create, connect on database domicilios_valle_db to domicilios_valle_usr;
grant create on schema public to domicilios_valle_usr;
grant select, insert, update, delete, trigger on all tables in schema public to domicilios_valle_usr;

-- ***********************
-- Creación de las tablas
-- ***********************

-- Tabla: municipios
create table municipios
(
    id int not null
        constraint municipios_pk primary key,
    municipio varchar(50) not null
);

comment on table municipios is 'Municipios del area metropolitana';
comment on column municipios.id is 'Código del municipio';
comment on column municipios.municipio is 'Nombre del municipio';

-- Tabla: hogares
create table hogares
(
    hogar int not null
        constraint hogares_pk primary key,
    municipio_id int not null
        constraint hogares_municipio_fk references municipios
);

comment on table hogares is 'Hogares del area metropolitana';
comment on column hogares.hogar is 'Código del hogar';
comment on column hogares.municipio_id is 'Código del municipio del hogar';

-- Tabla: medios_transporte
create table medios_transporte
(
    id int not null
        constraint medios_transporte_pk primary key,
    medio_transporte varchar(50) not null
);

comment on table medios_transporte is 'Medios de transporte';
comment on column medios_transporte.id is 'Código del medio de transporte';
comment on column medios_transporte.medio_transporte is 'Nombre del medio de transporte';

-- Tabla: plataformas
create table plataformas
(
    id int not null
        constraint plataformas_pk primary key,
    plataforma_domicilio varchar(50) not null
);

comment on table plataformas is 'Plataformas de domicilios';
comment on column plataformas.id is 'Código de la plataforma de domicilios';
comment on column plataformas.plataforma_domicilio is 'Nombre de la plataforma de domicilios';

-- Tabla: agentes
create table agentes
(
    id int not null
        constraint agentes_pk primary key,
    medio_transporte_id int not null
        constraint agentes_medio_transporte_fk references medios_transporte,
    plataforma_domicilio_id int not null
        constraint agentes_plataforma_domicilio_fk references plataformas
);

comment on table agentes is 'Agentes de domicilios';
comment on column agentes.id is 'Código del agente de domicilios';
comment on column agentes.medio_transporte_id is 'Código del medio de transporte del agente de domicilios';
comment on column agentes.plataforma_domicilio_id is 'Código de la plataforma de domicilios del agente de domicilios';

-- Tabla: tipos_domicilio
create table tipos_domicilio
(
    id int not null
        constraint tipos_domicilio_pk primary key,
    tipo_domicilio varchar(50) not null
);

comment on table tipos_domicilio is 'Tipos de domicilio';
comment on column tipos_domicilio.id is 'Código del tipo de domicilio';
comment on column tipos_domicilio.tipo_domicilio is 'Nombre del tipo de domicilio';

-- Tabla: formas_pago
create table formas_pago
(
    id int not null
        constraint formas_pago_pk primary key,
    forma_pago varchar(50) not null
);

comment on table formas_pago is 'Formas de pago';
comment on column formas_pago.id is 'Código de la forma de pago';
comment on column formas_pago.forma_pago is 'Nombre de la forma de pago';

-- Tabla: servicios
create table servicios
(
    id integer generated always as identity
        constraint servicios_pk primary key,
    hogar_id int not null
        constraint servicios_hogar_fk references hogares,
    agente_id int not null
        constraint servicios_agente_fk references agentes,
    tipo_domicilio_id int not null
        constraint servicios_tipo_domicilio_fk references tipos_domicilio,
    forma_pago_id int not null
        constraint servicios_forma_pago_fk references formas_pago,
    dia int not null,
    hora int not null,
    duracion_minutos int not null,
    valor int not null
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
    id int not null
        constraint remuneraciones_pk primary key
        constraint remuneraciones_servicio_fk references servicios,
    cargo_causado int not null,
    bonificacion_agilidad int not null,
    compensacion_nocturna int not null,
    valor_total int not null,
    fecha_registro timestamp,
    fecha_actualizacion timestamp
);

comment on table remuneraciones is 'Remuneraciones de los agentes de domicilios';
comment on column remuneraciones.id is 'Código de la remuneración del agente de domicilios';
comment on column remuneraciones.cargo_causado is 'Valor del cargo causado';
comment on column remuneraciones.bonificacion_agilidad is 'Valor de la bonificación por agilidad';
comment on column remuneraciones.compensacion_nocturna is 'Valor de la compensación nocturna';
comment on column remuneraciones.valor_total is 'Valor total de la remuneración';
comment on column remuneraciones.fecha_registro is 'Fecha de registro de la remuneración';
comment on column remuneraciones.fecha_actualizacion is 'Fecha de actualización de la remuneración';