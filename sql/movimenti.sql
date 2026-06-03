-- costi
select tipo, prodotto, data_inizio, descrizione, importo, costo, valuta, stato
from movimenti
where costo > 0
  and data_completamento <> '' -- pagameto completato (non annullato)
  and descrizione not like '%interessi %instant access savings%'

-- annullati (non completati)
select *
from movimenti
where data_completamento is null or data_completamento = ''
order by data_inizio

-- interessi
select sum(importo) --tipo, prodotto, data_inizio, descrizione, importo, costo, valuta, stato
from movimenti
where descrizione like '%interessi %instant access savings%'

-- pagamenti
select tipo, prodotto, data_inizio, descrizione, importo, costo, valuta, stato
from movimenti
where descrizione like '%pagamento%'
  and descrizione not like '%da pinelli luca%'
	and stato = 'COMPLETATO'
	and importo > 1000
order by data_inizio

-- pagamenti per anno
select strftime('%Y', data_inizio) "anno", sum(importo) "importo"
from movimenti
where descrizione like '%pagamento%'
  and descrizione not like '%da pinelli luca%'
	and stato = 'COMPLETATO'
	and importo > 1000
group by anno
order by anno

-- pagamenti: grand total
select sum(importo) "importo"
from movimenti
where descrizione like '%pagamento%'
  and descrizione not like '%da pinelli luca%'
	and stato = 'COMPLETATO'
	and importo > 1000

-- spese
select descrizione, sum(importo) "speso"
from movimenti
where prodotto <> 'Risparmi'
  and descrizione not like '%pinelli luca%'
  and descrizione not like '%luca pinelli%'
  and descrizione <> 'To EUR freedom'
  and descrizione <> 'Accredita EUR home da EUR'
  and descrizione <> 'Prelievo da Pocket'
	and stato = 'COMPLETATO'
  and importo < 0
group by descrizione
order by speso

-- spese per anno
select strftime('%Y', data_inizio) "anno", -sum(importo) "speso"
from movimenti
where prodotto <> 'Risparmi'
  and descrizione not like '%pinelli luca%'
  and descrizione not like '%luca pinelli%'
  and descrizione <> 'To EUR freedom'
  and descrizione <> 'Accredita EUR home da EUR'
  and descrizione <> 'Prelievo da Pocket'
	and stato = 'COMPLETATO'
  and importo < 0
group by anno
order by anno

-- spese per mese
select strftime('%Y-%m', data_inizio) "mese", -sum(importo) "speso"
from movimenti
where prodotto <> 'Risparmi'
  and descrizione not like '%pinelli luca%'
  and descrizione not like '%luca pinelli%'
  and descrizione not in (
		'To EUR freedom', 'Accredita EUR home da EUR', 'Prelievo da Pocket', 'Per i depositi senza vincoli'
	)
	and stato = 'COMPLETATO'
  and importo < 0
group by mese
order by mese
