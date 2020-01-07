#!/bin/bash

rm -f "$2/tableau.html" 
echo "Les urls sont dans : $1" ;
echo "Le tableau HTML est dans : $2" ;
echo "Le motif recherché est: $3" ;

motif=$3;
numerotableau=1 

echo "<html><head><meta charset = \"utf-8\" /><title>TABLEAU D'URLs</title></head><body>" >> "$2/tableau.html" ;

for fichier in $(ls $1)
do
compteur=1
echo "$1/$fichier" ;

echo "<table><table border=\"2\" align=\"centre\">" >> "$2/tableau.html" ;
echo "<tr bgcolor=\"purple\"><td>N°</td><td>URL</td><td>Code_http</td><td>Encodage</td><td>Page aspirée</td><td>Dump</td><td>Filtrage Txt</td><td>Filtrage Html</td><td>Index</td><td>Bitexte</td><td>Fq Motif</td></tr>" >> "$2/tableau.html" ;
	
	for ligne in $(cat "$1/$fichier")
	do
	echo "extraction : $ligne" ;
	coderetour=$(curl -SI -o toto -w %{http_code} $ligne);
	echo "Code_ HTTP : $coderetour";
	 
	if [[ $coderetour == 200 ]]
		then 
		encodage=$(curl -sIL -o encode -w %{content_type} $ligne| cut -f2 -d"="|tr '[a-z]' '[A-Z]'|tr -d '\r'); 
		echo " encodage : $encodage"
		curl -L -o "./PAGES-ASPIREES/$numerotableau-$compteur.html" "$ligne" ; 
		
		if [[ $encodage == 'UTF-8' ]]
			then
			#1. lynx page aspirée
			lynx -dump -nolist -assume_charset=$encodage -display_charset=$encodage "./PAGES-ASPIREES/$numerotableau-$compteur.html" > ./DUMP-TEXT/$numerotableau-$compteur.txt; 
			#2. fic context TXT
			egrep -i -C2 "$motif" ./DUMP-TEXT/$numerotableau-$compteur.txt > ./CONTEXTES/$numerotableau-$compteur.txt;
			#3. fq motif
			nbmotif=$(egrep -coi "$motif" ./DUMP-TEXT/$numerotableau-$compteur.txt);
			#4. context html
			perl ./minigrep/minigrepmultilingue.pl "utf-8" ./DUMP-TEXT/$numerotableau-$compteur.txt ./minigrep/motif.txt; 
			mv resultat-extraction.html ./CONTEXTES/$numerotableau-$compteur.html;
			#5. index
			egrep -o '\w+' ./DUMP-TEXT/$numerotableau-$compteur.txt| sort |uniq -c| sort -r > ./DUMP-TEXT/index-$numerotableau-$compteur.txt; 
			# 6. bigramme
			egrep -o "\w+" ./DUMP-TEXT/$numerotableau-$compteur.txt > fic1.txt;
			tail -n +2 fic1.txt > fic2.txt;
			paste fic1.txt fic2.txt >fic3.txt;
			cat fic3.txt | sort | uniq -c| sort -r > ./DUMP-TEXT/bigrams-$numerotableau-$compteur.txt;
			# 7. on écrit les résultats dans le tableau avec tous les résultats produits
			echo "<tr>
			<td>$compteur</td> 
			<td><a href=\"$ligne\" target=\"_blank\">$ligne</a></td>
			<td>Code_retour=$coderetour</td> 
			<td>Encodage=$encodage </td>
			<td><a href=\"../PAGES-ASPIREES/$numerotableau-$compteur.html\">$numerotableau-$compteur.html</a></td>
			<td><a href=\"../DUMP-TEXT/$numerotableau-$compteur.txt\">$numerotableau-$compteur.txt</a></td>
			<td><a href=\"../CONTEXTES/$numerotableau-$compteur.txt\">$numerotableau-$compteur.txt</a></td>
            <td><a href=\"../CONTEXTES/$numerotableau-$compteur.html\">$numerotableau-$compteur.html</a></td>
            <td><a href=\"../DUMP-TEXT/index-$numerotableau-$compteur.txt\">index-$numerotableau-$compteur</a></td>
            <td><a href=\"../DUMP-TEXT/bigrams-$numerotableau-$compteur.txt\">bigrams-$numerotableau-$compteur</a></td>
            <td>$nbmotif</td>
			</tr>" >> "$2/tableau.html";
			
			else 
				retouriconv=$(iconv -l | egrep -o "[-A-Z0-9\_\:]+"| egrep -i  "$encodage");
				if [[ $retouriconv != "" ]]
					then
					echo "Je connais l'encodage!!!"; 
					if [[ $encodage == "CP1251" ]]
						then 
						encodage="WINDOWS-1251";
						fi
						lynx -dump -nolist -assume_charset=$encodage -display_charset=$encodage "./PAGES-ASPIREES/$numerotableau-$compteur.html" > ./DUMP-TEXT/$numerotableau-$compteur.txt; 
						iconv -f $encodage -t utf-8 ./DUMP-TEXT/$numerotableau-$compteur.txt > ./DUMP-TEXT/$numerotableau-$compteur-utf8.txt;
						egrep -i -C2 "$motif" ./DUMP-TEXT/$numerotableau-$compteur-utf8.txt > ./CONTEXTES/$numerotableau-$compteur.txt;
						nbmotif=$(egrep -coi "$motif" ./DUMP-TEXT/$numerotableau-$compteur-utf8.txt);
						perl ./minigrep/minigrepmultilingue.pl "utf-8" ./DUMP-TEXT/$numerotableau-$compteur-utf8.txt ./minigrep/motif.txt; 
						mv resultat-extraction.html ./CONTEXTES/$numerotableau-$compteur.html;
						egrep -o '\w+' ./DUMP-TEXT/$numerotableau-$compteur.txt| sort |uniq -c| sort -r > ./DUMP-TEXT/index-$numerotableau-$compteur.txt;
						egrep -o "\w+" ./DUMP-TEXT/$numerotableau-$compteur.txt > fic1.txt;
						tail -n +2 fic1.txt > fic2.txt;
						paste fic1.txt fic2.txt >fic3.txt;
						cat fic3.txt | sort | uniq -c| sort -r > ./DUMP-TEXT/bigrams-$numerotableau-$compteur.txt;
						echo "<tr><td>$compteur</td><td><a href=\"$ligne\" target=\"_blank\">$ligne</a> <td>Code_retour=$coderetour</td> 
						<td>Encodage=$encodage</td><td><a href=\"../PAGES-ASPIREES/$numerotableau-$compteur.html\">$numerotableau-$compteur.html</a></td>
						<td><a href=\"../DUMP-TEXT/$numerotableau-$compteur-utf8.txt\">$numerotableau-$compteur-utf8.txt</a></td>
						<td><a href=\"../CONTEXTES/$numerotableau-$compteur.txt\">$numerotableau-$compteur.txt</a></td>
						<td><a href=\"../CONTEXTES/$numerotableau-$compteur.html\">$numerotableau-$compteur.html</a></td>
						<td><a href=\"../DUMP-TEXT/index-$numerotableau-$compteur.txt\">index-$numerotableau-$compteur</a></td>
						<td><a href=\"../DUMP-TEXT/bigrams-$numerotableau-$compteur.txt\">bigrams-$numerotableau-$compteur</a></td>
						<td>$nbmotif</td>
						</tr>" >> "$2/tableau.html";
						
					else 
						echo "On recherche l'encodage du texte.";
						reponse_iconv=$(egrep -o "charset.?=.?\"?[^\", ;>]+\"?" ./PAGES-ASPIREES/$numerotableau-$compteur.html |cut -f2 -d"="|tr -d '"'| tr -d " "| tr -d "'"| head -1 |tr 'a-z' 'A-Z');
						echo "$reponse_iconv";
						if [[ $reponse_iconv == "" ]]
							then 
							echo "<tr><td>$compteur</td><td><a href=\"$ligne\" target=\"_blank\">$ligne</a> <td>Code_retour=$coderetour</td> <td>Encodage=$encodage</td><td><a href=\"../PAGES-ASPIREES/$numerotableau-$compteur.html\">$numerotableau-$compteur.html</a></td><td></td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td></tr>" >> "$2/tableau.html";
						elif [[ $reponse_iconv == 'UTF-8' ]]
							then 
							echo "reponse_iconv = utf-8.";
							if [[ $encodage == "CP1251" ]]
								then 
							    encodage="WINDOWS-1251";
							    fi
							lynx -dump -nolist -display_charset=utf-8 "./PAGES-ASPIREES/$numerotableau-$compteur.html" > ./DUMP-TEXT/$numerotableau-$compteur.txt; 
							egrep -i -C2 "$motif" ./DUMP-TEXT/$numerotableau-$compteur.txt > ./CONTEXTES/$numerotableau-$compteur.txt;
							nbmotif=$(egrep -coi "$motif" ./DUMP-TEXT/$numerotableau-$compteur.txt);
							perl ./minigrep/minigrepmultilingue.pl "utf-8" ./DUMP-TEXT/$numerotableau-$compteur.txt ./minigrep/motif.txt; 
							mv resultat-extraction.html ./CONTEXTES/$numerotableau-$compteur.html;
							egrep -o '\w+' ./DUMP-TEXT/$numerotableau-$compteur.txt| sort |uniq -c| sort -r > ./DUMP-TEXT/index-$numerotableau-$compteur.txt; 
							egrep -o "\w+" ./DUMP-TEXT/$numerotableau-$compteur.txt > fic1.txt;
							tail -n +2 fic1.txt > fic2.txt;
							paste fic1.txt fic2.txt >fic3.txt;
							cat fic3.txt | sort | uniq -c| sort -r > ./DUMP-TEXT/bigrams-$numerotableau-$compteur.txt;
							echo "<tr>
							<td>$compteur</td> 
							<td><a href=\"$ligne\" target=\"_blank\">$ligne</a></td>
							<td>Code_retour=$coderetour</td> 
							<td>Encodage=$encodage </td>
							<td><a href=\"../PAGES-ASPIREES/$numerotableau-$compteur.html\">$numerotableau-$compteur.html</a></td>
							<td><a href=\"../DUMP-TEXT/$numerotableau-$compteur.txt\">$numerotableau-$compteur.txt</a></td>
							<td><a href=\"../CONTEXTES/$numerotableau-$compteur.txt\">$numerotableau-$compteur.txt</a></td>
							<td><a href=\"../CONTEXTES/$numerotableau-$compteur.html\">$numerotableau-$compteur.html</a></td>
							<td><a href=\"../DUMP-TEXT/index-$numerotableau-$compteur.txt\">index-$numerotableau-$compteur</a></td>
							<td><a href=\"../DUMP-TEXT/bigrams-$numerotableau-$compteur.txt\">bigrams-$numerotableau-$compteur</a></td>
							<td>$nbmotif</td>
							</tr>" >> "$2/tableau.html";
								
							else
								reponse_iconv2=$(iconv -l | egrep -o "[-A-Z0-9\_\:]+"| egrep -i  "$reponse_iconv"| head -1| tr 'a-z' 'A-Z'); 
								if [[ $reponse_iconv2 == "" ]]
									then 
										echo "<tr><td>$compteur</td><td><a href=\"$ligne\" target=\"_blank\">$ligne</a> <td>Code_retour=$coderetour</td> <td>Encodage=$encodage</td><td><a href=\"../PAGES-ASPIREES/$numerotableau-$compteur.html\">$numerotableau-$compteur.html</a></td><td></td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td></tr>" >> "$2/tableau.html";
								else
									echo "Je connais l'encodage!!!"; 
									if [[ $reponse_iconv == "CP1251" ]]
										then 
										reponse_iconv="WINDOWS-1251";
										fi
									lynx -dump -nolist -assume_charset=$reponse_iconv -display_charset=$reponse_iconv "./PAGES-ASPIREES/$numerotableau-$compteur.html" > ./DUMP-TEXT/$numerotableau-$compteur.txt; 
									iconv -f $reponse_iconv -t utf-8 ./DUMP-TEXT/$numerotableau-$compteur.txt > ./DUMP-TEXT/$numerotableau-$compteur-utf8.txt;
									egrep -i -C2 "$motif" ./DUMP-TEXT/$numerotableau-$compteur-utf8.txt > ./CONTEXTES/$numerotableau-$compteur.txt;
									nbmotif=$(egrep -coi "$motif" ./DUMP-TEXT/$numerotableau-$compteur-utf8.txt);
									perl ./minigrep/minigrepmultilingue.pl "utf-8" ./DUMP-TEXT/$numerotableau-$compteur-utf8.txt ./minigrep/motif.txt; 
									mv resultat-extraction.html ./CONTEXTES/$numerotableau-$compteur.html;
									egrep -o '\w+' ./DUMP-TEXT/$numerotableau-$compteur.txt| sort |uniq -c| sort -r > ./DUMP-TEXT/index-$numerotableau-$compteur.txt;
									egrep -o "\w+" ./DUMP-TEXT/$numerotableau-$compteur.txt > fic1.txt;
									tail -n +2 fic1.txt > fic2.txt;
									paste fic1.txt fic2.txt >fic3.txt;
									cat fic3.txt | sort | uniq -c| sort -r > ./DUMP-TEXT/bigrams-$numerotableau-$compteur.txt;
									echo "<tr><td>$compteur</td><td><a href=\"$ligne\" target=\"_blank\">$ligne</a> <td>Code_retour=$coderetour</td> 
									<td>Encodage=$encodage</td><td><a href=\"../PAGES-ASPIREES/$numerotableau-$compteur.html\">$numerotableau-$compteur.html</a></td>
									<td><a href=\"../DUMP-TEXT/$numerotableau-$compteur-utf8.txt\">$numerotableau-$compteur-utf8.txt</a></td>
									<td><a href=\"../CONTEXTES/$numerotableau-$compteur.txt\">$numerotableau-$compteur.txt</a></td>
									<td><a href=\"../CONTEXTES/$numerotableau-$compteur.html\">$numerotableau-$compteur.html</a></td>
									<td><a href=\"../DUMP-TEXT/index-$numerotableau-$compteur.txt\">index-$numerotableau-$compteur</a></td>
									<td><a href=\"../DUMP-TEXT/bigrams-$numerotableau-$compteur.txt\">bigrams-$numerotableau-$compteur</a></td>
									<td>$nbmotif</td>
									</tr>" >> "$2/tableau.html";
								fi
						fi
				fi
		fi
		
	else
		echo "<tr><td>$compteur</td> <td><a href=\"$ligne\" target=\"_blank\">$ligne</a> <td>Code_retour=$coderetour</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td></tr>" >> "$2/tableau.html"; 
	fi
	
	compteur=$((compteur+1));
	done
	
echo "</table><br />" >> "$2/tableau.html"
numerotableau=$((numerotableau+1)); 

done
echo "</body></html>" >> "$2/tableau.html"
