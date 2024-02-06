--  INIZIO QUERY

-- QUERY AGGREGAZIONE E JOIN

--Il numero dei target colpiti da ogni terrorista con la somma delle uccisioni da esso effettuati

select ef.terrorista, count(ob.nome), sum(att.numero_deceduti)
from effettuato as ef join attacco_terroristico as att
	on (ef.data_ora_attacco, ef.latitudine_attacco, ef.longitudine_attacco) 
	= (att.data_ora, att.latitudine, att.longitudine)
	join obiettivo as ob
	on (att.data_ora, att.latitudine, att.longitudine) 
	= (ob.data_ora, ob.latitudine, ob.longitudine)
group by ef.terrorista
order by ef.terrorista


--QUERY NIDIFICATA COMPLESSA

--dato un attacco, conoscere se fa parte di un attacco coordinato e visualizzare tutti i target colpiti dagli attacchi coordinati

select nome
from obiettivo
where (data_ora, latitudine, longitudine) 
in(
	select data_ora, latitudine, longitudine
	from attacco_terroristico
	where ID_attacco_coordinato 
	in(
		select ID_attacco_coordinato
		from attacco_terroristico
		where 	data_ora = '2001-09-11 09:34:26' and latitudine ='40°42′45.87″N' 
				and longitudine = '74°00′48.17″W' and ID_attacco_coordinato is not null
	)
)

--QUERY INSIEMISTICA

--trovare il nome e la sigla delle organizzazioni che indagano su attacchi iraniani e su attacchi italiani

select org.nome as organizzazione, org.sigla as sigla
from organizzazione as org, partecipazione as part, indagine_corso as in_c, attacco_terroristico as att
where (org.nome = part.organizzazione and part.indagine = in_c.ID_indagine and in_c.data_ora_attacco = att.data_ora
   and in_c.latitudine_attacco = att.latitudine and in_c.longitudine_attacco = att.longitudine and att.nazione = 'Italia')
   
intersect

select org.nome as organizzazione, org.sigla as sigla
from organizzazione as org, partecipazione as part, indagine_corso as in_c, attacco_terroristico as att
where (org.nome = part.organizzazione and part.indagine = in_c.ID_indagine and in_c.data_ora_attacco = att.data_ora
   and in_c.latitudine_attacco = att.latitudine and in_c.longitudine_attacco = att.longitudine and att.nazione = 'Iran')


--QUERY CON VISTA

-- La tipologia di arma più utilizzata negli attacchi (vista)

create view num_attacchi_per_arma as
	select gun.tipologia, count(*) as n_att
    from arma as gun join strumento as str
    on (gun.ID_arma = str.arma)
    group by gun.tipologia	

select *
from num_attacchi_per_arma  as n_att   
where n_att.n_att = (
					select max(n_att)
					from num_attacchi_per_arma
				    )

--ALTRE QUERY

-- trovare tutti i paesi tranne l'Iran che hanno almeno un target, almeno un attacco e almeno un'organizzazione

select distinct paese
from organizzazione as org, target as trg, attacco_terroristico as att, luogo as lg
where org.paese = trg.nazione and trg.nazione = att.nazione and lg.nazione <> 'Iran'


-- visualizzare tutte le organizzazioni che hanno il paese in comune con i target

select *
from organizzazione
where paese = any (select nazione
				from target)


select *
from organizzazione
where paese = (select paese 
				from organizzazione

				intersect

				select nazione
				from target)

--FINE QUERY






--TEST QUERY (query di test e in parte anche scorrette)

--i target che non sono italiani

select nome
from target as trg, luogo as lg
where trg.nazione = lg.nazione and trg.regione = lg.regione and trg.citta = lg.citta

except

select nome
from target as trg, luogo as lg
where trg.nazione = lg.nazione and trg.regione = lg.regione and trg.citta = lg.citta and trg.nazione = 'Italia'

--semplificata
select nome
from target as trg, luogo as lg
where trg.nazione = lg.nazione and trg.regione = lg.regione and trg.citta = lg.citta and trg.nazione <> 'Italia'

--
--estrapolare tutti gli attacchi in cui non sono coinvonti terroristi iraniani

select *
from attacco_terroristico as att join effettuato as eff
on (att.data_ora,att.latitudine,att.longitudine) = (eff.data_ora_attacco,eff.latitudine_attacco, eff.longitudine_attacco)
where eff.terrorista in (
						 select ID_terrorista
						 from terrorista
						 where provenienza <> 'Iran'
						)


--QUERY INSIEMISTICA

-- visualizzare tutte le organizzazioni che hanno il paese in comune con i target

select distinct nome
from organizzazione as org, luogo as lg
where org.paese = lg.nazione

--
--Trovare i terroristi iraniani ed iracheni

select ID_terrorista
from terrorista
where provenienza = 'Iran'

union

select ID_terrorista
from terrorista
where provenienza = 'Iraq'

--semplificata

select ID_terrorista
from terrorista
where provenienza = 'Iraq' or provenienza = 'Iran'

--
-- trovare tutti i paesi tranne l'Iran che hanno almeno un target, almeno un attacco e almeno un'organizzazione

(select nazione
from target

intersect

select nazione
from attacco_terroristico

intersect

select paese
from organizzazione)

except

select nazione
from luogo
where nazione = 'Iran'

--semplificata
select distinct paese
from organizzazione as org, target as trg, attacco_terroristico as att, luogo as lg
where org.paese = trg.nazione and trg.nazione = att.nazione and lg.nazione <> 'Iran'


--
--dato un attacco, conoscere se fa parte di una sequenza

select data_ora, latitudine, longitudine
from attacco_terroristico
where data_ora = '2001-09-11 09:34:26' and latitudine ='40°42′45.87″N' and longitudine = '74°00′48.17″W'

intersect

(select data_ora_attacco_precedente as data_ora, latitudine_attacco_precedente as latitudine, longitudine_attacco_precedente as longitudine
from sequenza

union

select data_ora_attacco_successivo as data_ora, latitudine_attacco_successivo as latitudine, longitudine_attacco_successivo as longitudine
from sequenza)

--	FINE QUERY TEST