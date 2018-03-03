#!/usr/bin/perl
$latex = 'platex -kanji=utf-8 -synctex=1 -interaction=nonstopmode %S';
$bibtex = 'pbibtex %O %B';
$dvipdf = 'dvipdfmx %S';
$pdf_mode = 3; # use dvipdf
$pdf_update_method = 2;
# $pdf_previewer = 'start "C:/Program Files/SumatraPDF/SumatraPDF.exe" %O %S';
if ($^O eq 'msys') {
    $pdf_previewer = 'start "C:/Program Files/SumatraPDF/SumatraPDF.exe" %O %S';
} elsif ($^O eq 'linux') {
#    $pdf_previewer = 'evince %S & invevince %S "vim %f +%l"';
    $pdf_previewer = 'evince %S';
}
$max_repeat = 5;
#prevent latexmk from removing PDF after typeset
$pvc_view_file_via_temporary = 0;

