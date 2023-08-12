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
alter session set current_schema = DOMICILIOS_VALLE_USR;

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
    id number generated always as identity (start with 1 increment by 1),
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
    cargo_causado number not null,
    bonificacion_agilidad number not null,
    compensacion_nocturna number not null,
    valor_total number not null,
    fecha_registro timestamp,
    fecha_actualizacion timestamp,
    constraint remuneraciones_pk primary key (id),
    constraint remuneraciones_servicio_fk foreign key (id) references servicios (id)
);

comment on table remuneraciones is 'Remuneraciones de los agentes de domicilios';
comment on column remuneraciones.id is 'Código de la remuneración del agente de domicilios';
comment on column remuneraciones.cargo_causado is 'Valor del cargo causado';
comment on column remuneraciones.bonificacion_agilidad is 'Valor de la bonificación por agilidad';
comment on column remuneraciones.compensacion_nocturna is 'Valor de la compensación nocturna';
comment on column remuneraciones.valor_total is 'Valor total de la remuneración';
comment on column remuneraciones.fecha_registro is 'Fecha de registro de la remuneración';
comment on column remuneraciones.fecha_actualizacion is 'Fecha de actualización de la remuneración';

-- ***********************
-- Creación de vistas
-- ***********************

-- Vista: cantidad de servicios por hora
create view v_cantidad_servicios_hora as
select
    servicios.hora,
    count(*) as cantidad_servicios
from servicios
group by servicios.hora
order by cantidad_servicios desc;

-- Vista: remuneraciones de los agentes de domicilios con su plataforma y tipo de transporte
create view v_remuneraciones_agentes as
select 
    a.id,
    p.plataforma_domicilio,
    mt.medio_transporte,
    r.cargo_causado,
    r.bonificacion_agilidad,
    r.compensacion_nocturna,
    r.valor_total,
    r.fecha_registro,
    r.fecha_actualizacion
from remuneraciones r
    inner join servicios s on r.id = s.id  
    inner join agentes a on s.agente_id = a.id
    inner join plataformas p on a.plataforma_domicilio_id = p.id
    inner join medios_transporte mt on a.medio_transporte_id = mt.id;

-- Vista: cantidad de servicios por formas de pago en plataformas de domicilios
create view v_cantidad_servicios_formas_pago_plataformas as
select
    p.plataforma_domicilio,
    fp.forma_pago,
    count(*) as cantidad_servicios
from servicios s
    inner join agentes a on s.agente_id = a.id
    inner join plataformas p on a.plataforma_domicilio_id = p.id
    inner join formas_pago fp on s.forma_pago_id = fp.id
group by p.plataforma_domicilio, fp.forma_pago;

-- Vista: cantidad de servicios por municipio
create view v_cantidad_servicios_municipio as
select
    municipios.municipio,
    count(*) as cantidad_servicios
from servicios
    inner join hogares on servicios.hogar_id = hogares.hogar
    inner join municipios on hogares.municipio_id = municipios.id
group by municipios.municipio;

-- ***********************
-- Creación de funciones
-- ***********************

-- Función: calcular el cargo causado (valor del servicio multiplicado por el 1%)
create or replace function f_calcular_cargo_causado(p_servicio_id in number)
return number as
    l_total_registros number := 0;
    l_cargo_causado number := 0;
begin
    select count(valor) into l_total_registros 
    from servicios
    where id = p_servicio_id;

    if l_total_registros > 0 then
        select valor into l_cargo_causado
        from servicios
        where id = p_servicio_id;
    end if;

    return l_cargo_causado * 0.01;
end f_calcular_cargo_causado;

-- Ejemplo de uso:
select f_calcular_cargo_causado(1) cargo_causado from dual;

-- Función: Bonificación por agilidad: Cero en caso de no aplicar
-- Si el servicio se realizó en menos de 15 minutos, se le dará una bonificación adicional de $5.000
create or replace function f_calcular_bonificacion_agilidad(p_servicio_id in number)
return number as
    l_total_registros number :=0;
    l_bonificacion_agilidad number :=0;
    l_duracion_minutos number :=0;
begin
    select count(duracion_minutos) into l_total_registros
    from servicios
    where id = p_servicio_id;

    if(l_total_registros>0) then
        select duracion_minutos into l_duracion_minutos
        from servicios
        where id = p_servicio_id;

        if l_duracion_minutos < 15 then
            l_bonificacion_agilidad := 5000;
        else
            l_bonificacion_agilidad := 0;
        end if;
    end if;
    return l_bonificacion_agilidad;
end f_calcular_bonificacion_agilidad;

-- Ejemplo de uso:
select f_calcular_bonificacion_agilidad(17) bonificacion_agilidad from dual;
select duracion_minutos from servicios where id = 17;

-- Función: Compensación nocturna: Cero en caso de no aplicar
-- Si el servicio se realizó entre las 8:00 p.m. y las 6:00 a.m., se le dará una compensación adicional de $10.000
create or replace function f_calcular_compensacion_nocturna(p_servicio_id in number)
return number as
    l_total_registros number :=0;
    l_compensacion_nocturna number :=0;
    l_hora number :=0;
begin
    select count(hora) into l_total_registros 
    from servicios
    where id = p_servicio_id;

    if(l_total_registros>0) then
        select hora into l_hora
        from servicios
        where id = p_servicio_id;

        if l_hora between 20 and 23 then
            l_compensacion_nocturna := 10000;
        elsif l_hora between 0 and 6 then
            l_compensacion_nocturna := 10000;
        else
            l_compensacion_nocturna := 0;
        end if;
    end if;
    return l_compensacion_nocturna;
end f_calcular_compensacion_nocturna;

--Ejemplos de uso:
select f_calcular_compensacion_nocturna(56) compensacion_nocturna from dual;
select hora from servicios where id = 56;

select f_calcular_compensacion_nocturna(12) compensacion_nocturna from dual;
select hora from servicios where id = 12;

select f_calcular_compensacion_nocturna(13) compensacion_nocturna from dual;
select hora from servicios where id = 13;

-- Función: calcular el valor total de la remuneración
create or replace function f_calcular_total_remuneracion(p_servicio_id in number)
return number as
    l_total_registros number :=0;
    l_valor number :=0;
    l_cargo_causado number :=0;
    l_bonificacion_agilidad number :=0;
    l_compensacion_nocturna number :=0;
    l_valor_total number :=0;
begin
    select count(valor) into l_total_registros 
    from servicios
    where id = p_servicio_id;

    if(l_total_registros>0) then
        select valor into l_valor from servicios where id = p_servicio_id;

        l_cargo_causado := f_calcular_cargo_causado(p_servicio_id);
        l_bonificacion_agilidad := f_calcular_bonificacion_agilidad(p_servicio_id);
        l_compensacion_nocturna := f_calcular_compensacion_nocturna(p_servicio_id);

        l_valor_total := l_valor +  l_cargo_causado + l_bonificacion_agilidad + l_compensacion_nocturna;
    end if;
    return l_valor_total;
end f_calcular_total_remuneracion;

-- Ejemplo de uso:
select f_calcular_total_remuneracion(1) valor_total from dual;
select valor from servicios where id = 1;
select f_calcular_cargo_causado(1) cargo_causado from dual;
select f_calcular_bonificacion_agilidad(1) bonificacion_agilidad from dual;
select f_calcular_compensacion_nocturna(1) compensacion_nocturna from dual;

-- Función: calcular la fecha de registro
-- La fecha se debe tomar en el mes de Julio, con el día y la hora de la tabla servicios
create or replace function f_calcular_fecha_registro(p_servicio_id in number)
return timestamp as
    l_dia number := 0;
    l_hora number := 0;
    l_fecha_registro timestamp;
begin
    select dia into l_dia from servicios where id = p_servicio_id;
    select hora into l_hora from servicios where id = p_servicio_id;

    l_fecha_registro := to_timestamp('2023-07-' || l_dia || ' ' || l_hora || ':00:00', 'yyyy-mm-dd hh24:mi:ss');

    return l_fecha_registro;
end f_calcular_fecha_registro;

-- Ejemplo de uso:
select f_calcular_fecha_registro(1) fecha_registro from dual;
select dia from servicios where id = 1;
select hora from servicios where id = 1;

-- ***********************
-- Creación de procedimientos
-- ***********************

-- Procedimiento: calcular la remuneración de todos los agentes
create or replace procedure p_calcular_remuneracion_agentes
as
    l_total_registros number := 0;
    l_servicio_id number := 0;
    l_cargo_causado number := 0;
    l_bonificacion_agilidad number := 0;
    l_compensacion_nocturna number := 0;
    l_valor_total number := 0;
    l_fecha_registro timestamp;
    l_fecha_actualizacion timestamp;
begin
    execute immediate 'alter session set time_zone = ''America/Bogota''';

    select count(id) into l_total_registros from servicios;

    FOR ids IN (SELECT id FROM servicios) LOOP
        l_servicio_id := ids.id;
        
        l_cargo_causado := f_calcular_cargo_causado(l_servicio_id);
        l_bonificacion_agilidad := f_calcular_bonificacion_agilidad(l_servicio_id);
        l_compensacion_nocturna := f_calcular_compensacion_nocturna(l_servicio_id);
        l_valor_total := f_calcular_total_remuneracion(l_servicio_id);
        l_fecha_registro := f_calcular_fecha_registro(l_servicio_id);
        l_fecha_actualizacion := CURRENT_TIMESTAMP;

        INSERT INTO remuneraciones(id, cargo_causado, bonificacion_agilidad, compensacion_nocturna, valor_total, fecha_registro, fecha_actualizacion)
        VALUES (l_servicio_id, l_cargo_causado, l_bonificacion_agilidad, l_compensacion_nocturna, l_valor_total, l_fecha_registro, l_fecha_actualizacion);
    END LOOP;
end p_calcular_remuneracion_agentes;

begin
    p_calcular_remuneracion_agentes;
end;