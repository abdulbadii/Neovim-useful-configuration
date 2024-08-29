A =vim.api
local O,o = vim.o,vim.opt
local Akm, Ac = A.nvim_set_keymap, A.nvim_command
local Inp, Afk,Trm = A.nvim_input, A.nvim_feedkeys,A.nvim_replace_termcodes
--[[
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
 vim.fn.system({
  "git",
  "clone",
  "--filter=blob:none",
  "https://github.com/folke/lazy.nvim.git",
  "--branch=stable", -- latest stable release
  lazypath,
 })
end
vim.opt.rtp:prepend(lazypath)
--require("lazy").setup({
--})
]]
-- GUI
o.cursorline=true -- Cursor line hilite. On GUI, comment out Terminal by --[=[     ]=]
A.nvim_exec([[
highlight LineNr guifg=#DFDFDF
highlight CursorLine guibg=#001927 gui=NONE
highlight CursorLineNr guibg=#FFF009 guifg=#000019 gui=NONE
highlight Search guibg=#D03000 guifg=#FFFF00 gui=NONE
highlight Visual guibg=#FF09F0 guifg=#000000
autocmd!
autocmd InsertLeave * highlight CursorLine guibg=#001927 gui=NONE
autocmd InsertLeave * highlight CursorLineNr guibg=#FFF009 guifg=#000019
autocmd InsertEnter * highlight CursorLine guifg=NONE guibg=NONE gui=underline
autocmd InsertEnter * highlight CursorLineNr guibg=#0303EE guifg=#FBFB00 ]],
false)
-- Terminal
--[=[
A.nvim_exec([[
highlight LineNr ctermfg=254
highlight CursorLine ctermbg=17 cterm=NONE
highlight CursorLineNr ctermbg=yellow ctermfg=black cterm=NONE
highlight Search ctermbg=88 ctermfg=11 cterm=NONE
highlight Visual ctermbg=9 ctermfg=0
autocmd!
autocmd InsertLeave * highlight CursorLine ctermbg=17 cterm=NONE
autocmd InsertLeave * highlight CursorLineNr ctermbg=yellow ctermfg=black
autocmd InsertEnter * highlight CursorLine ctermfg=NONE ctermbg=236 cterm=underline
autocmd InsertEnter * highlight CursorLineNr ctermbg=19 ctermfg=yellow
]],false)
--]=]
-- no auto comment, cursor at last edit position at rows center, leader key TO etc
A.nvim_exec([[
autocmd FileType * setlocal formatoptions-=cro
autocmd BufReadPost * if line("'\"") >0 && line("'\"") <= line('$') | exe 'normal! g`"' | endif
autocmd BufReadPost * execute "normal! zz5\<C-y>"
autocmd VimLeavePre * let @c = &cmdheight
autocmd VimEnter * let &cmdheight= @c| set scroll=3
autocmd CmdlineLeave * if getcmdtype()=~'[/?]' |call searchcount() |endif
autocmd InsertEnter * set timeoutlen=199
autocmd InsertLeave * set timeoutlen=530 |lua Tmr:stop()
autocmd InsertCharPre * lua navK()
autocmd TextChangedI * lua sTmrK()
autocmd ModeChanged [vV\x16]:* let g:V_B=0
]],false)
o.clipboard:append('unnamedplus')
--[=[ A.nvim_exec([[
if vim.fn.has('win32') then
vim.g.clipboard = {
name = 'win32yank',
 copy = {
	['+'] ='win32yank.exe -i --crlf',
	['*'] ='win32yank.exe -i --crlf',
	},
 paste = {
	['+'] ='win32yank.exe -o --lf',
	['*'] ='win32yank.exe -o --lf',
	},
	cache_enabled=0 }
end]])
]=]
vim.g.mapleader=' ' --spacebar is leader key --vim.g.maplocalleader = "9"
o.compatible=false
o.whichwrap:append('<,>,[,],l')
o.shiftwidth=2
o.tabstop=2
O.guicursor='n-v-sm-i-ci-ve:block,i:ver49-iCursor,r:hor49,a:blinkoff99-blinkon710-Cursor/lCursor'
vim.wo.number=true --O.cindent=true O.autoindent=true
Akm('v', '<Esc>', '<cmd>let g:WDx=0<CR><Esc>', {noremap=true,silent=true})
local preK, lasT, C= '',0,1
function navK()
local now,k= vim.loop.hrtime(), vim.v.char
if preK==k and k:match('[jlki;]') then
	C=C+1
	if C>3 and now-lasT<449*1e6 then
		if k==';' then
			Afk(Trm('<Right>'..string.rep('\b',C+1)..'<ESC>`^', true, false, true), 'n',true)
			Akm('n', ';', '', {})
			vim.defer_fn(function()
				Akm('n', ';', "col('.')==col('$')-1? ':lua dEol()<CR>': '\"_x'",{noremap=true,expr=true})
			end, 740)
		else Afk(Trm(string.rep('\b',C)..'<ESC>`^', 1,nil,1), 'n',1) end
		preK=k
	end
else preK=k; C=1;lasT=now end
end
Tmr = vim.loop.new_timer()
local inT1=nil;PreT=nil
function sTmrK() -- Timer to auto exit Insert
	Tmr:stop()
	local now, T, t = vim.loop.hrtime()
	t= Last and (now-Last)/1e6 or 3300
	inT1= inT1 and inT1 or (t<900 and (t>610 and 1330 or 720) or 4700)
	PreT=PreT and PreT or t
	inT1=inT1+(t-PreT>79 and 195 or t-PreT>0 and 45 or 0)
	Tmr:start( (PreT+t+inT1)/2, 0, function()
		vim.schedule(function()
		Afk(Trm("<ESC>`^", 1, nil, 1), 'n',true)
		Last=nil;inT1=nil;PreT=nil
		end)
	end)
	Last=now; PreT=t
end
vim.g.V_B=0
IHld=1 -- h into Insert mode, Leader h toggling keep/cancel auto exit
Akm('n', 'h', "col('.')<col('$')-1? ':lua Last=vim.loop.hrtime()<CR>i' :':lua Last=vim.loop.hrtime()<CR>a'", {expr=true,noremap=true,silent=true})
Akm('v', 'h', [[mode()=="\<C-v>"? 'c': col('.')<col('$')-1? '<cmd>lua Last=vim.loop.hrtime()<CR>"_xi' :'<cmd>lua Last=vim.loop.hrtime()<CR>"_xa']], {expr=true,noremap=true,silent=true})
Akm('i', '<Leader>h', "<C-o>:lua if IHld then Tmr:stop();Last=nil;inT1=nil;PreT=nil;IHld=nil;print('No timeout to exit') else sTmrK();IHld=1;print('Auto exit by timeout')end<CR>", {noremap=true})
Akm('n', '<Space>', 'i <Esc>`^', {noremap=true,silent=true})
Akm('n', '<Leader>h', "col('.')<col('$')-1? '' :'<cmd>lua Last=vim.loop.hrtime()<CR>i'", {expr=true,noremap=true})
Akm('v', '<Leader>i', [[mode()=="\<C-v>" ? '<cmd>lua Last=vim.loop.hrtime()<CR>I': '']],{expr=true,noremap=true})
Akm('n', 's', '<cmd>lua Last=vim.loop.hrtime()<CR>"_s', { noremap=true })
-- INS is into replace mode, toggling there. else does ESC/exit
Akm('n', '<Insert>', ':lua Last=vim.loop.hrtime()<CR>R', {noremap=true})
Akm('c', '<Insert>', '<C-c>', {noremap=true})
vim.keymap.set({'v','o','s','t'}, '<Insert>', '<cmd>let g:WDx=0<CR><Esc>', {noremap=true})
-- Selection
Akm('n', '<Leader><Space>', 'V', {noremap=true,silent=true})
Akm('n', '<Leader>j', 'v', {noremap=true})
Akm('n', '<Leader>v', '<C-v>', {noremap=true})
-- p behaves P except at EOL, vice versa P behaves p, swapping visual-sel/register
Akm('n', 'p', [[ getline('.') !~ "\\S" || col('.')<col('$')-1? getregtype("")[0]==nr2char(22)? 'P`['.nr2char(22).'`]' : 'Pl' : ':lua nlP(1)<CR>']], {expr=true,noremap=true})
function nlP(E)
local l, R,C,s,t = {}, unpack(vim.fn.getpos('.'),2,3)
t=vim.fn.getregtype("")
s=vim.fn.getreg("")
if not E and t=='v' then Ac('normal! ^i\010\027kp')
elseif t=='V' then
	s=s:gsub('^%s+',''):gsub('%s+$',''):gsub('\n','')
	C=C+(E or 0)
	A.nvim_buf_set_text(0, R-1,C-1, R-1,C-1, {s})
	Ac('normal! '..vim.fn.virtcol({R,C+#s})..'|')
elseif E then
	if E>1 then
		s=s:gsub('\n',' ')
		A.nvim_buf_set_text(0, R-1,C-1, R-1,C-1, {s})
		Ac('normal! '..vim.fn.virtcol({R,C})..'|v'..vim.fn.virtcol({R,C+#s})..'|')
	else vim.cmd('normal! '..(E==1 and 'p' or 'P')..'`[`]') end
else
	for m in (s..'\n'):gmatch("(.-)"..'\n') do table.insert(l,m) end
	vim.cmd('normal! 0i'..string.rep('\013',#l)..'\027'..#l..'-P')
end
end
Akm('n', 'P', [[getline('.')!~"\\S" || col('.')<col('$')-1? 'pl': ':lua nlP(0)<CR>']], {expr=true,noremap=true,silent=true})
Akm('v','P','pl',{noremap=true})
Akm('n', '<Leader>p', "col('.')<col('$')-1? ':lua nlP()<CR>': 'a <Esc>:lua nlP(1)<CR>'", {expr=true,noremap=true,silent=true})
Akm('n', '<Leader>P', [[getregtype("")[0]==nr2char(22)? ':lua nlP(2)<CR>':'']], {expr=true,noremap=true,silent=true})
Akm('v', 'p', [[mode()=='V'? 'p': '"_x<cmd>lua nlP(0)<CR>']], {expr=true,noremap=true})
-- Normal's ENTER like Insert's, its Alt drops current line down
Akm('n', '<CR>', 'i<CR><Esc>', {noremap=true,silent=true})
Akm('n', '<M-CR>', 'kA<CR><Space><BS><Esc>', {noremap=true})
Akm('v', '<CR>', "g:V_B? '<Esc>' :'d'", {expr=true,noremap=true})
Akm('n', '<Leader>4', [['`['.getregtype("").'`]']], {expr=true})
Akm('v', 'u', '<Esc>u', {noremap=true})
vim.g.Cwl=nil
-- Navigator
Akm('n', '<M-y>', '<C-e>', {noremap=true})
local C,ltsT = 1,0 -- Progressive/incr. Scroll
function iScrl(U)
	local now, R =vim.loop.hrtime(), U and U or 'j'
	if now-ltsT< 299*1e6 then
		if C<16 then Ac('normal! '..(vim.g.Cwl and 'g' or '')..R)
			if C==15 then Ac('normal! mk') end
		elseif C<49 then Ac('normal! '..(math.floor(C/8))..R) vim.g.Cwl=nil 
		elseif C<79 then Ac('normal! '..(math.floor(C/6))..R)
		else Ac('normal! '..(math.ceil(C/6))..R) end
		C=C+1
		if C%5==0 then ltsT=now end
	else Ac('normal! '..(vim.g.Cwl and 'g' or '')..R) C=1
		ltsT=now end
end
Akm('n', 'j', [[col('.')==1? "k$:if virtcol('$')>winwidth(0)-&numberwidth |let g:Cwl=1 |endif<CR>" :'h']], {expr=true,noremap=true,silent=true})
Akm('n', 'l', [[col('.')==col('$')-1? "j^:if virtcol('$')>winwidth(0)-&numberwidth |let g:Cwl=1 |endif<CR>" :'l']], {expr=true,noremap=true,silent=true})
Akm('n', 'i', ":lua iScrl('k')<CR>", {noremap=true,silent=true})
Akm('n', 'k', ':lua iScrl()<CR>', {noremap=true,silent=true})
Akm('v', 'j', [[col('.') == 1? 'k$<cmd>let g:V_B=0<CR>': 'h<cmd>let g:V_B=0<CR>']], {noremap=true,expr=true})
Akm('v', 'l', [[col('.') == col('$')-1? 'j0<cmd>let g:V_B=0<CR>' : 'l<cmd>let g:V_B=0<CR>']], { noremap=true, expr=true })
Akm('v', 'i', 'k<cmd>let g:V_B=0<CR>', { noremap=true,silent=true })
Akm('v', 'k', 'j<cmd>let g:V_B=0<CR>', { noremap=true,silent=true })
Akm('n', '<C-Up>', '<C-b>', { noremap=true })
Akm('n', '<C-Down>', '<C-f>', { noremap=true })
Akm('n', '<Up>', '<C-u>', { noremap=true})
Akm('n', '<Down>', '<C-d>', { noremap=true})
local R,C, Lc,Rc, I,S, Pt,Pre, Wrp = 0,0,0,0,0 -- Get through end points on line
function eol(i)
local r,c,x = unpack(vim.fn.getpos('.'),2,3)
if i~=Pre or r~=R or c~=Pt then
	Wrp= Wrp and Wrp or vim.fn.winwidth(0)-vim.opt.numberwidth:get()
	if r==R and (c<=Lc or Rc<=c) then c=C end
	if i then S={'^','0', vim.fn.virtcol({r,c})..'|','g_','$'}
	else
		S={'g_','$', vim.fn.virtcol({r,c})..'|','^','0'}
		for e= Wrp,vim.fn.col('$'), Wrp do table.insert( S,3,e..'|') end
	end
	vim.g.Cwl= Wrp<vim.fn.col('$') and 1 or nil
	I=0; R=r;C=c; Pre=i; Pt=0
end
while	1 do I=I+1
	Ac( 'normal! '..S[I])
	x=vim.fn.col('.')
	if I==1 then if i then Lc=x else Rc=x end
	elseif I==4 then if i then Rc=x else Lc=x end end
	if x~=Pt then Pt=x break end
	I=I % #S
end
I=I % #S
end
Akm('n', '[', ':lua eol()<CR>', {silent=true,noremap=true})
Akm('n', '0', ':lua eol(1)<CR>', {silent=true,noremap=true})
Akm('v', '0', '<cmd>lua eol(1)<CR>', {silent=true,noremap=true})
Akm('n', '<Leader>l', 'v<cmd>lua eol()<CR>', {silent=true,noremap=true})
Akm('v', '<Leader>l', '<cmd>lua eol()<CR>', {silent=true,noremap=true})
-- ;, n, Del, etc will delete literally, unlike d or x' cut
function dEol()
	Ac("nnoremap ; \\<Nop> |normal! \"_x")
	vim.defer_fn(function()
		Akm('n', ';', "col('.')==col('$')-1? ':lua dEol()<CR>': '\"_x'", {noremap=true,expr=true}) end, 870)
end
Akm('n', ';', "col('.')==col('$')-1? ':lua dEol()<CR>': '\"_x'", {noremap=true,expr=true})
Akm('v', ';', '"_d', { noremap=true })
Akm('n', '<Leader>;', '"_d$', { noremap=true })
Akm('n', 'D', '"_D', { noremap=true })
Akm('i', "<Leader>;", '<C-o>"_d$', { noremap=true })
Akm('n', '<Del>', [[col('.') >= col('$')-1 ? '"_xa': '"_x']], { noremap=true,expr=true})
Akm('i', '<Del>', [[col('.') == col('$') ? '': '<C-o>"_x']], { noremap=true,expr=true })
Akm('v', '<Del>', '"_x', { noremap=true })
Akm('n', '<BS>', [[col('.') == 1 ? '' : 'h"_x']], { noremap=true,expr=true })
Akm('i', '<BS>', "col('.') == 1 ? '' : '<BS>'", { noremap=true,expr=true })
Akm('n', '<Leader>d', '"_d', { noremap=true })
Akm('n', 'n', '"_dd', { noremap=true, silent=true })

Akm('n', '<Leader>t', 'i	<Esc>`^', {noremap=true}) --Tab
Akm('i', '<Leader>t', '	', {noremap=true})
Akm('n', '<M-o>', 'o', {noremap=true}) --Vim o by Alt+o
-- Search. Alt+BACKSP clears cmd entry
Ac([[
cnoremap <M-BS> <C-u>
function! LnM()
	let c=line('.')| let b=line('w$')| let t=line('w0')
	if c>b-4 |execute 'normal! '.(6-b+c)."\<C-e>"
	elseif c<t+4 |execute 'normal! '.(6-c+t)."\<C-y>" |endif
endfunction
nnoremap <silent> <C-n> n:call LnM()<CR>
nnoremap <silent> <C-b> N:call LnM()<CR>
nnoremap <silent> u u:call LnM()<CR>
nnoremap <silent> o <C-r>:call LnM()<CR>
function! EdE()
	call feedkeys("/\<C-u>\\<".@/.'\>', 'nt')
	if mapcheck('<M-CR>','c') != ''|cunmap <M-CR>|endif
endfunction
function! SWd()
	set hlsearch| cnoremap <M-CR> <CR>:call EdE()<CR>
endfunction
nnoremap / :call SWd()<CR>/<C-r><C-w>
function! SSel()
  let [R,C,r,c] = getpos("'<")[1:2]+getpos("'>")[1:2]
	if R!=r |echo "Can't be Multi-line"| return|endif
  call feedkeys('/'.getline(R)[C-1:c-1], 'nt')
  set hlsearch
	cnoremap <M-CR> <CR>:call EdE()<CR>
endfunction
vnoremap / :call SSel()<CR>
]])
vim.g.WDx=0;vim.g.J='' --Select (through) word string joined by .-=/\+*
A.nvim_exec([[
function! s:wdx()
if !g:WDx
	let [R,C]=getpos("'<")[1:2]
	let c=getpos("'>")[2]
	let s=getline(R)
	let Jno= g:J==''
	let g:J= Jno? '[-.=/\\+*]' : '['.g:J.']'
	let [t,b,en]=matchstrpos(s,"\\v^\\w+\\zs%((".g:J.")\\w+%(\\1\\w+)*)?", C-1)
	let s:ST=[] |let s:o=[R,C]
	let FND= b!=en |let b+=1
	if b
		if FND && Jno |let g:J='['.t[0].']' |endif
	else |let en=c
	endif
	let [_,B,E]= matchstrpos(s[0:c-1], "\\v\\w+\\ze%(".g:J."\\w+)+$")
	let B+=1
	if B
		let s:ST= [ virtcol([R,B]).'|v'.virtcol([R,en]).'|' ]
	elseif !b |return 0|endif
	if b && FND
		let s:ST += [ virtcol([R,C]).'|v'.virtcol([R,en]).'|' ]
		let e=0
		while 1 |do
			let e=matchend( t,"\\v^".g:J."\\w+", e)
			let m=b-1+e
			if m>=en ||e<0 |break|endif
			let s:ST += [ virtcol([R,C]).'|v'.virtcol([R,m]).'|' ]
		endwhile
	endif
	if B
		let e=0
		while 1 |do
			let s:ST += [ virtcol([R,B]).'|v'.virtcol([R,E+e]).'|' ]
			let e=matchend( s[E:],"\\v^".g:J."\\w+", e)
			if e<0 |break|endif
		endwhile
	endif
	let g:WDx=1 |let s:I=0
endif
if s:I==len(s:ST) |let g:WDx=0|execute "normal! \<Esc>".virtcol(s:o).'|' |return|endif
execute 'normal! '.s:ST[s:I]
let s:I+=1
endfunction
function! WDX()
	let s=getline('.') |let c=col('.')
	if s[c-1] =~ '\w' | let g:J=''| normal! viw
	elseif s[c-2].s[c-1].s[c] =~ '\w[-.=/\\+*]\w'
		execute "normal! lviw\<Esc>"
		let g:J=matchlist(s,"\\v\\w+([-.=/\\+*])\\w+%(\\1\\w+)*.{,".(col('$')-c-strlen(expand('<cword>')))."}$")[1]
		if g:J !='' |let g:WDx=0 |call <SID>wdx()
	endif|endif
endfunction
nnoremap <silent> <Leader>y :call WDX()<CR>
vnoremap <silent> <Leader>y :call <SID>wdx()<CR>
nnoremap <silent> <Leader>3 :%s/\v\s+$//<CR>
]], false) --^ doc trailing-space cleanup
local Sw2n, LEN,Len,R,C,r,c = nil,0,0 --2 words/selections swap
function swS()
  local VBlk, t, Y,X, y,x = vim.fn.mode()=='\022'
	vim.cmd "highlight Word guibg=#00EF00 guifg=#FF00BB"
	--vim.cmd "highlight Word ctermbg=10 ctermfg=0"
	if VBlk then
		V_C=vim.fn.virtcol({R,C})
		V_c=vim.fn.virtcol({r,c})
	elseif Sw2n then
		Ac('normal! '..(vSl and '' or 'viw')..'\027')
		_,Y,X = unpack(vim.fn.getpos("'<"))
		_,y,x = unpack(vim.fn.getpos("'>"))
		t=A.nvim_buf_get_text(0, Y-1,X-1, y-1,x, {})
		for _,s in ipairs(t) do Len=Len+#s end
		Ac('normal! gvP')
		A.nvim_buf_add_highlight(0, 0, 'Word', Y-1, X-1, X-1+LEN)
		A.nvim_buf_set_text(0, R-1,C-1, r-1, c, t)
		A.nvim_buf_add_highlight(0,-1, 'Word', R-1, C-1, C-1+Len)
		vim.defer_fn(function()
			A.nvim_buf_clear_namespace(0, -1, R-1, R)
			A.nvim_buf_clear_namespace(0, 0, Y-1, Y) end,2770)
		Sw2n=nil
	else LEN=0; Len=0
		Ac('normal! '..(vSl and 'y' or 'viwy'))
		_,R,C = unpack(vim.fn.getpos("'<"))
		_,r,c = unpack(vim.fn.getpos("'>"))
		t=A.nvim_buf_get_text(0, R-1,C-1, r-1,c, {})
		for _,s in ipairs(t) do LEN=LEN+#s end
		A.nvim_buf_add_highlight(0,-1, 'Word', R-1, C-1, C-1+LEN)
		print('Go on next selection or word to swap') Sw2n=1
	end
	vSl=nil
end
Akm('n', '<Leader><CR>', ':lua swS()<CR>', {noremap=true})
Akm('v', '<Leader><CR>', '<cmd>lua vSl=1;swS()<CR>', {})
-- Duplicate line or selection
Akm('n', 'b', ':t.<CR>', {})
function dup(S)
  local VBlk, isVL, blk, of, nl, t, b,d= vim.fn.mode()=='\022', vim.fn.mode()=='V', {}, 0,0
  Ac('normal! \027')
  local _, R,C = unpack(vim.fn.getpos("'<"))
  local _, r,c = unpack(vim.fn.getpos("'>"))
	V_C=vim.fn.virtcol({R,C})
	V_c=vim.fn.virtcol({r,c})
	if VBlk then
		if V_C>V_c then
			wd=V_C-V_c
			C= c+V_c-vim.fn.virtcol({R,c})
			V_C=vim.fn.virtcol({R,C})
		else wd=V_c-V_C end
		for i= R,r do
			d=C+V_C-vim.fn.virtcol({i, C})
			table.insert(blk, vim.fn.getline(i):sub( d,d+wd)) 
		end
		C=C+wd+1
		b=C+vim.fn.virtcol({R,C})
		for i,l in ipairs(blk) do
			if S then C=1
				A.nvim_buf_set_text(0, R-2+i, 0, R-2+i, 0, {l,''})
			else
				d=b-vim.fn.virtcol({R-1+i,C})-1
				A.nvim_buf_set_text(0, R-2+i, d, R-2+i, d, {l}) end
		end
		Ac('normal! '..R..'G'..vim.fn.virtcol({R,C})..'|')
		A.nvim_input('\\<C-v>')
		c=C+wd
		d=c+vim.fn.virtcol({R,c})-vim.fn.virtcol({r,c})
		Ac('normal! v'..r..'G'..vim.fn.virtcol({r,d})..'|')
	else
		c = isVL and vim.fn.col({r,'$'})-1 or c
		t= A.nvim_buf_get_text(0, R-1,C-1, r-1, c, {})
		d=c+1
		if R==r then of=c
		elseif C==1 then table.insert(t,1,'') -- prepend newline
			nl=1 ;d=1 end      
		c= c==vim.fn.col('$') and c-1 or c -- don't get newline col
		A.nvim_buf_set_text(0, r-1,c, r-1,c, t)
		l=r+nl
		Ac('normal! '..l..'G'..vim.fn.virtcol({l,d})..'|')
		r=l+r-R
		c=isVL and '$' or of+#t[#t]
		Ac('normal! v'..r..'G'..vim.fn.virtcol({r, vim.fn.col({r,c})})..'|')
	end
end
Akm('v', 'b', '<cmd>lua dup();vim.g.V_B=1<CR>', {noremap=true})
Akm('v', '<Leader>b','<cmd>lua dup(1);vim.g.V_B=1<CR>', {noremap=true}) 
Akm('n', '<Leader>6', 'vb', {noremap=true})
Akm('n', '<Leader>7', 've', {noremap=true})
vim.g.Lc,vim.g.Vlc=0,0 -- Letter case toggle
Ac([[
function! TtLc()
	let [R,C]=getpos("'<")[1:2]
	let [r,c]=getpos("'>")[1:2]
	let l=getline(R)
	normal! u
	if R!=r
		let s= substitute( l[C-1:], '\v<(\a)(\w*)','\U\1\L\2', 'g')
		call setline( R, l[:C-1].s)
		for i in range( R+1, r-1)
			let s= substitute( getline(i), '\v<(\a)(\w*)','\U\1\L\2', 'g')
			call setline( i,s)
		endfor
		let l=getline(r)
		let s= substitute( l[:c-1], '\v<(\a)(\w*)','\U\1\L\2', 'g')
		call setline( r, s.l[c-1:])
	else
		let s= substitute( l[C-1:c-1], '\v<(\a)(\w*)','\U\1\L\2', 'g')
		call setline( R, (C-1? l[:C-2]:'').s.l[c:])
	endif
endfunction
let [s:i,s:y,s:x]=[0,0,0]
function! LtrC()
if !g:Lc
	let s:S=[ 'gv~', 'gvgU', 'gvgu', 'call TtLc()', '' ]
	let [s:y,s:x]=getpos('.')[1:2]
	let s:i=0
	let g:Lc=1
	nnoremap u u:let g:Lc=0\|let g:Vlc=0\|nunmap u<CR>
endif
let [l,f]=getpos('.')[1:2]
if s:y!=l ||s:x!=f
	let s:y=l |let s:x=f |let s:i=0 |normal! gv
endif
let K='normal! '
if s:i
	if s:i==3 |let K='' |else |let K.='u' |endif|endif
execute K.s:S[s:i].(g:Vlc? (s:i==3? '|normal! ':'').'gv': '')
let s:i+=1 |let s:i %= 5 
endfunction
nnoremap <expr><silent> gu getline('.')[col('.')-1]=~'\w'? 'viw:<C-u>call LtrC()<CR>' :''
vnoremap <silent> gu :<C-u>let g:Vlc=1\|call LtrC()<CR>
]])
-- Move line/selected up
function slUP()
local VBlk, blk, l, s, co, V_C, V_c, wd, base,t = vim.fn.mode()=='\022', {}
Ac('normal! \027')
local _, R,C = unpack(vim.fn.getpos("'<"))
local _, r,c = unpack(vim.fn.getpos("'>"))
V_C=vim.fn.virtcol({R,C})
V_c=vim.fn.virtcol({r,c})
if VBlk then
	if V_C>V_c then
		wd=V_C-V_c
		C= c+V_c-vim.fn.virtcol({R,c})
		V_C=vim.fn.virtcol({R,C})
		c=c+wd
		V_c=vim.fn.virtcol({r,c})
	else wd=V_c-V_C end
	base=C+V_C
	for i= R,r do l=vim.fn.getline(i)
		co= base - vim.fn.virtcol({i, C})
		table.insert(blk, l:sub( co,co+wd)) 
		A.nvim_buf_set_text(0, i-1, co-1, i-1, co+wd, {})
	end
	if vim.fn.virtcol({R-1, '$'})<V_C then
		C=vim.fn.col({R-1,'$'})
		base=C+vim.fn.virtcol({R-1,C})
	end
	for i,l in ipairs(blk) do
		co=base-vim.fn.virtcol({R-2+i,C})-1
		A.nvim_buf_set_text(0, R-3+i, co, R-3+i, co, {l})
	end
	co=base - vim.fn.virtcol({R-1,C})
	Ac('normal! '..(R-1)..'G'..vim.fn.virtcol({R-1,co})..'|')
	A.nvim_input('\\<C-v>')
	co=c+V_c - vim.fn.virtcol({r-1,c})
	Ac('normal! v'..(r-1)..'G'..vim.fn.virtcol({r-1,co})..'|')
else
	s=A.nvim_buf_get_text(0, R-1, C-1, r-1, c, {})
	A.nvim_buf_set_text(0, R-1, C-1, r-1, c, {})
	if vim.fn.virtcol({R-1, '$'})<V_C then
		co=vim.fn.col({R-1,'$'})
	else co=C+V_C - vim.fn.virtcol({R-1,C}) end
	A.nvim_buf_set_text(0, R-2, co-1, R-2, co-1, s)
	Ac('normal! '..(R-1)..'G'..vim.fn.virtcol({R-1,co})..'|v'
	..(r-1)..'G'..vim.fn.virtcol({r-1,c})..'|')
end vim.g.V_B=1
end
Akm('n', 'I', ':m .-2<CR>', {noremap=true,silent=true})
Akm('v', 'I', [[mode()=='V'? ":let g:V_B=1|<C-u>'<-1m '><CR>gv=gv": '<cmd>lua slUP()<CR>']], {noremap=true,expr=true,silent=true})
-- Move line/selected down
function slDN()
local VBlk, blk, l, s, co, V_C, V_c, wd, base,t = vim.fn.mode()=='\022', {}
Ac('normal! \027')
local _, R,C = unpack(vim.fn.getpos("'<"))
local _, r,c = unpack(vim.fn.getpos("'>"))
V_C=vim.fn.virtcol({R,C})
V_c=vim.fn.virtcol({r,c})
if VBlk then
	if V_C>V_c then
		wd=V_C-V_c
		C= c+V_c-vim.fn.virtcol({R,c})
		V_C=vim.fn.virtcol({R,C})
		c=c+wd
		V_c=vim.fn.virtcol({r,c})
	else wd=V_c-V_C end
	base=C+V_C
	for i= R,r do l=vim.fn.getline(i)
		co= base - vim.fn.virtcol({i, C})
		table.insert(blk, l:sub( co,co+wd)) 
		A.nvim_buf_set_text(0, i-1, co-1, i-1, co+wd, {})
	end
	if vim.fn.virtcol({r+1, '$'})<V_C then
		C=vim.fn.col({r+1,'$'})
		base=C+vim.fn.virtcol({r+1,C})
	end
	for i,l in ipairs(blk) do
		co=base-vim.fn.virtcol({R+i,C})-1
		A.nvim_buf_set_text(0, R-1+i, co, R-1+i, co, {l})
	end
	co=base - vim.fn.virtcol({R+1,C})
	Ac('normal! '..(R+1)..'G'..vim.fn.virtcol({R+1,co})..'|')
	A.nvim_input('\\<C-v>')
	co=c+V_c - vim.fn.virtcol({r+1,c})
	Ac('normal! v'..(r+1)..'G'..vim.fn.virtcol({r+1,co})..'|')
else
	s=A.nvim_buf_get_text(0, R-1, C-1, r-1, c, {})
	A.nvim_buf_set_text(0, R-1, C-1, r-1, c, {})
	if vim.fn.virtcol({R+1,'$'})<V_C then
		co=vim.fn.col({R+1,'$'})
	else co= C+V_C -vim.fn.virtcol({R+1,C}) end
	A.nvim_buf_set_text(0, R, co-1, R, co-1, s)
	Ac('normal! '..(R+1)..'G'..vim.fn.virtcol({R+1,co})..'|v'
	..(r+1)..'G'..vim.fn.virtcol({r+1,c})..'|')
end vim.g.V_B=1
end
Akm('n', 'K', ':m .+1<CR>', {noremap=true,silent=true})
Akm('v', 'K', [[mode()=='V'? ":let g:V_B=1|<C-u>'>+1m '<-1<CR>gv=gv": '<cmd>lua slDN()<CR>']], {noremap=true,expr=true,silent=true})
function slLF() -- Move selected left
local VBlk, blk, l, s, co, V_C, V_c, wd, base,t = vim.fn.mode()=='\022', {}
Ac('normal! \027')
local _, R,C = unpack(vim.fn.getpos("'<"))
local _, r,c = unpack(vim.fn.getpos("'>"))
V_C=vim.fn.virtcol({R,C})
V_c=vim.fn.virtcol({r,c})
if VBlk then
	if V_C>V_c then
		wd=V_C-V_c
		C= c+V_c-vim.fn.virtcol({R,c})
		V_C=vim.fn.virtcol({R,C})
		c=c+wd
		V_c=vim.fn.virtcol({r,c})
	else wd=V_c-V_C
	end
	base=C+V_C
	for i= R,r do l=vim.fn.getline(i)
		co= base - vim.fn.virtcol({i, C})
		table.insert(blk, l:sub( co,co+wd)) 
		A.nvim_buf_set_text(0, i-1, co-1, i-1, co+wd, {})
	end
	for i,l in ipairs(blk) do
		co=base-vim.fn.virtcol({R-1+i,C})-2
		A.nvim_buf_set_text(0, R-2+i, co, R-2+i, co, {l})
	end
	co=base - vim.fn.virtcol({R,C})
	Ac('normal! '..R..'G'..vim.fn.virtcol({R,co-1})..'|')
	A.nvim_input('\\<C-v>')
	co=c+V_c - vim.fn.virtcol({r,c})
	Ac('normal! v'..r..'G'..vim.fn.virtcol({r,co-1})..'|')
else
	c=math.min(c,vim.fn.col({r,'$'})-1)
	s=A.nvim_buf_get_text(0, R-1, C-1, r-1, c, {})
	A.nvim_buf_set_text(0, R-1, C-1, r-1, c, {})
	if C<2 then
		R=R-1 ;C=vim.fn.col({R,'$'}) r=r-1
		if R==r	then c='$' end
	else
		C=C-1 if R==r	then c=c-1 end
	end
	A.nvim_buf_set_text(0, R-1, C-1, R-1, C-1, s)
	Ac('normal! '..R..'G'..vim.fn.virtcol({R,C})..'|v'..r..'G'
	..vim.fn.virtcol({r,c})..'|')
end vim.g.V_B=1
end
Akm('v', 'J', '<cmd>lua slLF()<CR>', {noremap=true,silent=true})
function slRG() -- Move selected right
local VBlk, blk, l, s, co, V_C, V_c, wd, base,t = vim.fn.mode()=='\022', {}
Ac('normal! \027')
local _, R,C = unpack(vim.fn.getpos("'<"))
local _, r,c = unpack(vim.fn.getpos("'>"))
V_C=vim.fn.virtcol({R,C})
V_c=vim.fn.virtcol({r,c})
if VBlk then
	if V_C>V_c then
		wd=V_C-V_c
		C= c+V_c-vim.fn.virtcol({R,c})
		V_C=vim.fn.virtcol({R,C})
		c=c+wd
		V_c=vim.fn.virtcol({r,c})
	else wd=V_c-V_C end
	base=C+V_C
	for i= R,r do l=vim.fn.getline(i)
		co= base - vim.fn.virtcol({i, C})
		table.insert(blk, l:sub( co,co+wd)) 
		A.nvim_buf_set_text(0, i-1, co-1, i-1, co+wd, {})
	end
	for i,l in ipairs(blk) do
		co=base-vim.fn.virtcol({R-1+i,C})
		A.nvim_buf_set_text(0, R-2+i, co, R-2+i, co, {l})
	end
	co=base - vim.fn.virtcol({R,C})
	Ac('normal! '..R..'G'..vim.fn.virtcol({R,co+1})..'|')
	A.nvim_input('\\<C-v>')
	co=c+V_c - vim.fn.virtcol({r,c})
	Ac('normal! v'..r..'G'..vim.fn.virtcol({r,co+1})..'|')
else
	print('R, C, r,c,$',R,C,r,c,vim.fn.col({r,'$'}))
	c=math.min(c,vim.fn.col({r,'$'})-1)
	s=A.nvim_buf_get_text(0, R-1, C-1, r-1, c, {})
	A.nvim_buf_set_text(0, R-1, C-1, r-1, c, {})
	if C==vim.fn.col({R,'$'}) then
		C=1; R=R+1 ;r=r+1
		if R==r	then c=#s[1] end
	else
		C=C+1 if R==r	then c=c+1 end
	end
	A.nvim_buf_set_text(0, R-1, C-1, R-1, C-1, s)
	Ac('normal! '..R..'G'..vim.fn.virtcol({R,C})..'|v'..r..'G'
	..vim.fn.virtcol({r,c})..'|')
end
vim.g.V_B=1
end
Akm('v', 'L', '<cmd>lua slRG()<CR>', {noremap=true,silent=true})
-- Comment
Akm('v', 'c', '', {noremap=true})

Akm('n', '<Leader>1', '^vg_', {noremap=true})
Akm('n', '<Leader>9', ':set hlsearch! hlsearch?<CR>',{})
Akm('n', '<Leader>q', ':n noname<CR>', {})
Akm('n', '<Leader>z', '<C-w>w', {noremap=true}) --Switch buffers
O.mouse='a' -- Mouse support toggle
vim.keymap.set({'n','i','c'}, '<F9>', '', {callback=function()
 if O.mouse=='a' then
  vim.wo.number=false O.mouse= ''; print('System/Terminal Mouse')
 else vim.wo.number=true; O.mouse= 'a'; print('Neovim Mouse') end
end})
-- Add # lines of CLI
vim.keymap.set({'n','i','v','c'}, '<F6>','',{callback=function()
  O.cmdheight = O.cmdheight<7 and O.cmdheight+1 or 1
end})
-- show/hide line#
Akm('n', '<F5>',':lua im.wo.number=not vim.wo.number<CR>', {noremap=true,silent=true})
-- Save, Exit
vim.keymap.set({'n','v','i','c'}, '<Leader>x', '', {callback=function()
 if A.nvim_buf_get_option(A.nvim_get_current_buf(), 'modified') then  Ac('w')
 elseif #A.nvim_list_wins() >1 then Ac('q')
 elseif #vim.fn.getbufinfo( {buflisted=1}) >1 then
  Ac('bp| bd #')
 else  Ac('q') end
end})
Akm('n', '<End>', ':bp<CR>', {}) -- END switch to the next/previous buffer

function bg256co()
local B = A.nvim_create_buf(nil, 1)  -- new, unlisted, scratch/temporary buffer
local opts = {
  style = "minimal",
  relative = "editor",
  width = 37, height = 41,
  row = 1, col = 10
}
-- Generate it's content
local k, lines = 0, {}
for bg = 1, 255 do
 for fg = 0, 73 do
  if fg ~= bg then
	 k=k+1 lines[k] = string.format("###===### FG: %03d BG: %03d ###===###", fg, bg)
  end
 end
end
A.nvim_buf_set_lines(B, 0, -1, nil, lines)
local c, win = 0, A.nvim_open_win(B, 1, opts)
A.nvim_win_set_option(win, 'winhl', 'Normal:FloatingWindowBG')
Ac("highlight FloatingWindowBG ctermbg=0")
-- Define highlight groups, apply it
for bg = 1, 255 do
    for fg = 0, 73 do
        if fg ~= bg then
            local hl = string.format("FG%dBG%d", fg, bg)
            Ac(string.format("highlight %s ctermfg=%d ctermbg=%d", hl, fg, bg))
            A.nvim_buf_add_highlight(B, -1, hl, c, 0, -1)
            c = c+1
        end
    end
end print('Total',c)
end
Akm('n', '<F12>', '<cmd>lua bg256co()<CR>', {})
