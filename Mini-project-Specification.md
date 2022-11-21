Pišemo biblioteku za "bolji" rad sa google sheets-om. Koristite ovu
[**[biblioteku]{.underline}**](https://github.com/gimite/google-drive-ruby),
kao osnov za svoju. Postoji problem pri autentifikaciji u okviru
biblioteke, koji ćemo rešiti preko uputstva na **[[sledećem
dokumentu]{.underline}](https://docs.google.com/document/d/1RoiBTxJTYJq0_wEMszJmAgW3ZFI3m7Lb/edit?rtpof=true)**
.

Očekujemo da ćemo otvarati google sheet-ove, koji unutar sebe imaju
tabele (bilo gde unutar sheeta). Voditi se predpostavkom da svaka tabela
ima prvi red koji predstavlja header, i opcionalni poslednji red koji
može biti suma. Potrebno je upotrebom osnova ruby programskog jezika i
principa metaprogramiranja ispuniti sledeće zahteve.

Primer:

  -----------------------------------------------------------------------
  Prva Kolona             Druga Kolona            Treća kolona
  ----------------------- ----------------------- -----------------------
                                                  

  1                       25                      3

  4                                               6
  -----------------------------------------------------------------------

1.  **(0.5 Poena)** Biblioteka može da vrati dvodimenzioni niz sa vrednostima tabele
2.  **(0.5 Poena)** Moguće je pristupati redu preko **t.row(1)**, i pristup njegovim elementima po sintaksi niza.
3.  **(0.5 Poena)** Mora biti implementiran **Enumerable** modul(**each** funkcija), gde se vraćaju sve ćelije unutar tabele, sa leva na desno.
4.  **(0.5 Poena)** Biblioteka treba da vodi računa o merge-ovanim poljima
5.  **(1.0 Poena)** \[ \] sintaksa mora da bude obogaćena tako da je moguće pristupati određenim vrednostima.
    a.  Biblioteka vraća celu kolonu kada se napravi upit **t\["PrvaKolona"\]**
    b.  Biblioteka omogućava pristup vrednostima unutar kolone po sledećoj sintaksi 
    **t\["Prva Kolona"\]\[1\]** za pristup drugom elementu te kolone
    c.  Biblioteka omogućava podešavanje vrednosti unutar ćelije po sledećoj sintaksi 
    **t\["Prva Kolona"\]\[1\]= 2556**
6.  **(5.0 Poena)** Biblioteka omogućava direktni pristup kolonama, preko istoimenih metoda.
    a.  **t.prvaKolona, t.drugaKolona, t.trecaKolona**
        i.  Subtotal/Average neke kolone se može sračunati preko sledećih sintaksi **t.prvaKolona.sum** i **t.prvaKolona.avg**
        ii. Iz svake kolone može da se izvuče pojedinačni red na osnovu vrednosti jedne od ćelija. (smatraćemo da ta ćelija jedinstveno identifikuje taj red)
        1.  Primer sintakse: **t.indeks.rn2310**, ovaj kod će vratiti red studenta čiji je indeks rn2310
        iii. Kolona mora da podržava funkcije kao što su [**[map]{.underline}**](https://apidock.com/ruby/Enumerable/map), **[[select]{.underline}](https://apidock.com/ruby/Enumerable/select),                            [[reduce]{.underline}](https://apidock.com/ruby/Enumerable/reduce)**.
        Naprimer: **t.prvaKolona.map { \|cell\| cell+=1 }**
7.  **(0.5 Poena)** Biblioteka prepoznaje ukoliko postoji na bilo koji način ključna reč **total** ili **subtotal** unutar sheet-a, i ignoriše taj red
8.  **(0.5 Poena)** Moguce je sabiranje dve tabele, sve dok su im headeri isti. Npr t1+t2, gde svaka predstavlja, tabelu unutar
    jednog od worksheet-ova. Rezultat će vratiti novu tabelu gde su redovi(bez headera) t2 dodati unutar t1. (SQL UNION operacija)
9.  **(0.5 Poena)** Moguce je oduzimanje dve tabele, sve dok su imheaderi isti. 
10. **(0.5 Poena)** Biblioteka prepoznaje prazne redove, koji mogu biti ubačeni izgleda radi

Uz ispunjenje svih uslova, potrebno je napraviti malu demonstraciju
implementiranih funkcionalnosti. Vaša "main" funkcija bi trebalo da
pokaže ispunjenost svakog od gore navedenih zahteva.

Domaći zadatak nosi **10 poena**, dok se dodatnih bonus **5 poena** mogu
ostvariti na "lepotu" koda, i drugih dodatnih **5 poena** na
"efikasnost" koda.
[**[if-statements]{.underline}**](https://kyan.com/news/how-ruby-if-statements-can-help-you-write-better-code)
**[[Style Guide]{.underline}](https://github.com/airbnb/ruby)
[[Idiomatic
Ruby]{.underline}](https://www.codementor.io/@leandrotk100/idiomatic-ruby-writing-beautiful-code-pwdt8a8kq)
[[lep kod vs lepsi
kod?]{.underline}](https://technology.doximity.com/articles/when-is-ugly-code-beautiful)**

Predaja domaćeg je ponoć dva dana pred odbranu **(Na datum -\>
20/11/2022 23:59 +0100)**, predaja se vrši preko github classsroom-a,
kome pristupate preko sledećeg
[[linka]{.underline}](https://classroom.github.com/a/yphjIGtd)
