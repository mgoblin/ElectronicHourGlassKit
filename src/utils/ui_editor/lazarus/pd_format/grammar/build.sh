#!/bin/bash

pyacc pd.y pd_parser
plex pd.l pd_lexer.pas
fpc pd_parser.pas
