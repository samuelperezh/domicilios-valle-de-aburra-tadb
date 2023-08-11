-- *******************
-- Consultas
-- *******************

-- ¿Cuál es el horario más concurrido de domicilios?
select
    servicios.hora,
    count(*) as cantidad_servicios
from servicios
group by servicios.hora
order by cantidad_servicios desc
limit 1;

-- ¿Cuál es el tipo de domicilio que más hace cada empresa de mensajería?
WITH RankedServices AS ( -- se calcula la cantidad de servicios para cada combinación de plataforma_domicilio
    -- y tipo_domicilio, y se asigna un rango a cada tipo de domicilio dentro de cada plataforma.
    SELECT
        p.plataforma_domicilio,
        td.tipo_domicilio,
        COUNT(*) AS cantidad_servicios,
        RANK() OVER (PARTITION BY p.plataforma_domicilio ORDER BY COUNT(*) DESC) AS rank
    FROM servicios s
    INNER JOIN tipos_domicilio td ON s.tipo_domicilio_id = td.id
    INNER JOIN agentes a ON s.agente_id = a.id
    INNER JOIN plataformas p ON a.plataforma_domicilio_id = p.id
    GROUP BY p.plataforma_domicilio, td.tipo_domicilio
)
SELECT plataforma_domicilio, tipo_domicilio, cantidad_servicios
FROM RankedServices
WHERE rank = 1; --En la consulta principal, seleccionamos los resultados de RankedServices
-- donde el rango es igual a 1. Esto nos dará solo el tipo de domicilio más realizado en cada plataforma de domicilio.

-- ¿Cuál es la cantidad de agentes por medio de transporte y por plataformas?
SELECT
    mt.medio_transporte,
    p.plataforma_domicilio,
    COUNT(a.id) AS cantidad_agentes
FROM agentes a
INNER JOIN medios_transporte mt ON a.medio_transporte_id = mt.id
INNER JOIN plataformas p ON a.plataforma_domicilio_id = p.id
GROUP BY mt.medio_transporte, p.plataforma_domicilio
ORDER BY mt.medio_transporte, p.plataforma_domicilio;

-- ¿Cuántos domicilios del tipo medicamentos por día y por municipio?
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

-- ¿Cuál es el tipo de pago más frecuente por plataforma de domicilios?
SELECT
    p.plataforma_domicilio,
    fp.forma_pago,
    COUNT(*) AS cantidad_servicios
FROM servicios s
INNER JOIN agentes a ON s.agente_id = a.id
INNER JOIN plataformas p ON a.plataforma_domicilio_id = p.id
INNER JOIN formas_pago fp ON s.forma_pago_id = fp.id
GROUP BY p.plataforma_domicilio, fp.forma_pago
ORDER BY p.plataforma_domicilio, cantidad_servicios DESC;