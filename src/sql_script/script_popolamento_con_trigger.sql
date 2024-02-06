drop table if exists luogo cascade;
drop table if exists motivazione cascade;
drop table if exists organizzazione cascade;
drop table if exists attacco_coordinato cascade;
drop table if exists gruppo_terroristico cascade;

drop table if exists arma cascade;
drop table if exists terrorista cascade;
drop table if exists alias_gruppo cascade;
drop table if exists target cascade;
drop table if exists attacco_terroristico cascade;

drop table if exists effettuato cascade;
drop table if exists obiettivo cascade;
drop table if exists sequenza cascade;
drop table if exists causato cascade;
drop table if exists strumento cascade;
drop table if exists dati_anagrafici cascade;
drop table if exists indagine_corso cascade;
drop table if exists indagine_conclusa cascade;

drop table if exists partecipazione cascade;
drop table if exists report cascade;

-- FINE CANCELLAZIONE TABELLE PREESISTENTI
--	
--
--
--
--
--
--
--
-- INIZIO DEFINIZIONE TABELLE

create table luogo(
	nazione varchar(30),
	regione varchar(30),
	citta varchar(30),
	constraint PK_luogo primary key (nazione, regione, citta)
);

create table motivazione(
	motivazione varchar(30) primary key
);

create table organizzazione(
	nome varchar(30) primary key,
	sigla varchar(30) not null,
	paese varchar(30) not null
);

create table attacco_coordinato(
	ID_attacco_coordinato integer primary key
);

create table gruppo_terroristico(
	nome varchar(30) primary key,
	sigla varchar(30) null,
	provenienza_principale varchar(30) not null default 'nessun terrorista associato',
	descrizione varchar(500) not null,
	tipologia_gruppo varchar(30) not null
);

create table arma(
	ID_arma integer primary key,
	nome varchar(30) not null,
	descrizione varchar(500) not null,
	tipologia varchar(30) not null,
	
	tipologia_veicolo varchar(30) null,
	sostanza varchar(30) null,
	tipologia_esplosivo varchar(30) null,
	calibro_arma varchar(30) null,
	
	constraint check_tipologia check 
	( 	(tipologia = 'veicolo' and tipologia_veicolo is not null and sostanza is null and tipologia_esplosivo is null and calibro_arma is null)
		or	
		(tipologia = 'arma chimica' and tipologia_veicolo is null and sostanza is not null and tipologia_esplosivo is null and calibro_arma is null)
		or	
		(tipologia = 'bomba' and tipologia_veicolo is null and sostanza is null and tipologia_esplosivo is not null and calibro_arma is null)
		or	
		(tipologia = 'arma da fuoco' and tipologia_veicolo is null and sostanza is null and tipologia_esplosivo is null and calibro_arma is not null)
		or	
		(tipologia not in ('veicolo', 'arma chimica', 'bomba', 'arma da fuoco') and tipologia_veicolo is null and sostanza is null 
		 																		and tipologia_esplosivo is null and calibro_arma is null)
	)
);

create table terrorista(
	ID_terrorista integer primary key,
	provenienza varchar(30) not null,
	gruppo_di_appartenenza varchar(30) null references gruppo_terroristico(nome) on update cascade on delete set null deferrable initially deferred
);

create table alias_gruppo (
   	alias_gruppo varchar(30) primary key,
   	gruppo_terroristico varchar(30) references gruppo_terroristico(nome) on update cascade on delete set null deferrable initially deferred
);

create table target(
    nome varchar(30) primary key,
    descrizione varchar(500) not null,
    tipologia varchar(30) not null,

    nazione varchar(30),
    regione varchar(30),
    citta varchar(30),

    constraint FK_luogo foreign key (nazione, regione, citta) references luogo(nazione, regione, citta) on update restrict on delete restrict
);

create table attacco_terroristico(
	data_ora timestamp,
	latitudine varchar(30),
	longitudine varchar(30),
	
	numero_terroristi integer not null default 0,
	numero_feriti integer not null,
	numero_deceduti integer not null,
	descrizione varchar(500) not null,
	tipologia varchar(30) not null,
	
	ID_attacco_coordinato integer,
	
	nazione varchar(30),
	regione varchar(30),
	citta varchar(30),
	
	constraint PK_attacco_terroristico primary key (data_ora, latitudine, longitudine),
	constraint FK_attacco_coordinato foreign key (ID_attacco_coordinato) references attacco_coordinato(ID_attacco_coordinato) on update cascade on delete set null,
	constraint FK_luogo foreign key (nazione, regione, citta) references luogo(nazione, regione, citta) on update restrict on delete restrict
);

create table effettuato(
	data_ora_attacco timestamp,
	latitudine_attacco varchar(30),
	longitudine_attacco varchar(30),
	terrorista integer,

	constraint PK_effettuato primary key (data_ora_attacco, latitudine_attacco, longitudine_attacco, terrorista),
	constraint FK_attacco_terroristico foreign key (data_ora_attacco, latitudine_attacco, longitudine_attacco) references attacco_terroristico(data_ora, latitudine, longitudine) on update restrict on delete restrict deferrable initially deferred,
	constraint FK_terrorista foreign key (terrorista) references terrorista(ID_terrorista) on update cascade on delete restrict deferrable initially deferred
);

create table obiettivo(
	data_ora timestamp,
	latitudine varchar(30),
	longitudine  varchar(30),
	nome varchar(30),

	constraint PK_obiettivo primary key (data_ora, latitudine, longitudine, nome),
	constraint FK_attacco_terroristico foreign key (data_ora, latitudine, longitudine) references attacco_terroristico(data_ora, latitudine, longitudine) 
																					   on update restrict on delete cascade deferrable initially deferred,
	constraint FK_target foreign key (nome) references target(nome) on update cascade on delete restrict deferrable initially deferred
);

create table sequenza(
	data_ora_attacco_precedente timestamp,
	latitudine_attacco_precedente varchar(30),
	longitudine_attacco_precedente  varchar(30),
	data_ora_attacco_successivo timestamp check (data_ora_attacco_successivo > data_ora_attacco_precedente),
	latitudine_attacco_successivo varchar(30),
	longitudine_attacco_successivo  varchar(30),

	constraint PK_sequenza primary key (data_ora_attacco_precedente, latitudine_attacco_precedente, longitudine_attacco_precedente),
	constraint FK_attacco_precendente foreign key (data_ora_attacco_precedente, latitudine_attacco_precedente, longitudine_attacco_precedente) references attacco_terroristico(data_ora, latitudine, longitudine) on update restrict on delete restrict,
	constraint FK_attacco_successivo foreign key (data_ora_attacco_successivo, latitudine_attacco_successivo, longitudine_attacco_successivo) references attacco_terroristico(data_ora, latitudine, longitudine) on update restrict on delete restrict,
	constraint Unique_attacco_successivo unique (data_ora_attacco_successivo, latitudine_attacco_successivo, longitudine_attacco_successivo)
);

create table causato(
	motivazione varchar(30),
	data_ora timestamp,
	latitudine varchar(30),
	longitudine varchar(30),

	constraint PK_causato primary key (motivazione, data_ora, latitudine, longitudine),
	constraint FK_attacco_terroristico foreign key (data_ora, latitudine, longitudine) references attacco_terroristico(data_ora, latitudine, longitudine) on update restrict on delete restrict deferrable initially deferred,
	constraint FK_motivazione foreign key (motivazione) references motivazione(motivazione) on update restrict on delete restrict
);

create table strumento(
	arma integer,
	data_ora_attacco timestamp,
	latitudine_attacco varchar(30),
	longitudine_attacco  varchar(30),

	constraint PK_strumento primary key (arma, data_ora_attacco, latitudine_attacco, longitudine_attacco),
	constraint FK_attacco_terroristico foreign key (data_ora_attacco, latitudine_attacco, longitudine_attacco) references attacco_terroristico(data_ora, latitudine, longitudine) on update restrict on delete restrict,
	constraint FK_arma foreign key (arma) references arma(ID_arma) on update cascade on delete restrict
);

create table dati_anagrafici(
	terrorista integer primary key,
	nome varchar(30)  null,
	cognome varchar(30)  null,
	data_nascita date null,
	nazione_nascita varchar(30),
	regione_nascita varchar(30),
	citta_nascita varchar(30),

	constraint FK_terrorista foreign key (terrorista) references terrorista(ID_terrorista) on update cascade on delete restrict,
	constraint FK_luogo foreign key (nazione_nascita, regione_nascita, citta_nascita) references luogo(nazione, regione, citta) on update restrict on delete restrict
);

create table indagine_corso(
	ID_indagine varchar(30) primary key,
	data_inizio date check (data_inizio >= date(data_ora_attacco)),
	
	data_ora_attacco timestamp,
	latitudine_attacco varchar(30),
	longitudine_attacco varchar (30),

	constraint Unique_attacco_indagine_corso unique (data_ora_attacco, latitudine_attacco, longitudine_attacco),
	constraint FK_attacco_terroristico foreign key (data_ora_attacco, latitudine_attacco, longitudine_attacco) references attacco_terroristico(data_ora, latitudine, longitudine) on update restrict on delete restrict
);
	
create table indagine_conclusa(
	ID_indagine varchar(30) primary key,
	data_ora_attacco timestamp,
	latitudine_attacco varchar(30),
	longitudine_attacco varchar (30),

	constraint Unique_attacco_indagine_conclusa unique (data_ora_attacco, latitudine_attacco, longitudine_attacco),
	constraint FK_attacco_terroristico foreign key (data_ora_attacco, latitudine_attacco, longitudine_attacco) references attacco_terroristico(data_ora, latitudine, longitudine) on update restrict on delete restrict
);

create table partecipazione(
	organizzazione varchar(30),
	indagine varchar(30),

	constraint PK_partecipazione primary key(organizzazione, indagine),
	constraint FK_organizzazione foreign key (organizzazione) references organizzazione(nome) on update cascade on delete restrict,
	constraint FK_indagine_corso foreign key (indagine) references indagine_corso(ID_indagine) on update restrict on delete cascade deferrable initially deferred
);

create table report(
	indagine varchar(30) primary key,
	data_chiusura date,
	titolo varchar(30),
	descrizione varchar(500),
	allegato varchar(30),
	organizzazione varchar(30),

	constraint FK_organizzazione foreign key (organizzazione) references organizzazione(nome) 
														 	  on update cascade on delete restrict,
	constraint FK_indagine_conclusa foreign key (indagine) references indagine_conclusa(ID_indagine) 
														   on update restrict on delete restrict deferrable initially deferred
);


-- FINE DEFINIZIONE TABELLE
--	
--
--
--
--
--
--
-- INIZIO TRIGGER DI POPOLAMENTO

--
-- Trig 1: La provenienza principale si ottiene contando le occorrenze in APPARTENENZA TERRORISTICA 
--			e prendendo la provenienza che appare più frequentemente.

create or replace function check_provenienza_principale() returns trigger as $$
declare
	max_prov integer;
	prov varchar(30);
begin

	select max(num_app) into max_prov
	from (
		select provenienza, count(*) as num_app
		from (	select provenienza
				from terrorista
				where gruppo_di_appartenenza = new.gruppo_di_appartenenza
			) as tab
		group by provenienza
	) as tab2;

	select provenienza into prov
	from(
		select provenienza, count(*) as num_app
		from terrorista
		where gruppo_di_appartenenza = new.gruppo_di_appartenenza
		group by provenienza
		) as tab
	where num_app = max_prov
	limit 1;

	update gruppo_terroristico
	set provenienza_principale = prov
	where nome = new.gruppo_di_appartenenza;	
return new;
end $$ language plpgsql;

drop trigger if exists check_provenienza_principale on terrorista;

create constraint trigger check_provenienza_principale
after insert or update on terrorista
deferrable initially deferred
for each row 
execute procedure check_provenienza_principale();

--
--
-- FINE TRIGGER 1
--
--

--
-- TRIGGER 2: aggiorna il numero di terroristi per un'attacco
--

create or replace function update_num_terroristi() returns trigger as $$
begin
	update attacco_terroristico
	set numero_terroristi = numero_terroristi + 1
	where data_ora = new.data_ora_attacco and latitudine = new.latitudine_attacco
	and longitudine = new.longitudine_attacco;

	return new;
end
$$ language plpgsql;


drop trigger if exists update_terroristi on effettuato;

create constraint trigger update_terroristi
after insert on effettuato
deferrable initially deferred
for each row 
execute procedure update_num_terroristi();

--
--
-- FINE TRIGGER 2
--
--

--
--
--
--
-- TRIGGER 3: Un attacco deve avere almeno un terrorista
--
--
--
--

create or replace function check_attacco_terrorista() returns trigger as $$
begin
	if(
		not exists (
				select * 
				from effettuato
				where (data_ora_attacco, latitudine_attacco, longitudine_attacco)
					  = (new.data_ora, new.latitudine, new.longitudine)
				)
	  )then
		raise exception 'Non è associato alcun terrorista!';	
	end if;
	return new;
end $$ language plpgsql;

drop trigger if exists check_attacco_terrorista on attacco_terroristico;

create constraint trigger check_attacco_terrorista
after insert or update on attacco_terroristico
deferrable initially deferred
for each row 
execute procedure check_attacco_terrorista();

--
--
-- FINE TRIGGER 3
--
--


--
--
--
--
-- Trigger 4: Un target deve essere presente almeno in un attacco
--
--
--
--
create or replace function checkNomeTarget() returns trigger as $$
	BEGIN
		if (not exists (select * from obiettivo where nome = new.nome)) then
		raise exception 'Target non presente in Obiettivo';
		end if;
	RETURN new;
	END $$ LANGUAGE plpgsql;
	
	
drop trigger if exists checkNomeTarget on target;

CREATE constraint TRIGGER checkNomeTarget 
after INSERT OR UPDATE OF nome ON target
deferrable initially deferred
FOR EACH ROW EXECUTE PROCEDURE checkNomeTarget();

--
--
-- FINE TRIGGER 4
--
--

--
--
--
--
-- Trigger 5: Un attacco deve essere avere almeno un target
--
--
--
--

create or replace function checkNomeObiettivo() returns trigger as $$
	BEGIN
		if (not exists (select * from target where nome = new.nome)) then
		raise exception 'Obiettivo non presente in Target';
		end if;
	RETURN new;
	END $$ LANGUAGE plpgsql;


drop trigger if exists checkNomeObiettivo on obiettivo;

CREATE constraint TRIGGER checkNomeObiettivo
after INSERT OR UPDATE OF nome ON obiettivo
deferrable initially deferred
FOR EACH ROW EXECUTE PROCEDURE checkNomeObiettivo();

--
--
-- FINE TRIGGER 5
--
--

-- FINE TRIGGER DI POPOLAMENTO
--
--
--
--
--
--
--
--  INIZIO TRIGGER VINCOLI AZIENDALI

-- TRIGGER 1 - 2: non può esistere ID_indagine uguale tra in corso e conclusa
create or replace function checkID_indagine() returns trigger as 
$body_function$
begin
	if(exists (select * from indagine_corso
			   where ID_indagine = new.ID_indagine)) then
			   raise exception 'ID_indagine già presente in indagine in corso';
	end if;

	if(exists (select * from indagine_conclusa
			   where ID_indagine = new.ID_indagine)) then
			   raise exception 'ID_indagine già presente in indagine conclusa';
	end if;
	return new;
end $body_function$ language plpgsql;

drop trigger if exists checkID_indagine on indagine_corso;

create trigger checkID_indagine
before insert or update of ID_indagine on indagine_corso
for each row execute procedure checkID_indagine();

drop trigger if exists checkID_indagine on indagine_conclusa;

create trigger checkID_indagine
before insert or update of ID_indagine on indagine_conclusa
for each row execute procedure checkID_indagine();

--
--
--FINE TRIGGER 1 - 2
--
--


-- FINE TRIGGER AZIENDALI
--
--
--
--
--
--
-- INIZIO POPOLAMENTO

--inserimento nella relazione luogo
insert into luogo (nazione, regione, citta)
values	('Italia','Campania','Napoli'),
		('Italia','Piemonte','Torino'),
		('Italia','Lombardia','Milano'),
		('USA','Florida','Miami'),
		('USA','Massachusetts','Boston'),
		('USA','California','Los Angeles'),
		('USA','Louisiana','New Orleans'),
		('USA','New York','New York'),
		('Iraq','Iraq','Baghdad'),
		('Iran','Iran','Tehran');
		
--inserimento nella relazione motivazione		
insert into motivazione (motivazione)
values	('potere'),
		('avidità'),
		('supremazia'),
		('conflitto'),
		('dominazione'),
		('libertà'),
		('terrore'),
		('politica'),
		('religiosa'),
		('razziale');

--inserimento nella relazione organizzazione
insert into organizzazione (nome, sigla, paese)
values	('Central Intelligence Agency','CIA','USA'),
		('Federal Bureau Investigation','FBI','USA'),
		('Organisation de police','Interpol','Francia'),
		('Los angel police dipartement','LAPD','USA'),
		('Military Intelligence 7','MI7','UK');

--inserimento nella relazione attacco_coordinato
insert into attacco_coordinato (ID_attacco_coordinato)
values	(1);

--inserimento nella relazione gruppo_terroristico
insert into gruppo_terroristico (nome, sigla, descrizione, tipologia_gruppo)
values	('abudabi','abu','terroristi politici','politico'),
		('i dieci anelli','10r','terroristi religiosi','religioso'),
		('i falchi','fal','terroristi che attaccano','attaccanti'),
		('i leoni','lio','terroristi con varie ideologie','religioso'),
		('i cervi','cer','attaccano città di varie nazioni','storico');

--inserimento tipologia = veicolo
insert into arma (ID_arma, nome, descrizione, tipologia, tipologia_veicolo)
values	(0,'SUV','Automobile di grossa taglia','veicolo','automobile'),
		(1,'Boeing 747','Aereo di linea','veicolo','velivolo'),
		(2,'Motoscafo','Imbarcazione di media taglia','veicolo','acquatico');

--inserimento tipologia = arma chimica
insert into arma (ID_arma, nome, descrizione, tipologia, sostanza)		
values	(10,'Covid19','Virus di grave impatto','arma chimica','Virulenta'),
		(11,'Gas tossico cloro','È un gas vescicantevie che causa irritazioni e soffocamento.','arma chimica','Cloro'),
		(12,'Gas nervino','Blocca le giunzioni neuromuscolari e le sinapsi nervose','arma chimica','Anticolinesterasici'),
		(13,'Monossido di Carbonio','Ha un effetto soporifero con conseguente perdita di conoscenza','arma chimica','Monossido di Carbonio');

--inserimento tipologia = bomba
insert into arma (ID_arma, nome, descrizione, tipologia, tipologia_esplosivo)
values	(20,'C4','Esplosivo militare','bomba','Esplosivo al plastico'),
		(21,'Granata','Bomba a mano di tipologia militare','bomba','A innesco'),
		(22,'Granata fumogena','Granata antisommossa che genera fumo','bomba','A innesco'),
		(23,'Dinamite','Potente esplosivo per la demolizione di palazzi','bomba','Tritolo'),
		(24,'Missile','Razzo ad elevata potenza distruttiva ed a lungo raggio','bomba','Razzo');
		
--inserimento tipologia = arma da fuoco
insert into arma (ID_arma, nome, descrizione, tipologia, calibro_arma)
values	(30,'AK47','Arma a ripetizione ad uso militare','arma da fuoco','9mm'),
		(31,'M16','Arma a ripetizione ad uso militare','arma da fuoco','5.54mm'),
		(32,'Revolver','Pistola a 6 colpi','arma da fuoco','10.6mm'),
		(33,'Barret M82','Fucile di precisione','arma da fuoco','12.7mm');
		
--inserimento tipologia generica	
insert into arma (ID_arma, nome, descrizione, tipologia)
values	(40,'Mazza da baseball','Mazza ad uso sportivo','Arma bianca'),
		(50,'Katana','Spada per combattimenti a corto raggio','Arma da taglio'),
		(60,'Balestra','Arma usata per uso sportivo','Arma con molla'),
		(70,'Fucile da caccia','Arma usata per la caccia di orsi','Arma da caccia');

--inserimento nella relazione terrorista
insert into terrorista (ID_terrorista, provenienza, gruppo_di_appartenenza)
values 	(1,'Iran','i dieci anelli'),
		(2,'Iran','i dieci anelli'),
		(3,'Afghanistan','i falchi'),
		(4,'Iraq','i dieci anelli'),
		(5,'USA','i dieci anelli'),
		(6,'Italia','i falchi'),
		(7,'UK','abudabi'),
		(8,'Francia',null),
		(9,'Iran','i cervi'),
		(10,'Iran','i dieci anelli'),
		(11,'Afghanistan','i dieci anelli'),
		(12,'USA',null),
		(13,'Afghanistan','i dieci anelli'),
		(14,'Pakistan','i leoni');
		
--inserimento nella relazione alias_gruppo
insert into alias_gruppo (alias_gruppo, gruppo_terroristico)
values 	('Ten rings','i dieci anelli'),
		('Rings','i dieci anelli'),
		('The rings','i dieci anelli'),
		('Lions','i leoni'),
		('ISIS','i cervi'),
		('Abu','abudabi'),
		('Falcons','i falchi'),
		('Adabi','abudabi');


--(NECESSARIA UNA TRANSAZIONE)
begin transaction;

--inserimento nella relazione target
insert into target (nome, descrizione, tipologia, nazione, regione, citta)
values 	('Maschio Angioino','Castello in pieno centro storico','Storico','Italia','Campania','Napoli'),
		('World Trade Center','Complesso di sette edifici','Economico','USA','New York','New York'),
		('Palazzo del governo','Palazzo dove risiede il governatore dello stato Iran','Governativo','Iran','Iran','Tehran'),
		('Pentagono','Dipartimento di difesa americana','Governativo','USA','California','Los Angeles'),
		('Casabianca','Palazzo dove abita il presidente degli stati uniti','Governativo','USA','Florida','Miami');


--inserimento nella relazione attacco_terroristico 
insert into attacco_terroristico (data_ora, latitudine, longitudine, numero_feriti, numero_deceduti, descrizione, tipologia, ID_attacco_coordinato, nazione, regione, citta)
values 	('2021-05-12 14:26:56','40°50′18.24″N','14°15′09.61″E', 14 , 0 ,'Attacco contro la città di Napoli','Storica',null,'Italia','Campania','Napoli'),
		('2001-09-11 09:34:26','40°42′45.87″N','74°00′48.17″W', 6000, 2977,'Attacco alle torri gemelle','Economico',1,'USA','New York','New York'),
		('2001-09-11 10:13:54','38°52′15.74″N','77°03′21.73″W', 50, 12,'Attacco al pentagono','Governativo',1,'USA','California','Los Angeles'),
		('2004-10-03 17:50:31','41°07′46.79″N','14°46′58.98″E', 3, 1,'Attacco al governo Iraniano','Governativo',null,'Iran','Iran','Tehran'),
		('1995-02-27 04:10:24','38°53′51.61″N','77°02′11.58″W', 8, 2,'Attacco alla Casabianca','Governativo',null,'USA','Florida','Miami');

--inserimento nella relazione effettuato
insert into effettuato(data_ora_attacco, latitudine_attacco, longitudine_attacco, terrorista)
values 	('2021-05-12 14:26:56','40°50′18.24″N','14°15′09.61″E', 1),
		('2021-05-12 14:26:56','40°50′18.24″N','14°15′09.61″E', 4),
		('2021-05-12 14:26:56','40°50′18.24″N','14°15′09.61″E', 7),
		('2021-05-12 14:26:56','40°50′18.24″N','14°15′09.61″E', 12),
		('2021-05-12 14:26:56','40°50′18.24″N','14°15′09.61″E', 13),
		('2001-09-11 09:34:26','40°42′45.87″N','74°00′48.17″W', 1),
		('2001-09-11 09:34:26','40°42′45.87″N','74°00′48.17″W', 2),
		('2001-09-11 09:34:26','40°42′45.87″N','74°00′48.17″W', 3),
		('2001-09-11 09:34:26','40°42′45.87″N','74°00′48.17″W', 4),
		('2001-09-11 09:34:26','40°42′45.87″N','74°00′48.17″W', 5),
		('2001-09-11 09:34:26','40°42′45.87″N','74°00′48.17″W', 6),
		('2001-09-11 09:34:26','40°42′45.87″N','74°00′48.17″W', 7),
		('2001-09-11 09:34:26','40°42′45.87″N','74°00′48.17″W', 8),
		('2001-09-11 09:34:26','40°42′45.87″N','74°00′48.17″W', 9),
		('2001-09-11 09:34:26','40°42′45.87″N','74°00′48.17″W', 10),
		('2001-09-11 09:34:26','40°42′45.87″N','74°00′48.17″W', 11),
		('2001-09-11 09:34:26','40°42′45.87″N','74°00′48.17″W', 12),
		('2001-09-11 09:34:26','40°42′45.87″N','74°00′48.17″W', 13),
		('2001-09-11 10:13:54','38°52′15.74″N','77°03′21.73″W', 14),
		('2001-09-11 10:13:54','38°52′15.74″N','77°03′21.73″W', 12),
		('2001-09-11 10:13:54','38°52′15.74″N','77°03′21.73″W', 11),
		('2001-09-11 10:13:54','38°52′15.74″N','77°03′21.73″W', 4),
		('2004-10-03 17:50:31','41°07′46.79″N','14°46′58.98″E', 1),
		('1995-02-27 04:10:24','38°53′51.61″N','77°02′11.58″W', 3),
		('1995-02-27 04:10:24','38°53′51.61″N','77°02′11.58″W', 7),
		('1995-02-27 04:10:24','38°53′51.61″N','77°02′11.58″W', 8);

--inserimento nella relazione obiettivo
insert into obiettivo(data_ora, latitudine, longitudine, nome)
values 	('2021-05-12 14:26:56','40°50′18.24″N','14°15′09.61″E','Maschio Angioino'),
		('2001-09-11 09:34:26','40°42′45.87″N','74°00′48.17″W','World Trade Center'),
		('2001-09-11 10:13:54','38°52′15.74″N','77°03′21.73″W','Palazzo del governo'),
		('2004-10-03 17:50:31','41°07′46.79″N','14°46′58.98″E','Pentagono'),
		('1995-02-27 04:10:24','38°53′51.61″N','77°02′11.58″W','Casabianca');

commit;
--(FINE DELLA TRANSAZIONE)

--inserimento nella relazione sequenza
insert into sequenza(data_ora_attacco_precedente, latitudine_attacco_precedente, longitudine_attacco_precedente, data_ora_attacco_successivo, latitudine_attacco_successivo, longitudine_attacco_successivo)
values	('2001-09-11 09:34:26','40°42′45.87″N','74°00′48.17″W','2001-09-11 10:13:54','38°52′15.74″N','77°03′21.73″W'),
		('2001-09-11 10:13:54','38°52′15.74″N','77°03′21.73″W','2004-10-03 17:50:31','41°07′46.79″N','14°46′58.98″E');

--inserimento nella relazione causato
insert into causato (motivazione, data_ora, latitudine, longitudine)
values 	('terrore','2021-05-12 14:26:56','40°50′18.24″N','14°15′09.61″E'),
		('religiosa','2021-05-12 14:26:56','40°50′18.24″N','14°15′09.61″E'),
		('terrore','2001-09-11 09:34:26','40°42′45.87″N','74°00′48.17″W'),
		('conflitto','2001-09-11 09:34:26','40°42′45.87″N','74°00′48.17″W'),
		('politica','2001-09-11 09:34:26','40°42′45.87″N','74°00′48.17″W'),
		('politica','2001-09-11 10:13:54','38°52′15.74″N','77°03′21.73″W'),
		('potere','2001-09-11 10:13:54','38°52′15.74″N','77°03′21.73″W'),
		('supremazia','2004-10-03 17:50:31','41°07′46.79″N','14°46′58.98″E'),
		('politica','2004-10-03 17:50:31','41°07′46.79″N','14°46′58.98″E'),
		('dominazione','1995-02-27 04:10:24','38°53′51.61″N','77°02′11.58″W');

--inserimento nella relazione strumento
insert into strumento(arma, data_ora_attacco, latitudine_attacco, longitudine_attacco)
values 	(30,'2021-05-12 14:26:56','40°50′18.24″N','14°15′09.61″E'),
		(0,'2021-05-12 14:26:56','40°50′18.24″N','14°15′09.61″E'),
		(1,'2001-09-11 09:34:26','40°42′45.87″N','74°00′48.17″W'),
		(23,'2001-09-11 09:34:26','40°42′45.87″N','74°00′48.17″W'),
		(30,'2001-09-11 09:34:26','40°42′45.87″N','74°00′48.17″W'),
		(33,'2001-09-11 10:13:54','38°52′15.74″N','77°03′21.73″W'),
		(20,'2001-09-11 10:13:54','38°52′15.74″N','77°03′21.73″W'),
		(1,'2004-10-03 17:50:31','41°07′46.79″N','14°46′58.98″E'),
		(23,'2004-10-03 17:50:31','41°07′46.79″N','14°46′58.98″E'),
		(32,'1995-02-27 04:10:24','38°53′51.61″N','77°02′11.58″W');
		

--inserimento nella relazione dati_anagrafici

insert into dati_anagrafici (terrorista, nome, cognome, data_nascita, nazione_nascita, regione_nascita,	citta_nascita)
values 	(1,'Abdul',null,null,null,null,null),
		(2,'Mohammed','Salah','1975-12-10','Iran','Iran','Tehran'),
		(3,'Akir',null,null,null,null,null),
		(4,'Araan','Tehrr','1954-04-23',null,null,null),
		(5,'John','Reese','1987-12-04','USA','California','Los Angeles'),
		(6,'Luigi','Pizza','1999-12-01','Italia','Campania','Napoli'),
		(7,'Arthur','Moore',null,null,null,null),
		(8,'Cesar','Aurich','1999-05-28',null,null,null),
		(12,'Will','Smith',null,null,null,null);

--inserimento nella relazione indagine_corso
insert into indagine_corso (ID_indagine, data_inizio, data_ora_attacco, latitudine_attacco, longitudine_attacco)
values 	('AAA000', '2021-05-13', '2021-05-12 14:26:56','40°50′18.24″N','14°15′09.61″E'),
		('AAA001', '2021-01-10', '2004-10-03 17:50:31','41°07′46.79″N','14°46′58.98″E');

--inserimento nella relazione indagine_conclusa
insert into indagine_conclusa (ID_indagine, data_ora_attacco, latitudine_attacco, longitudine_attacco)
values 	('AAA002', '2001-09-11 09:34:26','40°42′45.87″N','74°00′48.17″W'),
		('AAA003', '2001-09-11 10:13:54','38°52′15.74″N','77°03′21.73″W'),
		('AAA004', '1995-02-27 04:10:24','38°53′51.61″N','77°02′11.58″W');
		
--inserimento nella relazione partecipazione
insert into partecipazione (organizzazione, indagine)
values 	('Central Intelligence Agency','AAA000'),
		('Central Intelligence Agency','AAA001'),
		('Federal Bureau Investigation','AAA001'),
		('Organisation de police','AAA000'),
		('Los angel police dipartement','AAA000'),
		('Los angel police dipartement','AAA001'),
		('Military Intelligence 7','AAA000');


--inserimento nella relazione report
insert into report (indagine, data_chiusura, titolo, descrizione, allegato, organizzazione)
values 	('AAA002','2003-05-13','Report Torri gemelle','Report complessivo contenente tutte le informazioni','report.doc','Central Intelligence Agency'),
		('AAA003','2002-01-12','Report palazzo governativo','Report complessivo contenente tutte le informazioni','Report_governo.pdf','Los angel police dipartement'),
		('AAA004','1999-06-15','Report Casabianca','Report complessivo contentente le informazioni accadute','Report_casabianca.docx','Federal Bureau Investigation');
		
--
--
--
--	FINE POPOLAMENTO
--
--




