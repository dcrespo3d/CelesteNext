#!/bin/python3

# https://pillow.readthedocs.io/en/stable/
# http://omz-software.com/pythonista/docs/ios/PIL.html

from PIL import Image

# sprite width and height
sw = 16
sh = 16

# max palette index count
mpic = 16

# sprite count
spcount = 0

# palette count
palcount = 0

def process_sprite_set_def(sprite_set_def, bmp_fn, pal_fn):
    global spcount, palcount
    spcount = 0
    palcount = 0

    bmp_data = b''
    pal_data = b''
    pal_raw = []

    for sprite_group_def in sprite_set_def:
        grpdata = process_sprite_group_def(sprite_group_def)
        bmp_data += grpdata['bmp']
        pal_data += grpdata['pal']
        pal_raw  += grpdata['pal_raw']

    pal_raw = create_palette_substitutions(pal_raw, 9)

    f = open(bmp_fn, 'wb')
    f.write(bmp_data)
    f.close()

    pal_data = b''
    for rgba3333color in pal_raw:
        by = convert_palette3333color_to_bytes(rgba3333color)
        pal_data += by

    f = open(pal_fn, 'wb')
    f.write(pal_data)
    f.close()

    print_pal_raw(pal_raw)
    # for i in range(1,8):
    #     darken_full_palette(pal_raw, 1)
    #     # print('pal_raw:', pal_raw)
    #     fn = pal_fn.replace('.bin', '_'+str(i)+'.bin')
    #     pal_data = b''
    #     for rgba3333color in pal_raw:
    #         by = convert_palette3333color_to_bytes(rgba3333color)
    #         pal_data += by
    #     f = open(fn, 'wb')
    #     f.write(pal_data)
    #     f.close()

def create_palette_substitutions(pal333arr, subst_index):
    result = []
    for isubpal in range(16):
        for idx in range(len(pal333arr)):
            if isubpal > 0 and idx == subst_index:
                if isubpal - 1 == subst_index:
                    entry = '0007'
                else:
                    entry = pal333arr[isubpal - 1]
            else:
                entry = pal333arr[idx]
            result.append(entry)
    return result

def print_pal_raw(pal_raw):
    s = ''
    for i in range(len(pal_raw)):
        if i % 16 != 0: s += ', '
        s += str(pal_raw[i])
        if i % 16 == 15: s += '\n'
    print(s.rstrip())

def process_sprite_group_def(sprite_group_def):
    global palcount
    print('palette #' + str(palcount) + ':')
    palcount += 1
    
    rgba_imgs = []
    for sprite_def in sprite_group_def:
        spimgs = slice_sprite_def(sprite_def)
        for spimg in spimgs:
            rgba_imgs.append(spimg)
    # print(rgba_imgs)

    rgba3333imgs = []
    for spimg in rgba_imgs:
        rgba3333img = convert_img_to_rgba3333(spimg)
        rgba3333imgs.append(rgba3333img)
    # print(rgba3333imgs[0])

    palette3333set = set()
    for rgba3333img in rgba3333imgs:
        sample_palette(palette3333set, rgba3333img)
    # print(len(palette3333set), palette3333set)

    if len(palette3333set) > mpic:
        print('too many palette entries for')
        print(sprite_group_def)
        return
    
    palette3333set = sorted(palette3333set)
    palette3333table = palette_table_from_set(palette3333set)
    # print(palette3333table)

    indeximgs = []
    for rgba3333img in rgba3333imgs:
        indeximg = convert_rgba3333_to_index(rgba3333img, palette3333table)
        indeximgs.append(indeximg)

    # for indeximg in indeximgs:
    #     print_index_img(indeximg)

    bytedata = b''
    for indeximg in indeximgs:
        bytedata += convert_indeximg_to_bytes(indeximg)

    result = {}
    result['bmp'] = bytedata
    result['pal'] = convert_palette3333table_to_bytes(palette3333table)
    result['pal_raw'] = convert_palette3333table_to_arr(palette3333table)
    return result


def slice_sprite_def(sprite_def):
    global spcount
    spi0 = spcount
    spi1 = spi0

    img = Image.open(sprite_def)
    img = img.convert('RGBA')
    w, h = img.size
    cols, rows = w // sw, h // sh
    spimgs = []
    # print(sprite_def, w, h, cols, rows)
    for r in range(rows):
        for c in range(cols):
            box = [c*sw, r*sh, sw+c*sw, sh+r*sh]
            spimg = img.crop(box)
            # spimg.save(sprite_def.replace('.png','') + '_' + str(r) + '_' + str(c) + '.png')
            spimgs.append(spimg)
            spi1 += 1
    print('    ' + sprite_def.split('/')[-1] + ': index from ' + str(spi0) + ' to ' + str(spi1-1))
    spcount = spi1
    return spimgs

def convert_img_to_rgba3333(img):
    w, h = img.size
    rgba3333img = []
    for y in range(h):
        for x in range(w):
            pixel = img.getpixel((x, y))
            if (pixel[3] == 0):
                pixel = (0,0,0,0)
            s = ''
            for c in pixel:
                s += str(c >> 5)
            # print(s, pixel)
            rgba3333img.append(s)
    return rgba3333img
    
def sample_palette(palette3333set, rgba3333img):
    for pix in rgba3333img:
        palette3333set.add(pix)

def palette_table_from_set(palette3333set):
    palette3333table = {}
    index = 0
    for entry in palette3333set:
        if entry == '0000':
            continue
        else:
            palette3333table[entry] = index
            index += 1
    palette3333table['0000'] = 15            
    return palette3333table

def convert_rgba3333_to_index(rgba3333img, palette3333table):
    indeximg = []
    for pix in rgba3333img:
        indeximg.append(palette3333table[pix])
    return indeximg

def print_index_img(indeximg):
    s = ''
    for y in range(sh):
        for x in range(sw):
            index = indeximg[x + y * sw]
            if index == 15:
                s += '·'
            else:
                s += hex(index).replace('0x', '')
        s += '\n'
    s += '\n'
    print(s)

def convert_indeximg_to_bytes(indeximg):
    barr = []
    for i in range(len(indeximg) // 2):
        hi = indeximg[2*i+0]
        lo = indeximg[2*i+1]
        hilo = hi << 4 | lo
        barr.append(hilo)
    return bytes(barr)

def convert_palette3333color_to_bytes(color):
    r = int(color[0])
    g = int(color[1])
    b = int(color[2])
    by1 = r << 5 | g << 2 | b >> 1
    by2 = b & 1
    return bytes([by1,by2])


def convert_palette3333table_to_bytes(palette3333table):
    arr3333 = []
    for i in range(16):
        arr3333.append('0000')
    for entry in palette3333table:
        index = palette3333table[entry]
        arr3333[index] = entry
    # print(arr3333)
    bypal = b''
    for color in arr3333:
        bypal += convert_palette3333color_to_bytes(color)
    return bypal
    
def convert_palette3333table_to_arr(palette3333table):
    arr3333 = []
    for i in range(16):
        arr3333.append('0000')
    for entry in palette3333table:
        index = palette3333table[entry]
        arr3333[index] = entry
    return arr3333
    
def darken_full_palette(fp, val):
    for i in range(len(fp)):
        entry = fp[i]
        r = int(entry[0])
        g = int(entry[1])
        b = int(entry[2])
        a = int(entry[3])
        r -= val
        g -= val
        b -= val
        if r < 0 : r = 0
        if g < 0 : g = 0
        if b < 0 : b = 0
        entry = str(r) + str(g) + str(b) + str(a)
        fp[i] = entry


def convert_menu_sprites():
    print('*' * 60)
    print('**  Converting Menu Sprites')
    print('*' * 60)

    bmp_fn = '../res/sprite_menu_defs_bmp.bin'
    pal_fn = '../res/sprite_menu_defs_pal.bin'

    sprite_set_def = [
        [
            "../art/col-smarto-huge-head.png",
            "../art/col-dumber-huge-head.png",
        ],
        [
            "../art/col-smarto-huge-shoes.png",
            "../art/col-dumber-huge-shoes.png",
        ],
        [
            "../art/col-smart-idle.png",
        ],
        [
            "../art/col-dumb-idle.png",
            "../art/final-bean.png",
        ],
        [
            "../art/final-objects.png",
        ],
        [
            "../art/final-objects2.png",
        ],
        [
            "../art/placeholder-16x16.png", # empty object in conveyor
        ],
        [
            "../art/final-camera.png",
        ],
        [
            "../art/sprite-allgray.png",
            "../art/sprite-allblack.png",
        ],
        [
            "../art/lock.png",
        ],
        [
            "../art/sprite-font-12-index.png",
        ],
    ]

    process_sprite_set_def(sprite_set_def, bmp_fn, pal_fn)

def convert_game_sprites():
    print('*' * 60)
    print('**  Converting Game Sprites')
    print('*' * 60)

    bmp_fn = '../res/sprite_defs_bmp.bin'
    pal_fn = '../res/sprite_defs_pal.bin'

    sprite_set_def = [
        [
            "../art/sprites.png",
        ],
    ]

    process_sprite_set_def(sprite_set_def, bmp_fn, pal_fn)

if __name__ == '__main__':
    convert_game_sprites()