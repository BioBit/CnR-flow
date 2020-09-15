#!/usr/bin/env bash
#Daniel Stribling
#Renne Lab, University of Florida
#
#This file is part of CnR-flow.
#CnR-flow is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#CnR-flow is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#You should have received a copy of the GNU General Public License
#along with CnR-flow.  If not, see <https://www.gnu.org/licenses/>.

# Source: https://github.com/BenLangmead/bowtie-majref
gunzip test_reference.tar.gz
tar -xvf test_reference.tar
cd test_reference
curl -o grch38_1kgmaj.fa.gz   ftp://ftp.ccb.jhu.edu/pub/data/bowtie_indexes/grch38_1kgmaj.fa.gz
gunzip grch38_1kgmaj.fa.gz

mkdir grch38_1kgmaj_bt2_db; cd grch38_1kgmaj_bt2_db
curl -o grch38_1kgmaj_bt2.zip ftp://ftp.ccb.jhu.edu/pub/data/bowtie2_indexes/grch38_1kgmaj_bt2.zip
unzip grch38_1kgmaj_bt2.zip
cd ../../


