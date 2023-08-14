-- Script Consultas de ambos motores de bases de datos
-- Curso de Tópicos Avanzados de base de datos - UPB 202320
-- Samuel Pérez Hurtado ID 000459067 - Luisa María Flórez Múnera ID 000449529


-- 1. ¿Cuál es el horario más concurrido de domicilios?
select
    servicios.hora,
    count(*) as cantidad_servicios
from servicios
group by servicios.hora
order by cantidad_servicios desc
fetch first 1 row only;

-- 2. ¿Cuál es el tipo de domicilio que más hace cada empresa de mensajería?
-- Para realizar esta consulta SQL se requirió ayuda de ChatGPT.
with cte as (
    select
        p.plataforma_domicilio,
        td.tipo_domicilio,
        count(*) as cantidad_servicios,
        row_number() over (partition by p.plataforma_domicilio order by count(*) desc) as rango
    from servicios s
        inner join agentes a on s.agente_id = a.id
        inner join plataformas p on a.plataforma_domicilio_id = p.id
        inner join tipos_domicilio td on s.tipo_domicilio_id = td.id
    group by p.plataforma_domicilio, td.tipo_domicilio
)
select
    plataforma_domicilio,
    tipo_domicilio,
    cantidad_servicios
from cte
where rango = 1
order by plataforma_domicilio;

-- 3. ¿Cuál es la cantidad de agentes por medio de transporte y por plataformas?
select
    mt.medio_transporte,
    p.plataforma_domicilio,
    count(a.id) as cantidad_agentes
from agentes a
inner join medios_transporte mt on a.medio_transporte_id = mt.id
inner join plataformas p on a.plataforma_domicilio_id = p.id
group by mt.medio_transporte, p.plataforma_domicilio
order by mt.medio_transporte, p.plataforma_domicilio;

-- 4. ¿Cuántos domicilios del tipo medicamentos por día y por municipio?
select
    municipios.municipio,
    servicios.dia,
    count(*) as cantidad_servicios
from servicios
    inner join tipos_domicilio on servicios.tipo_domicilio_id = tipos_domicilio.id
    inner join hogares on servicios.hogar_id = hogares.hogar
    inner join municipios on hogares.municipio_id = municipios.id
where tipos_domicilio.tipo_domicilio = 'Medicamentos'
group by municipios.municipio, servicios.dia;

-- 5. ¿Cuál es el tipo de pago más frecuente por plataforma de domicilios?
with cte as (
    select
        p.plataforma_domicilio,
        fd.forma_pago,
        count(*) as cantidad_servicios,
        row_number() over (partition by p.plataforma_domicilio order by count(*) desc) as rango
    from servicios s
        inner join agentes a on s.agente_id = a.id
        inner join plataformas p on a.plataforma_domicilio_id = p.id
        inner join formas_pago fd on s.forma_pago_id = fd.id
    group by p.plataforma_domicilio, fd.forma_pago
)
select
    plataforma_domicilio,
    forma_pago,
    cantidad_servicios
from cte
where rango = 1
order by plataforma_domicilio;

-- ************************************************
-- Consultas después de ejecutar los procedimientos
-- ************************************************

-- 1. ¿Cuál(es) agente(s) tuvo/tuvieron la mayor remuneración en el mes y de cuánto fue?
select
    a.id,
    sum(r.valor_total) as remuneracion_total
from remuneraciones r
    inner join servicios s on r.servicio_id = s.id  
    inner join agentes a on s.agente_id = a.id
group by a.id
order by remuneracion_total desc
fetch first 1 row only;

-- 2. ¿Cuál(es) compañía(s)/plataforma(s) pagaron la mayor compensación nocturna en el mes y de cuánto fue?
select
    p.plataforma_domicilio,
    sum(r.compensacion_nocturna) as compensacion_nocturna_total
from remuneraciones r
    inner join servicios s on r.servicio_id = s.id
    inner join agentes a on s.agente_id = a.id
    inner join plataformas p on a.plataforma_domicilio_id = p.id
group by p.plataforma_domicilio
order by compensacion_nocturna_total desc
fetch first 1 row only;