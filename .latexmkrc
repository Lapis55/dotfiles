#!/usr/bin/perl
$latex = 'platex -kanji=utf-8 -synctex=1 -interaction=nonstopmode %S';
$bibtex = 'pbibtex %O %B';
$dvipdf = 'dvipdfmx %S';
$pdf_mode = 3; # use dvipdf
$pdf_update_method = 2;
$pdf_previewer = 'start "c:/Program Files/SumatraPDF/SumatraPDF.exe" %O %S';
$max_repeat       = 5;
# Prevent latexmk from removing PDF after typeset.
$pvc_view_file_via_temporary = 0;