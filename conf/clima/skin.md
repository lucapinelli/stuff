----

# Skin File


## What this example demonstrates

* read a skin from the skin file in the example directory
* print this text with the skin just deserialized
* a simple template
* ~~animated style transitions~~

## How it works

The skin file is read into a string, then **deserialized** into a `MadSkin`:

```
let hjson = fs::read_to_string(file_path)?;
let skin: MadSkin = deser_hjson::from_str(&hjson)?;
```

*(of course it doesn't have to be Hjson, it can be JSON, TOML, or any serde compatible format of your choice)*

As we want to print the real skin file, we use a template (see the complete code), but using the skin could have been as simple as

```
skin.print_text(MD);
```

In your own program, you may want to not parse a `MadSkin` but some specific styling parts then build the skin(s) yourself.
In this case, use the various functions of the `parse` module: they allow parsing `Color`, `LineStyle`, `CompoundStyle`, `StyledChar`, etc. from strings using the same syntax than for a whole skin deserialization.

## Skin syntax

Here's the content of the skin file used to render this text:

    ${skin}

### Colors:

A color can be described as
* one of the standard ANSI color names: `red`, `yellow`, `magenta`, etc.
* a gray level, `gray(0)` (dark) to `gray(23)` (light)
* an ANSI color code, eg `ansi(123)`
* a rgb color, eg `rgb(255, 0, 50)`, `#fb0`, or `#cafe00`

### Inline styles:

Inline styles are "bold", "italic", "strikeout", "inline-code", and "ellipsis".

They're defined by a foreground color, a background color, and attributes, all those parts being optional.

The first encountered color is the foreground color. If you want no foreground color but a background one, use `none`, eg `bold none red`.

### Line styles

Line styles are "paragraph", "code-block", and "table".

They're defined like inline styles but accept an optional alignment (`left`, `right`, or `center`) and optional left and right margins.

### Styled chars

Styled chars are "bullet", "quote", and "horizontal-rule".

They're defined by a character (which must be one character wide and long), and foreground and background colors. All parts are optional.

### Scrolled bar

It's defined either by
* a char, a fg color and a bg color, all parts optional
* a struct with two styled chars named `track` and `thumb`

Examples:

```Hjson
scrollbar: white
```

```Hjson
scrollbar: {
    track: | darkblue black
    thumb: | lightblue black bold
}
```

### Headers:

Headers are line styles too.
They can he defined one per one:

    headers: [
        yellow bold center
        yellow underlined
        yellow
    ]

*(you don't have to define all 8 possible levels, others will stay default)*

It's also possible to change all default headers with a shortened syntax. The example below would set all headers to be in yellow and italic but keep all other properties as default:

    headers: yellow italic

### Summary: Skin entries

|:-:|:-:|:-:|
|**keys**|**type**|**comments**|
|:-:|:-:|:-|
|bold|inline|
|italic|inline|
|strikeout|inline|
|inline-code, inline_code|inline|
|paragraph|line|standard line
|code-block, code_block|line|
|table|line|fg and bg colors are for the border
|bullet|character|
|quote, quote-mark, quote_mark|character|
|scrollbar|character|
|horizontal-rule, horizontal_rule, rule|character|
|:-:|:-:|:-|

----

### Quotes

> Listen for silence in noisy places;
> feel at peace in the midst of disturbance;
> awaken joy when there is no reason.
>
> Gurudeva
