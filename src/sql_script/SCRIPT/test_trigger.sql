--
--
--
--
--
--  INIZIO TRIGGER TEST


-- TRIGGER 1 TEST : La provenienza principale si ottiene contando le occorrenze in APPARTENENZA TERRORISTICA 
--					e prendendo la provenienza che appare più frequentemente.
select *
from gruppo_terroristico

select * 
from terrorista

select provenienza, count(*) 
from terrorista
group by provenienza

--FINE TRIGGER 1 TEST


-- TRIGGER 2 TEST : aggiorna il numero di terroristi per un'attacco

select * from attacco_terroristico

insert into effettuato values ('2001-09-11 10:13:54','38°52′15.74″N','77°03′21.73″W',2)

select * from attacco_terroristico 
where data_ora = '2001-09-11 10:13:54' and latitudine = '38°52′15.74″N'
and longitudine = '77°03′21.73″W'

-- FINE TRIGGER 2 TEST



-- TRIGGER 2 TEST: un attacco deve avere almeno un obiettivo

begin transaction;

insert into attacco_terroristico (data_ora, latitudine, longitudine, numero_terroristi, numero_feriti, numero_deceduti, descrizione, tipologia, ID_attacco_coordinato, nazione, regione, citta)
values 	('2021-05-12 14:26:56','40°50′18.23″N','14°15′09.61″E', 1 , 2 , 0 ,'Attacco','Politica',null,'Italia','Campania','Napoli');

insert into effettuato (data_ora_attacco, latitudine_attacco, longitudine_attacco, terrorista)
values  ('2021-05-12 14:26:56','40°50′18.23″N','14°15′09.61″E', 6);

commit;

-- FINE TRIGGER 2 TEST


-- INIZIO TRIGGER VINCOLI
--
-- TEST trigger 1 - 2 - l'ID_indagine non può essere presente sia in indagine_corso che in indagine_conclusa

select *
from indagine_corso

insert into indagine_corso (ID_indagine, data_inizio, data_ora_attacco, latitudine_attacco, longitudine_attacco)
values 	('AAA002', '2018-03-12 12:42:12', '2001-09-11 09:34:26','40°42′45.87″N','74°00′48.17″W');

select *
from indagine_conclusa

insert into indagine_conclusa (ID_indagine, data_ora_attacco, latitudine_attacco, longitudine_attacco)
values 	('AAA001', '2004-10-03 17:50:31','41°07′46.79″N','14°46′58.98″E');
--
--	FINE TRIGGER TEST
--
--