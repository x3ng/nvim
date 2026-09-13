-- Auto-close brackets/quotes while typing.
-- Deliberately mini.pairs instead of nvim-autopairs: it does not map <CR>,
-- which is blink.cmp's accept key.
return {
  "nvim-mini/mini.pairs",
  event = "InsertEnter",
  opts = {},
}
