"-------------------------------------------------------------------------------
" 全般設定
"-------------------------------------------------------------------------------
set nocompatible
set number
set ruler
set title
set linespace=0
set showcmd

"-------------------------------------------------------------------------------
" 検索
"-------------------------------------------------------------------------------
set ignorecase  " 大文字小文字無視
set smartcase  " 大文字ではじめたら大文字小文字無視しない
set wrapscan  " 最後まで検索したら先頭へ戻る
set hlsearch  " 検索文字をハイライト
set incsearch  " インクリメンタルサーチ

"-------------------------------------------------------------------------------
" タブ
"-------------------------------------------------------------------------------
set tabstop=4    " tabstopはTab文字を画面上で何文字分に展開するか
set smarttab
set shiftwidth=4
set shiftround
set nowrap
set lcs=tab:>.,trail:_,extends:\
set list

"-------------------------------------------------------------------------------
" 色
"-------------------------------------------------------------------------------
syntax on
highlight LineNr ctermfg=darkgrey

" 全角スペースの表示
highlight ZenkakuSpace cterm=underline ctermfg=lightblue guibg=darkgray
match ZenkakuSpace /　/

" タブページの切り替えをSHIFT+Tabで行うように.
nmap <S-Tab> gT
