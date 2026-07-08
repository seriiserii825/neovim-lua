" h2 html to scss at position in scss
let @a='^f"lvf_hc&veyu��Lpa {'

" js log
let @c='^wvt yoconsole.log()i""hpla, pla;'

" delete props vue
let @d='/const propsvf=xx nhG'

" format file
let @f='gg=G'

" js log json stringify
let @j='^wvt yoconsole.log9)�kb�kb�kb();hiJSON.stringify()hpa, null, 4'

" postamn variables clear
let @k="^xf'lhxvf'c: Dj^@a"

" li
let @l='I<li>jjA</li>jjj'

" php my_get_image
let @m='^f=llimy_get_image(id�kb�kb�kb_id(lx$hp'

" vue class
let @n='^f_vf"h"ayGkko&"apa{'

" p
let @p='I<p>jjA</p>jj^llllj'

" copy class from html to scss
function! MacroCopyClassToScss()
  let l:suffix = matchstr(getline('.'), 'class="[^"]*__\zs[a-zA-Z0-9-]\+\ze')
  if empty(l:suffix)
    echohl ErrorMsg | echo 'No BEM element (class="block__x") found on this line' | echohl None
    return
  endif
  for l:winnr in range(1, winnr('$'))
    if bufname(winbufnr(l:winnr)) =~# '\.scss$'
      execute l:winnr . 'wincmd w'
      let l:insert_after = line('$') - 1
      call append(l:insert_after, ['  &__' . l:suffix . ' {', '    ', '  }'])
      call cursor(l:insert_after + 2, 1)
      startinsert!
      return
    endif
  endfor
  echohl ErrorMsg | echo 'No .scss window found' | echohl None
endfunction
let @s = ":call MacroCopyClassToScss()\r"

" h3
let @t='I<h3>jjA</h3>jj^llllj'

" uncomment php block code
let @u='/\/\*\*v/\*\/:s//�kb�kb�kbd'

" vardump
let @v='^vt hl"myovardump("mpA;^'

" delete to up
let @u='Vggx'
