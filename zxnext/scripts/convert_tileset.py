###############################################################################
#
#  (c) 2023 David Crespo - https://github.com/dcrespo3d
#                          https://davidprograma.itch.io
#                          https://www.youtube.com/@Davidprograma
#
###############################################################################

# http://omz-software.com/pythonista/docs/ios/PIL.html

from PIL import Image

# tile width and height
tw = 8
th = 8

# max palette index count
MPIC = 16

ifn_set = '../art/tileset.png'
ifn_grp = '../art/tileset_palgroup.txt'
ifn_pal = '../art/tileset_palette_extra.txt'

ofn_bmp = '../res/tileset_bitmap.bin'
ofn_pal = '../res/tileset_palette.bin'


dolog = True

def padSpace2(val):
    sval = str(val)
    while len(sval) < 2: sval = ' ' + sval
    return sval

def process_tileset(ifn_set, ifn_grp, ifn_pal, ofn_bmp, ofn_pal):
    print('reading ' + ifn_pal)
    grp_palette_arr_extra = load_palette_rgb333(ifn_pal)
    print(grp_palette_arr_extra)

    print('reading ' + ifn_grp)
    f = open(ifn_grp, 'rt')
    palgroup_txt = f.read()
    f.close()

    print('reading ' + ifn_set)
    img = Image.open(ifn_set)

    img = img.convert('RGBA')

    w = img.size[0]
    h = img.size[1]

    print('image size:', w, 'x', h, '->', w*h, 'pixels')
    print('image mode:', img.mode)

    ncols = w // tw
    nrows = h // th
    nblocks = ncols * nrows

    print('blocks:', ncols, 'X', nrows, '->', nblocks, 'blocks')

    timgs = cut_img_to_tiles(img, nrows, ncols)
    # timgs[0].save('test_out.png')

    rgb333imgs = []
    for timg in timgs:
        rgb333imgs.append(rgb333img_for_tile_img(timg))

    palgroup_arr = create_palgroup_arr(palgroup_txt)
    palgroup_tbl = create_palgroup_tbl(palgroup_arr)
    grp_palette_arr = create_grp_palette_arr_for_img_groups(rgb333imgs, palgroup_tbl)
    # grp_palette_tbl = grp_palette_tbl_for_grp_palette_arr(grp_palette_arr)

    print('implicit palette (taken from tileset)')
    for ipal in range(16):
        if not ipal in grp_palette_arr: continue
        pal = grp_palette_arr[ipal]
        s = padSpace2(ipal) + ' ' + padSpace2(len(pal)) + ': '
        for entry in pal: s += entry + ' '
        print(s)

    print('explicit palette (taken from extra palette)')
    for ipal in range(16):
        if ipal in grp_palette_arr: continue
        if not ipal in grp_palette_arr_extra: continue
        grp_palette_arr[ipal] = grp_palette_arr_extra[ipal]
        pal = grp_palette_arr[ipal]
        s = padSpace2(ipal) + ' ' + padSpace2(len(pal)) + ': '
        for entry in pal: s += entry + ' '
        print(s)


    indeximgs = []
    for tidx in range(len(rgb333imgs)):
        rgb333img = rgb333imgs[tidx]
        g = palgroup_arr[tidx]
        palette_arr = grp_palette_arr[g]
        indeximg = indeximg_for_rgb333img_and_palette(rgb333img, palette_arr)
        indeximgs.append(indeximg)

    tileset8 = []
    for indeximg in indeximgs:
        for index in indeximg:
            tileset8.append(index)

    # row8 = ''
    # for val in tileset8:
    #     if val == 0: row8 += ' '
    #     else:        row8 += 'X'
    #     if len(row8) == 8:
    #         print(row8)
    #         row8 = ''

    tileset4 = to_4bit_values(tileset8)

    # row8 = ''
    # for val4 in tileset4:
    #     for i in range(2):
    #         val = val4 & 0xF0
    #         if val == 0: row8 += ' '
    #         else:        row8 += 'X'
    #         if len(row8) == 8:
    #             print(row8)
    #             row8 = ''
    #         val4 = val4 << 4

    print('writing ' + ofn_bmp)
    f = open(ofn_bmp, 'wb')
    f.write(bytes(tileset4))
    f.close()

    full_palette = create_full_palette_for_grp_palette_arr(grp_palette_arr)
    print('writing ' + ofn_pal)
    write_full_palette_to_next_palette_file(full_palette, ofn_pal)

    # print('full_palette:', full_palette)
    # for i in range(1,8):
    #     darken_full_palette(full_palette, 1)
    #     # print('full_palette:', full_palette)
    #     fn = ofn_pal.replace('.bin', '_'+str(i)+'.bin')
    #     write_full_palette_to_next_palette_file(full_palette, fn)

def load_palette_rgb333(ifn):
    f = open(ifn, 'rt')
    itxt = f.read()
    f.close()

    grp_palette_arr_extra = {}
    ipal = 0
    for line in itxt.splitlines():
        toks = line.split(',')
        pal = []
        for tok in toks:
            tok = tok.strip()
            if tok: pal.append(tok)
        grp_palette_arr_extra[ipal] = pal
        ipal += 1
    return grp_palette_arr_extra

def cut_img_to_tiles(img, nrows, ncols):
    timgs = []
    for r in range(nrows):
        for c in range(ncols):
            box = [c*tw, r*th, tw+c*tw, th+r*th]
            timg = img.crop(box)
            timgs.append(timg)
    return timgs

def rgb333img_for_tile_img(img):
    w, h = img.size
    rgb333img = []
    for y in range(h):
        for x in range(w):
            pixel = img.getpixel((x,y))
            r, g, b, a = pixel
            pixel = r, g, b
            s = ''
            for c in pixel:
                s += str(c >> 5)
            # print(s, pixel)
            rgb333img.append(s)
    return rgb333img

def create_palgroup_arr(palgroup_txt):
    palgroup_txt = palgroup_txt.replace('\n', '')
    palgroup_arr = []
    for ch in palgroup_txt:
        val = int(ch, 16)
        palgroup_arr.append(val)
    # print(palgroup_arr)
    return palgroup_arr

def create_palgroup_tbl(palgroup_arr):
    palgroup_tbl = {}
    for ti in range(len(palgroup_arr)):
        g = palgroup_arr[ti]
        if not g in palgroup_tbl:
            palgroup_tbl[g] = []
        palgroup_tbl[g].append(ti)
    # print(palgroup_tbl)
    return palgroup_tbl

def create_grp_palette_arr_for_img_groups(rgb333imgs, palgroup_tbl):
    grp_palette_arr = {}
    for g in palgroup_tbl:
        tiarr = palgroup_tbl[g]
        palette_set = set()
        for ti in tiarr:
            rgb333img = rgb333imgs[ti]
            for rgb333 in rgb333img:
                palette_set.add(rgb333)
        palette_arr = list(palette_set)
        palette_arr.sort()
        grp_palette_arr[g] = list(palette_arr)

    # for k in grp_palette_arr:
    #     print(k, len(grp_palette_arr[k]), grp_palette_arr[k])
    return grp_palette_arr

def palette_tbl_for_palette_arr(palette_arr):
    palette_tbl = {}
    for i in range(len(palette_arr)):
        rgb333 = palette_arr[i]
        palette_tbl[rgb333] = i
    return palette_tbl

# def grp_palette_tbl_for_grp_palette_arr(grp_palette_arr):
#     grp_palette_tbl = {}
#     for g in grp_palette_arr:
#         palette_arr = grp_palette_arr[g]
#         palette_tbl = palette_tbl_for_palette_arr(palette_arr)
#         grp_palette_tbl[g] = palette_tbl
#     print(grp_palette_tbl)
#     return grp_palette_tbl

def indeximg_for_rgb333img_and_palette(rgb333img, palette_arr):
    indeximg = []
    for rgb333 in rgb333img:
        index = palette_arr.index(rgb333)
        indeximg.append(index)
    return indeximg

def to_4bit_values(tileset8):
    tileset4 = []
    for n in range(len(tileset8) // 2):
        hi = tileset8[2*n+0] & 15
        lo = tileset8[2*n+1] & 15
        val = hi << 4 | lo
        tileset4.append(val)
    return bytes(tileset4)

def create_full_palette_for_grp_palette_arr(grp_palette_arr):
    full_palette = []
    garr = []
    for g in grp_palette_arr:
        garr.append(g)
    garr.sort()
    for g in garr:
        palette_arr = grp_palette_arr[g]
        for i in range(MPIC):
            if i < len(palette_arr):
                full_palette.append(palette_arr[i])
            else:
                full_palette.append('000')
    # print('full_palette', full_palette)
    return full_palette

def write_full_palette_to_next_palette_file(full_palette, fn):
    intarr = []
    for entry in full_palette:
        r = int(entry[0])
        g = int(entry[1])
        b = int(entry[2])
        rgb333 = r << 6 | g << 3 | b
        intarr.append(rgb333 >> 1)
        intarr.append(rgb333 & 1)
    f = open(fn, 'wb')
    f.write(bytes(intarr))
    f.close()

def darken_full_palette(fp, val):
    for i in range(len(fp)):
        entry = fp[i]
        r = int(entry[0])
        g = int(entry[1])
        b = int(entry[2])
        r -= val
        g -= val
        b -= val
        if r < 0 : r = 0
        if g < 0 : g = 0
        if b < 0 : b = 0
        entry = str(r) + str(g) + str(b)
        fp[i] = entry

def convert_tileset():
    print('*' * 60)
    print('**  Converting Tileset')
    print('*' * 60)

    process_tileset(ifn_set, ifn_grp, ifn_pal, ofn_bmp, ofn_pal)

if __name__ == '__main__':
    convert_tileset()
