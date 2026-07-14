from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets' / 'previews'
OUT.mkdir(parents=True, exist_ok=True)

W, H = 1600, 1000
BG = '#17131f'
SURFACE = '#211c2a'
SURFACE_HIGH = '#302938'
PRIMARY = '#d4bbff'
ON_PRIMARY = '#3a225f'
SECONDARY = '#d1c0dc'
SECONDARY_CONTAINER = '#4c4055'
TERTIARY = '#a7d9d4'
TERTIARY_CONTAINER = '#254f4d'
TEXT = '#eee7f2'
TEXT_2 = '#cbc3cf'
OUTLINE = '#958d99'
ERROR = '#ffb4ab'


def rect(x, y, w, h, r, fill, stroke='none', sw=0, opacity=1):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}" opacity="{opacity}"/>'


def text(x, y, value, size=24, weight=400, fill=TEXT, anchor='start'):
    safe = value.replace('&', '&amp;')
    return f'<text x="{x}" y="{y}" font-family="Roboto, sans-serif" font-size="{size}" font-weight="{weight}" fill="{fill}" text-anchor="{anchor}">{safe}</text>'


def circle(cx, cy, r, fill, stroke='none', sw=0):
    return f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}"/>'


def icon_wifi(x, y, color=TEXT):
    return f'''<g fill="none" stroke="{color}" stroke-width="5" stroke-linecap="round">
    <path d="M{x-22} {y-5} Q{x} {y-25} {x+22} {y-5}"/><path d="M{x-14} {y+4} Q{x} {y-9} {x+14} {y+4}"/><path d="M{x-5} {y+13} Q{x} {y+8} {x+5} {y+13}"/></g>'''


def icon_bt(x, y, color=TEXT):
    return f'''<g fill="none" stroke="{color}" stroke-width="4" stroke-linecap="round" stroke-linejoin="round">
    <path d="M{x} {y-22} L{x+15} {y-8} L{x-15} {y+18} M{x} {y+24} L{x+15} {y+9} L{x-15} {y-17} M{x} {y-22} L{x} {y+24}"/></g>'''


def icon_sun(x, y, color=TEXT):
    rays = ''.join(f'<line x1="{x}" y1="{y-29}" x2="{x}" y2="{y-22}" transform="rotate({a} {x} {y})"/>' for a in range(0, 360, 45))
    return f'<g fill="none" stroke="{color}" stroke-width="4" stroke-linecap="round">{circle(x,y,11,"none",color,4)}{rays}</g>'


def base(title):
    parts = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">']
    parts.append('''<defs><linearGradient id="wall" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#2b203d"/><stop offset=".5" stop-color="#594078"/><stop offset="1" stop-color="#1e5d5d"/></linearGradient><radialGradient id="glow"><stop stop-color="#d9b8ff" stop-opacity=".55"/><stop offset="1" stop-color="#d9b8ff" stop-opacity="0"/></radialGradient></defs>''')
    parts += [rect(0, 0, W, H, 0, 'url(#wall)'), circle(370, 280, 420, 'url(#glow)'), rect(12, 10, W-24, 64, 32, SURFACE, OUTLINE, 1)]
    parts += [rect(20, 18, 172, 48, 24, SECONDARY_CONTAINER), text(52, 50, '⌘  Space 1', 18, 600), text(218, 49, title, 18, 500)]
    parts += [text(1185, 49, 'Tue 14  ·  10:42', 17, 500), rect(1370, 18, 206, 48, 24, SECONDARY_CONTAINER), icon_wifi(1400, 42), text(1430, 49, '▮▮  56%   2', 17, 600)]
    return parts


def finish(parts, name):
    parts.append('</svg>')
    (OUT / f'{name}.svg').write_text('\n'.join(parts))


def quick_settings():
    p = base('Firefox — Material guidance')
    x, y, w, h = 1032, 92, 536, 866
    p += [rect(x, y, w, h, 36, SURFACE, OUTLINE, 1), text(x+28, y+52, 'Control center', 30, 600), text(x+28, y+82, 'Live system controls', 16, 400, TEXT_2)]
    p += [circle(x+w-92, y+48, 24, SURFACE_HIGH), text(x+w-92, y+56, '⚙', 22, 500, TEXT, 'middle'), circle(x+w-40, y+48, 24, SURFACE_HIGH), text(x+w-40, y+56, '⏻', 22, 500, TEXT, 'middle')]
    tiles = [
        (x+24,y+112,238,94,'Wi‑Fi','Connected',True,'wifi'),
        (x+274,y+112,238,94,'Bluetooth','Available',True,'bt'),
        (x+24,y+218,238,94,'Do Not Disturb','Alerts on',False,'moon'),
        (x+274,y+218,238,94,'Dark theme','On',True,'moon'),
        (x+24,y+324,238,94,'Night light','Unavailable',False,'sun'),
        (x+274,y+324,238,94,'Keyboard','English (US)',False,'kbd'),
    ]
    for tx,ty,tw,th,label,sub,sel,kind in tiles:
        fill = SECONDARY_CONTAINER if sel else SURFACE_HIGH
        # M3E toggle shape response: checked is more squared; unchecked is rounder.
        p.append(rect(tx,ty,tw,th,18 if sel else 28,fill))
        p.append(circle(tx+38,ty+47,22,TERTIARY_CONTAINER if sel else SURFACE))
        if kind=='wifi': p.append(icon_wifi(tx+38,ty+47,TERTIARY))
        elif kind=='bt': p.append(icon_bt(tx+38,ty+47,TERTIARY))
        elif kind=='sun': p.append(icon_sun(tx+38,ty+47,TEXT_2))
        else: p.append(text(tx+38,ty+55,'●' if kind=='moon' else '⌨',22,500,TEXT,'middle'))
        p.append(text(tx+74,ty+39,label,17,600))
        p.append(text(tx+74,ty+65,sub,14,400,TEXT_2))

    p.append(text(x+24,y+452,'Audio',20,600))

    def audio_card(sy, title, device, value, input_endpoint=False):
        accent = SECONDARY if input_endpoint else PRIMARY
        active_fill = '#7d6c91' if input_endpoint else '#70558e'
        p.append(rect(x+24,sy,w-48,110,24,SURFACE_HIGH))
        p.append(text(x+42,sy+29,title,16,600))
        p.append(text(x+w-43,sy+29,f'{value}%',15,600,TEXT,'end'))
        # Expressive split button: primary action + source menu segment.
        p.append(rect(x+40,sy+43,248,50,25,SECONDARY_CONTAINER))
        p.append(text(x+62,sy+74,'◖' if not input_endpoint else '●',18,600,TEXT))
        p.append(text(x+87,sy+74,device,14,600))
        p.append(rect(x+244,sy+47,40,42,21,'#5b4d65'))
        p.append(text(x+264,sy+74,'⌄',18,600,TEXT,'middle'))
        # M3E slider: thick tonal track, gap around a narrow expressive handle.
        sx, sw, sh = x+310, 178, 22
        fillw = sw * value / 100
        handle_x = sx + fillw
        p.append(rect(sx,sy+57,sw,sh,11,'#4d4454'))
        p.append(rect(sx,sy+57,max(18,fillw-7),sh,11,active_fill))
        p.append(rect(handle_x-3,sy+51,6,34,3,accent))
        p.append(circle(sx+14,sy+68,7,accent))

    audio_card(y+470,'Output','Built‑in speakers',56,False)
    audio_card(y+590,'Input','USB microphone',72,True)

    by = y+710
    p.append(rect(x+24,by,w-48,84,24,SURFACE_HIGH))
    p.append(text(x+42,by+30,'Brightness',16,600))
    p.append(text(x+w-43,by+30,'72%',15,600,TEXT,'end'))
    sx, sw, fillw = x+42, w-84, (w-84)*.72
    p.append(rect(sx,by+50,sw,22,11,'#4d4454'))
    p.append(rect(sx,by+50,fillw-7,22,11,'#6c6b49'))
    p.append(rect(sx+fillw-3,by+44,6,34,3,TERTIARY))
    p.append(icon_sun(sx+15,by+61,TERTIARY))

    p.append(text(x+24,y+815,'Power profile',15,600))
    p.append(rect(x+24,y+826,w-48,40,20,SURFACE_HIGH))
    p.append(rect(x+180,y+830,164,32,14,SECONDARY_CONTAINER))
    p.append(text(x+101,y+853,'Saver',13,500,TEXT_2,'middle'))
    p.append(text(x+262,y+853,'Balanced',13,600,TEXT,'middle'))
    p.append(text(x+425,y+853,'Fast',13,500,TEXT_2,'middle'))
    finish(p,'quick-settings')


def launcher():
    p = base('Desktop')
    x,y,w,h=180,112,1240,820
    p += [rect(x,y,w,h,40,SURFACE,OUTLINE,1), rect(x+36,y+34,w-108,66,33,SURFACE_HIGH), text(x+76,y+76,'⌕',28,500,TEXT_2), text(x+118,y+76,'Search apps, settings, files, and actions',19,400,TEXT_2), circle(x+w-42,y+67,30,SURFACE_HIGH), text(x+w-42,y+76,'◉',20,500,TEXT_2,'middle')]
    p += [text(x+40,y+150,'Your apps',30,600), text(x+40,y+180,'8 recent and pinned',16,400,TEXT_2), rect(x+w-130,y+132,90,48,24,SECONDARY_CONTAINER), text(x+w-85,y+163,'▦   ≡',22,600,TEXT,'middle')]
    apps=[('F','Firefox'),('W','WezTerm'),('F','Files'),('T','Text Editor'),('C','Calculator'),('I','Image Viewer'),('V','Videos'),('S','Settings'),('A','Audio'),('P','PDFs'),('D','Disk Usage'),('M','Monitor')]
    for i,(letter,label) in enumerate(apps):
        col=i%6; row=i//6; tx=x+38+col*194; ty=y+214+row*242
        p.append(rect(tx,ty,174,214,28,SURFACE_HIGH))
        fill=TERTIARY_CONTAINER if i%3==0 else SECONDARY_CONTAINER if i%3==1 else '#49364a'
        p.append(circle(tx+87,ty+82,44,fill)); p.append(text(tx+87,ty+95,letter,34,600,TERTIARY if i%3==0 else TEXT,'middle'))
        p.append(text(tx+87,ty+160,label,17,600,TEXT,'middle'))
        p.append(text(tx+87,ty+187,'Application',13,400,TEXT_2,'middle'))
    finish(p,'launcher')


def overview():
    p=base('Spaces')
    x,y,w,h=130,108,1340,830
    p += [rect(x,y,w,h,40,SURFACE,OUTLINE,1), text(x+34,y+56,'Spaces',30,600), text(x+34,y+86,'A spatial map of work',16,400,TEXT_2), rect(x+w-184,y+26,150,52,26,SECONDARY_CONTAINER), text(x+w-109,y+59,'＋ New space',16,600,TEXT,'middle')]
    p += [rect(x+28,y+118,118,h-146,34,SURFACE_HIGH)]
    rail=[('▦','Spaces'),('▣','Windows'),('⌕','Find')]
    for i,(ic,label) in enumerate(rail):
        ry=y+158+i*102
        if i==0: p.append(rect(x+43,ry-30,88,58,29,SECONDARY_CONTAINER))
        p.append(text(x+87,ry,ic,26,600,TEXT,'middle')); p.append(text(x+87,ry+28,label,13,500,TEXT_2,'middle'))
    cards=[]
    for i in range(6):
        col=i%3; row=i//3; tx=x+170+col*376; ty=y+122+row*326
        active=i==0
        cards.append((tx,ty,346,296,active,i+1))
    for tx,ty,tw,th,active,num in cards:
        p.append(rect(tx,ty,tw,th,30, '#4b3864' if active else SURFACE_HIGH))
        p.append(text(tx+22,ty+42,f'Space {num}',19,600))
        p.append(circle(tx+tw-30,ty+32,8,PRIMARY if active else 'none',OUTLINE,3))
        if num==1:
            p.append(rect(tx+20,ty+70,145,188,20,SURFACE)); p.append(circle(tx+92,ty+145,34,TERTIARY_CONTAINER)); p.append(text(tx+92,ty+156,'F',26,600,TERTIARY,'middle')); p.append(text(tx+92,ty+218,'Firefox',15,500,TEXT,'middle'))
            p.append(rect(tx+181,ty+70,145,188,20,SURFACE)); p.append(circle(tx+253,ty+145,34,SECONDARY_CONTAINER)); p.append(text(tx+253,ty+156,'E',26,600,TEXT,'middle')); p.append(text(tx+253,ty+218,'Editor',15,500,TEXT,'middle'))
        elif num==2:
            p.append(rect(tx+56,ty+70,234,188,20,SURFACE)); p.append(circle(tx+173,ty+145,34,SECONDARY_CONTAINER)); p.append(text(tx+173,ty+156,'F',26,600,TEXT,'middle')); p.append(text(tx+173,ty+218,'Files',15,500,TEXT,'middle'))
        else:
            p.append(text(tx+tw/2,ty+170,'Room to begin',16,400,TEXT_2,'middle'))
    finish(p,'overview')

quick_settings(); launcher(); overview()



def render_pngs():
    command = shutil.which('magick') or shutil.which('convert')
    if command is None:
        print('SVG previews generated; install ImageMagick to refresh PNG files.')
        return
    for source in OUT.glob('*.svg'):
        target = source.with_suffix('.png')
        subprocess.run(
            [command, str(source), '-resize', f'{W}x{H}', str(target)],
            check=True,
        )
    print('SVG and PNG previews generated.')


render_pngs()
