## FLP 2. projekt
**Jméno**: Veronika Nevařilová \
**Login**: xnevar00 \
**Akademický rok**: 2024/25 \
**Název zadání**: Babylonská věž

## Metoda řešení

### 1. Vnitřní reprezentace věže
Věž je načtena ze standardního vstupu ve tvaru:

```
A1 B1 C1 D1 E1
A2 B2 C2 D2 E2
B3 C3 D3 E3 E4
A3 B4 C4 D4 **
```

Pro zpracování vstupu bylo využito poskytnutých základních funkcí souboru `input2.pl`, které byly přesunuty do souboru `stdin_stdout_utils.pl` pro větší přehlednost.

Po načtení věže je věž reprezentována v programu následovně:

```
[
    [['A','1'], ['B','1'], ['C','1'], ['D','1'], ['E','1']],
    [['A','2'], ['B','2'], ['C','2'], ['D','2'], ['E','2']],
    [['B','3'], ['C','3'], ['D','3'], ['E','3'], ['E','4']],
    [['A','3'], ['B','4'], ['C','4'], ['D','4'], ['*','*']]
]
```

Jedná se tedy o trojrozměrné pole s dimenzemi `řádky`,`elementy`, `obsah elementů`. Každý element je reprezentován dvěmi hodnotami, písmenem a číslem, s výjimkou prázdné buňky, která obsahuje dvě hvězdičky. Pro správné fungování programu je vyžadováno použít velká písmena, viz následující sekce.

### 2. Tahy s věží a kontrola konečného řešení

Tahů je v každém kroku konečný počet, přičemž záleží na velikosti věže:

- **Rotace řádku o 1 krok doprava** (počet možností = počet řádků věže)
- **Rotace řádku o 1 krok doleva** (počet možností = počet řádků věže)
- **Posunutí prázdného místa o jeden krok nahoru** (pokud se nenachází v prvním řádku)
- **Posunutí prázdného místa o jeden krok dolů** (pokud se nenachází v posledním řádku)

Rotace řádků jsou implementovány pomocí operací se seznamem reprezentující konkrétní řádek.

Pro posunutí prázdného místa je potřeba nalézt souřadnice prázdného místa (predikát `find_empty_cell` v souboru `tower.pl`) a následně jej vyměnit s prvkem ve sloupci nad/pod ním pomocí dalších pomocných predikátů.

**Kontrola konečného řešení** je prováděna ve dvou částech, přičemž u správně složené věže musí být obě podmínky splněny:

1.  V jednotlivých řádcích se nachází elementy s číslem, které odpovídá číslu řádku číslovaného od hodnoty 1.
2. V jednotlivých sloupcích se nachází elementy s písmenem, které odpovídá písmenu v abecedě na pozici čísla sloupce (1. sloupec obsahuje `'A'`, 26. sloupec by obsahoval `'Z'`).

Kontrola podmínky řádků je poměrně jednoduchá, pouze u posledního řádku je vyžadováno, aby na první pozici řádku byl element `['*', '*']`.

Pro kontrolu podmínky sloupců je potřeba navíc předzpracování spočívající v extrakci elementů z daného sloupce do jednoho seznamu elementů. Následná kontrola pak kontroluje přítomnost písmena s ASCII hodnotou `65 + column_index`, jelikož číslo 65 reprezentuje znak `'A'`.

### 3. Hledání řešení

Pro prohledávání stavového prostoru babylonské věže jsem zprvu zvolila algoritmus Breadth-First Search (BFS). Toto řešení fungovalo, avšak bylo příliš pomalé a pro větší vstupy s delším počtem kroků nutných k řešení už bylo nedostačující. Proto jsem následně změnila tento algoritmus na Iterative Deepening Search (IDS). Nalezená řešení jsou tedy optimální.

Hledání začíná na maximální hloubce 1, přičemž se v případě nenalezení řešení zvyšuje. IDS predikát tedy volá pro řešení opakovaně DLS (Depth Limited Search).

V každém stavu jsou pomocí predikátu `find_neighbors` nalezeni sousedé aktuálního stavu (stavy, do kterých je možné se dostat jedním tahem z aktuálního stavu), a ti jsou následně také vyhodnoceni.

Pro eliminaci zacyklení je implementována kontrola, zda stav už není v předchozí cestě aktuálního stavu.

V přiložené variantě BFS (popsána v sekci `ROZŠÍŘENÍ`) je využita množina `visited_bfs` implementována jako dynamický predikát, která si udržuje informace o již navštívených stavech. Takové stavy nejsou opakovaně prozkoumávány. U varianty BFS je možné tento globální dynamický predikát použít, ale u IDS nikoliv, protože každá cesta musí mít svůj seznam `visited`. Bez toho by byla porušena optimálnost, protože např. při max. hloubce 5 může cesta X dojít k danému stavu pomocí 4 tahů a označí stav jako navštívený. Cesta Y pak může dojít ve stejné iteraci ke stejnému stavu pomocí 2 tahů, ale dále ho prozkoumávat nebude, protože stav už je označen jako navštívený. Tato cesta ale mohla vést k optimálnímu řešení. U IDS je tato kontrola proto redukována pouze na předchozí stavy aktuálního stavu.

Každý prozkoumávaný stav si s sebou nese také předchozí stavy, přes které se k atuálnímu stavu dostal z původního stavu. Při zpracování každého takového stavu je kontrolováno, zda daný stav není již cílový. Pokud ano, výpočet končí a cesta k řešení je tisknuta na standardní výstup.

### 4. Tisk výsledného řešení

Výsledné řešení je na standardní výstup tisknuto v pořadí od původního stavu k cílovému stavu. Jdou v něm tedy sledovat tahy, které program dělal při hledání daného řešení.

Příklad výstupu:

```
E1 A1 B1 C1 D1
A2 B2 C2 D2 E2
B3 C3 D3 E3 **
A3 B4 C4 D4 E4

A1 B1 C1 D1 E1
A2 B2 C2 D2 E2
B3 C3 D3 E3 **
A3 B4 C4 D4 E4

A1 B1 C1 D1 E1
A2 B2 C2 D2 E2
** B3 C3 D3 E3
A3 B4 C4 D4 E4

A1 B1 C1 D1 E1
A2 B2 C2 D2 E2
A3 B3 C3 D3 E3
** B4 C4 D4 E4
```


## Návod k použití

Pro překlad je k dispozici `Makefile`. Výstupem překladu je program `flp24-log` v kořenovém adresáři. Překlad a spuštění je možné provést tedy takto:

```
 make
 ./flp24-log < tower.txt
```

kde `tower.txt` je soubor obsahující počáteční stav věže ve tvaru ukázaném výše.

Pro vyzkoušení funkčnosti algoritmu je možné spustit skript s jakýmkoli souborem ze složky `examples`, např. následovně:

```
./flp24-log <./examples/small_3.txt
```

Soubory ve složce examples jsou rozděleny do několika skupin:

- `small` - obsahuje věže o rozměrech 4x5 (řádky x sloupce)
- `medium` - obsahuje věže o rozměrech 7x10
- `large` - obsahuje věže o rozměrech 9x26 (maximální velikost)

Číslo za označením velikosti pak indikuje **minimální počet tahů** potřebných k vyřešení dané věže.

Doba řešení byla měřena na serveru Merlin:

| Velikost | 3 tahy | 6 tahů |
|----------|--------|--------|
| small    | 0.031 s | 0.608 s |
| medium   | 0.048 s | 31.392 s |
| large    | 0.243 s | > 10 min |

Pro srovnání byla na velikosti `small` vyhodnocena i verze BFS, kterou jsem implementovala první. Její časy byly následující:

| Velikost | 3 tahy | 6 tahů |
|----------|--------|--------|
| small    | 0.162 s | 14.518 s |

Lze vidět, že verze IDS je výrazně rychlejší než verze BFS.

Verze BFS je také přiložena a lze spustit, viz následující sekce.


## ROZŠÍŘENÍ

Jelikož jsem zezačátku implementovala i verzi s využitím Breadth-First Search algoritmu, přiložila jsem ji pro srovnání časů řešení také. Je možné si ji zapnout odkomentováním `solve_bfs` a zakomentováním `solve` v `main.pl`:

```prolog
start() :-
    prompt(_, ''),
    read_lines(LL),
    split_lines(LL, S),
    solve(S),          % COMMENT FOR BFS VERSION
    %solve_bfs(S),     % UNCOMMENT FOR BFS VERSION
    halt.
```
