#!/usr/bin/env python
# -*- coding: utf-8 -*-
import re
import sys

#Recuperer les info dans jfm-data-id7308_3397_744-view1.txt en fonction des donnees du tableur tableur_res.csv
#tableur head:
#
#Id;Label;Type;Année;Auteur;Journal;Pays de l'auteur;Ville de travail de l’auteur au moment de la publication;Pays du journal ou ouvrage ;Série du journal;Volume du journal;Numéro du journal;pp;Page de début;Page de fin;Nombre de pages;Année d’origine;Auteur d‘origine;Ouvrage d'origine;Nom de l’article d’origine;Journal d’origine;Numéro du journal d'origine;Pays de l'auteur d'origine;Pays du journal ou ouvrage d'origine;Ville de publication d’origine;Editeur de l’ouvrage d’origine;Volume du journal d’origine;Numéro du journal d'origine;pp. d'origine;Partie dans le Jahrbuch über die Fortschritte der Mathematik;Chapitre dans le Jahrbuch über die Fortschritte der Mathematik;Section dans le Jahrbuch über die Fortschritte der Mathematik;Numero JFM;Reviewer dans le Jahrbuch über die Fortschritte der Mathematik;Pays du reviewer;Classe dans les Transaction of the AMS;Place dans un chapitre de l'Encyclopédie des sciences mathématiques et appliquées;Classe dans les Bulletin des sciences mathématiques 1870-1884;Classe dans les Revue semestrielle des publications mathématiques 1893-1934;Classe dans le Catalogue of Scientific Papers;Classe dans l' International Catalogue of Scientific Literature 1902-1917;Classe dans la Bibliographie mathématique de Valentin 1885-1910;Remarques

#à remplir : 29:partie, 30:chapitre, 31:section et 32:numero jfm si on trouve 2 dans jfm
samsonTable=open('tableur_res.csv','r')
jfmDb=open('jfm-data-id7308_3397_744-view2.txt','r')
resfile=open('tblres.csv','w')
for line in samsonTable:
	allFiels=line.split(";")
	l=allFiels[1].strip().lower()
	l=re.sub(r'\W','',l)
	chapter=""
	par=""
	JFM=""
	section=""
	for jfmline in jfmDb:
		allJFMFields=jfmline.split("|")
		if len(allJFMFields) > 3:
			test=re.search('(.*)',allJFMFields[1])
			lower=allJFMFields[3].strip().lower()
			lower=re.sub(r'\W','',lower)
			if lower == l:
				JFM=allJFMFields[1]
				#print allJFMFields[1],allJFMFields[2],lower
				part=re.search('(.* Abschnitt.*)\. [CK]apitel.*',allJFMFields[5])
				chap=re.search('.* Abschnitt.*\. ([CK]apitel \d+\. .+)\. [A-Z][\.\)].+',allJFMFields[5])
				sec=re.search('.* Abschnitt.*\. [CK]apitel \d+\. .+\. ([A-Z][\.\)].+)\.',allJFMFields[5])
				if part:
					par=part.group(1)
				else:
					part=re.search('(.* Abschnitt\. .+)\.',allJFMFields[5])
					if par:
						par=part.group(1)
				if sec:
					section=sec.group(1)
				if chap:
					chapter= chap.group(1)
				else:
					chap=re.search('.* Abschnitt.*\. ([CK]apitel \d+\. .+)\.',allJFMFields[5])
					if chap:
						chapter= chap.group(1)
		
				print "all:",allJFMFields[5]
				print "section:",section
				print "par:",par
				print "chapter:",chapter
		
					
	jfmDb.seek(0)
	#print "section:",section
	#print "par:",par
	#print "chapter:",chapter
	for i in range(0,len(allFiels)-1):
		if i == 29:
			resfile.write(par)
		elif i == 30:
			resfile.write(chapter)
		elif i == 31:
			resfile.write(section)
		elif i == 32:
			resfile.write(JFM)
		else:
			resfile.write(allFiels[i])
		resfile.write(";")
	resfile.write("\n")
samsonTable.close()
jfmDb.close()
resfile.close()
