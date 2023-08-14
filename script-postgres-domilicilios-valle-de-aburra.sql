-- Script PostgreSQL
-- Curso de Tópicos Avanzados de base de datos - UPB 202320
-- Samuel Pérez Hurtado ID 000459067 - Luisa María Flórez Múnera ID 000449529

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
    servicio_id int not null
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
comment on column remuneraciones.servicio_id is 'Código del servicio de domicilio';
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
    a.id as agente_id,
    p.plataforma_domicilio,
    mt.medio_transporte,
    r.cargo_causado,
    r.bonificacion_agilidad,
    r.compensacion_nocturna,
    r.valor_total,
    r.fecha_registro,
    r.fecha_actualizacion
from remuneraciones r
    inner join servicios s on r.servicio_id = s.id  
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
create or replace function f_calcular_cargo_causado(p_servicio_id int)
returns int as $$
declare
    l_total_registros int :=0;
    l_cargo_causado int :=0;
begin
    select count(valor) into l_total_registros 
    from servicios
    where id = p_servicio_id;

    if(l_total_registros>0) then
        select valor into l_cargo_causado
        from servicios
        where id = p_servicio_id;
    end if;

    return l_cargo_causado * 0.01;
end;
$$ language plpgsql;

-- Ejemplo de uso:
select f_calcular_cargo_causado(1) cargo_causado;

-- Función: Bonificación por agilidad: Cero en caso de no aplicar
-- Si el servicio se realizó en menos de 15 minutos, se le dará una bonificación adicional de $5.000
create or replace function f_calcular_bonificacion_agilidad(p_servicio_id int)
returns int as $$
declare
    l_total_registros int :=0;
    l_bonificacion_agilidad int :=0;
    l_duracion_minutos int :=0;
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
end;
$$ language plpgsql;

-- Ejemplo de uso:
select f_calcular_bonificacion_agilidad(17) bonificacion_agilidad;
select duracion_minutos from servicios where id = 17;

-- Función: Compensación nocturna: Cero en caso de no aplicar
-- Si el servicio se realizó entre las 8:00 p.m. y las 6:00 a.m., se le dará una compensación adicional de $10.000
create or replace function f_calcular_compensacion_nocturna(p_servicio_id int)
returns int as $$
declare
    l_total_registros int :=0;
    l_compensacion_nocturna int :=0;
    l_hora int :=0;
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
        elsif l_hora between 0 and 5 then
            l_compensacion_nocturna := 10000;
        else
            l_compensacion_nocturna := 0;
        end if;
    end if;
    return l_compensacion_nocturna;
end;
$$ language plpgsql;

--Ejemplos de uso:
select f_calcular_compensacion_nocturna(56) compensacion_nocturna;
select hora from servicios where id = 56;

select f_calcular_compensacion_nocturna(12) compensacion_nocturna;
select hora from servicios where id = 12;

select f_calcular_compensacion_nocturna(13) compensacion_nocturna;
select hora from servicios where id = 13;

-- Función: calcular el valor total de la remuneración
create or replace function f_calcular_total_remuneracion(p_servicio_id int)
returns int as $$
declare
    l_total_registros int :=0;
    l_valor int :=0;
    l_cargo_causado int :=0;
    l_bonificacion_agilidad int :=0;
    l_compensacion_nocturna int :=0;
    l_valor_total int :=0;
begin
    select count(valor) into l_total_registros
    from servicios
    where id = p_servicio_id;

    if(l_total_registros>0) then
        select valor into l_valor from servicios where id = p_servicio_id;

        l_cargo_causado := f_calcular_cargo_causado(p_servicio_id);
        l_bonificacion_agilidad := f_calcular_bonificacion_agilidad(p_servicio_id);
        l_compensacion_nocturna := f_calcular_compensacion_nocturna(p_servicio_id);

        l_valor_total := l_cargo_causado + l_bonificacion_agilidad + l_compensacion_nocturna;
    end if;
    return l_valor_total;
end;
$$ language plpgsql;

-- Ejemplo de uso:
select f_calcular_total_remuneracion(1) valor_total;
select valor from servicios where id = 1;
select f_calcular_cargo_causado(1) cargo_causado;
select f_calcular_bonificacion_agilidad(1) bonificacion_agilidad;
select f_calcular_compensacion_nocturna(1) compensacion_nocturna;

-- Función: calcular la fecha de registro
-- La fecha se debe tomar en el mes de Julio, con el día y la hora de la tabla servicios
create or replace function f_calcular_fecha_registro(p_servicio_id int)
returns timestamp as $$
declare
    l_dia int :=0;
    l_hora int :=0;
begin
    select dia into l_dia from servicios where id = p_servicio_id;
    select hora into l_hora from servicios where id = p_servicio_id;

    return '2023-07-' || l_dia || ' ' || l_hora || ':00:00';
end;
$$ language plpgsql;

-- Ejemplo de uso:
select f_calcular_fecha_registro(1) fecha_registro;
select dia from servicios where id = 1;
select hora from servicios where id = 1;

-- ***********************
-- Creación de procedimientos
-- ***********************

-- Procedimiento: actualizar e insertar la remuneración de todos los agentes
create or replace procedure p_actualiza_inserta_remuneracion_agentes()
as $$
declare
    l_total_registros int :=0;
    l_servicio_id int :=0;
    l_cargo_causado int :=0;
    l_bonificacion_agilidad int :=0;
    l_compensacion_nocturna int :=0;
    l_valor_total int :=0;
    l_fecha_registro timestamp;
    l_fecha_actualizacion timestamp;
    c_servicios cursor for select id from servicios;
    r_servicio record;
    r_remuneracion remuneraciones%rowtype;
begin
    set timezone='America/Bogota';

    open c_servicios;
    loop
        fetch c_servicios into r_servicio;
        exit when not found;

        select count(servicio_id) into l_total_registros
        from remuneraciones
        where servicio_id = r_servicio.id;

        l_servicio_id := r_servicio.id;
        l_cargo_causado := f_calcular_cargo_causado(l_servicio_id);
        l_bonificacion_agilidad := f_calcular_bonificacion_agilidad(l_servicio_id);
        l_compensacion_nocturna := f_calcular_compensacion_nocturna(l_servicio_id);
        l_valor_total := f_calcular_total_remuneracion(l_servicio_id);
        l_fecha_registro := f_calcular_fecha_registro(l_servicio_id);
        l_fecha_actualizacion := current_timestamp;

        if (l_total_registros>0) then
            if (r_remuneracion.cargo_causado != l_cargo_causado or
                r_remuneracion.bonificacion_agilidad != l_bonificacion_agilidad or
                r_remuneracion.compensacion_nocturna != l_compensacion_nocturna or
                r_remuneracion.valor_total != l_valor_total or
                r_remuneracion.fecha_registro != l_fecha_registro) then

                update remuneraciones r
                set cargo_causado = l_cargo_causado,
                    bonificacion_agilidad = l_bonificacion_agilidad,
                    compensacion_nocturna = l_compensacion_nocturna,
                    valor_total = l_valor_total,
                    fecha_registro = l_fecha_registro,
                    fecha_actualizacion = l_fecha_actualizacion
                where r.servicio_id = l_servicio_id;
            end if;
        else
            insert into remuneraciones(servicio_id, cargo_causado, bonificacion_agilidad, compensacion_nocturna, valor_total, fecha_registro, fecha_actualizacion)
            values (l_servicio_id, l_cargo_causado, l_bonificacion_agilidad, l_compensacion_nocturna, l_valor_total, l_fecha_registro, l_fecha_actualizacion);
        end if;
    end loop;
end;
$$ language plpgsql;

-- Ejemplo de uso:
do
$$
    begin
        call p_actualiza_inserta_remuneracion_agentes();
    end
$$;

-- Procedimiento: actualizar e insertar la remuneración de un agente
create or replace procedure p_actualiza_inserta_remuneracion_agente(p_servicio_id int)
as $$
declare
    l_total_registros int :=0;
    l_cargo_causado int :=0;
    l_bonificacion_agilidad int :=0;
    l_compensacion_nocturna int :=0;
    l_valor_total int :=0;
    l_fecha_registro timestamp;
    l_fecha_actualizacion timestamp;
    r_remuneracion remuneraciones%rowtype;
begin
    set timezone='America/Bogota';

    select count(servicio_id) into l_total_registros
    from remuneraciones
    where servicio_id = p_servicio_id;

    l_cargo_causado := f_calcular_cargo_causado(p_servicio_id);
    l_bonificacion_agilidad := f_calcular_bonificacion_agilidad(p_servicio_id);
    l_compensacion_nocturna := f_calcular_compensacion_nocturna(p_servicio_id);
    l_valor_total := f_calcular_total_remuneracion(p_servicio_id);
    l_fecha_registro := f_calcular_fecha_registro(p_servicio_id);
    l_fecha_actualizacion := current_timestamp;

    if (l_total_registros>0) then
        if (r_remuneracion.cargo_causado != l_cargo_causado or
            r_remuneracion.bonificacion_agilidad != l_bonificacion_agilidad or
            r_remuneracion.compensacion_nocturna != l_compensacion_nocturna or
            r_remuneracion.valor_total != l_valor_total or
            r_remuneracion.fecha_registro != l_fecha_registro) then

            update remuneraciones r
            set cargo_causado = l_cargo_causado,
                bonificacion_agilidad = l_bonificacion_agilidad,
                compensacion_nocturna = l_compensacion_nocturna,
                valor_total = l_valor_total,
                fecha_registro = l_fecha_registro,
                fecha_actualizacion = l_fecha_actualizacion
            where r.servicio_id = p_servicio_id;
        end if;
    else
        insert into remuneraciones(servicio_id, cargo_causado, bonificacion_agilidad, compensacion_nocturna, valor_total, fecha_registro, fecha_actualizacion)
        values (p_servicio_id, l_cargo_causado, l_bonificacion_agilidad, l_compensacion_nocturna, l_valor_total, l_fecha_registro, l_fecha_actualizacion);
    end if;
end;
$$ language plpgsql;

-- ***********************
-- Trigger
-- ***********************

-- Trigger: añadir la remuneración de un agente cuando se añade o se modifica un servicio
create or replace function ft_actualiza_inserta_remuneracion_agente()
returns trigger as $$
begin
    call p_actualiza_inserta_remuneracion_agente(new.id);
    return null;
end;
$$ language plpgsql;

create trigger tr_insercion_remuneracion
	after insert or update
	on servicios
	for each row
	execute procedure ft_actualiza_inserta_remuneracion_agentes();