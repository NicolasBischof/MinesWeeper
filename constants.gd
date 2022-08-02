extends Node

const mine_btn_normal_style := preload("res://assets/tres/mine_button_normal_style_box_flat.tres")
const mine_btn_disabled_style := preload("res://assets/tres/mine_button_disabled_style_box_flat.tres")
const mine_btn_exploded_style := preload("res://assets/tres/mine_button_exploded_style.tres")

const square_mine_size := 30
const hexagonal_mine_maximal_diameter := 33

const mine_char := "*"
const mine_mark_char := "!"
const mine_mark_x_offset := 3
const mine_mark_color := Color.DEEP_SKY_BLUE
const mine_incorrectly_marked_color := Color.YELLOW
const mine_exploded_font_color := Color.BLACK
const mine_exploded_bg_color := Color.DARK_RED
const mine_undiscovered_font_color := Color.DARK_RED
const number_font_color := Color.WHITE
